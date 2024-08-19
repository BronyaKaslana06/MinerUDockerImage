# MinerU docker image

容器默认工作路径

镜像默认为cpu模式，不安装nividia等驱动

## GPU模式

1. ~~在宿主机(ubuntu 22.04)上执行下面的命令~~

   ~~配置apt源~~

   ```shell
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   
   ```

   ~~安装nvidia-container-toolkit~~

   ```shell
   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
   ```

2. 重启docker后构建镜像

   ```powershell
   docker build -t mineru-env-gpu .
   ```

​		在启动container时将本机模型目录挂载到container /PDF-Extract-Kit中

   ```shell
   docker run -v /root/PDF-Extract-Kit:/PDF-Extract-Kit --gpus all -it mineru-env-gpu
   ```

3. 验证安装效果：

   ```powershell
   (MinerU) root@40f64cd07231:/PDF-Extract-Kit# nvidia-smi
   Sun Aug 18 12:46:13 2024
   +-----------------------------------------------------------------------------------------+
   | NVIDIA-SMI 555.52.01              Driver Version: 555.99         CUDA Version: 12.5     |
   |-----------------------------------------+------------------------+----------------------+
   | GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
   | Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
   |                                         |                        |               MIG M. |
   |=========================================+========================+======================|
   |   0  NVIDIA GeForce RTX 4060 ...    On  |   00000000:01:00.0 Off |                  N/A |
   | N/A   55C    P8              2W /  135W |      63MiB /   8188MiB |      0%      Default |
   |                                         |                        |                  N/A |
   +-----------------------------------------+------------------------+----------------------+
   
   +-----------------------------------------------------------------------------------------+
   | Processes:                                                                              |
   |  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
   |        ID   ID                                                               Usage      |
   |=========================================================================================|
   |  No running processes found                                                             |
   +-----------------------------------------------------------------------------------------+
   ```

4. 上传宿主机待处理文件

   ```powershell
    docker cp <path-to-file> <container-name>:/PDF-Extract-Kit
   ```

6. 启动MinerU环境

   ```powershell
   conda activate MinerU
   ```

7. 运行

   ```powershell
   magic-pdf -p <path-to-file>
   ```


7. 运行失败，报错

	```powershell
	RuntimeError: Unexpected error from cudaGetDeviceCount(). Did you 	run some cuda functions before calling NumCudaDevices() that might have already set an error? Error 500: named symbol not found
	```

主要问题是docker container中torch无法使用cuda，但是cuda实际上是安装的。

解决方案：

1. 参考博客 https://blog.csdn.net/abc1831939662/article/details/123455955 ，无效，该博客应该是用来解决多卡的问题。
2. 参考https://stackoverflow.com/questions/66371130/cuda-initialization-unexpected-error-from-cudagetdevicecount  中涉及到k8s的解决方案，我在可以成功运行的宿主机上安装的版本是nvidia-driver-545，但是在container中的版本为530，然而container中无法成功安装545版本，也无法干净的卸载530版本。
