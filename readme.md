# MinerU docker image

容器默认工作路径

镜像默认为cpu模式，不安装nividia等驱动

## GPU模式

1. 在宿主机(ubuntu 22.04)上执行下面的命令

   配置apt源

   ```shell
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   
   ```

   安装nvidia-container-toolkit

   ```shell
   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
   ```

2. 重启docker后构建镜像

   ```shell
   docker run --gpus all -it mineru-env # 启用gpu
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

5. 修改配置文件:修改【用户目录】（/root/magic-pdf.json）中配置文件magic-pdf.json中device-mode的值

   ```json
   {
     "device-mode":"cuda"
   }
   ```

6. 运行

   ```powershell
   magic-pdf -p <path-to-file>
   ```

   

## Run

1. 构建 Docker 镜像

	```shell
	docker build -t mineru-env .
	```

2.  运行 Docker 容器

   ```shell
   # docker run --gpus all -it mineru-env # 启用gpu
   docker run -it mineru-env # 不启用gpu（默认）
   ```

3. 容器启动后测试从仓库中下载样本文件，并测试（optional）

   ```shell
   # wget https://gitee.com/myhloli/MinerU/raw/master/demo/small_ocr.pdf
   magic-pdf -p small_ocr.pdf
   ```

4. 提取结果在`/PDF-Extract-Kit/output`中，源代码示例仓库也被拉取到`/MinerU`目录下。
