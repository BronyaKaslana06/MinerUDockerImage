# 使用 Anaconda3 Ubuntu 22.04 基础镜像
FROM continuumio/miniconda3:latest

# 设置维护者信息
LABEL maintainer="LitaZ 2152614@tongji.edu.cn"

# 更新并安装必要的软件
RUN apt-get update && apt-get install -y --no-install-recommends \
    # nvidia-driver-545 \
    git-lfs \
    wget \
    libgl1-mesa-glx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 创建 Conda 环境并安装依赖
RUN conda create -n MinerU python=3.10 -y
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate MinerU" >> ~/.bashrc
RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate MinerU && pip install magic-pdf[full]==0.7.0b1 --extra-index-url https://wheels.myhloli.com -i https://pypi.tuna.tsinghua.edu.cn/simple"

# 克隆 Git LFS 仓库并安装 Git LFS
RUN git lfs install && \
    # git lfs clone https://huggingface.co/wanderkid/PDF-Extract-Kit
    git clone https://github.com/opendatalab/MinerU.git && \
    git clone https://www.modelscope.cn/wanderkid/PDF-Extract-Kit.git

# 下载 magic-pdf.template.json 文件
RUN wget https://gitee.com/myhloli/MinerU/raw/master/magic-pdf.template.json -O /root/magic-pdf.template.json

# 创建配置文件 magic-pdf.json 并设置模型路径和其他参数
RUN cp /root/magic-pdf.template.json /root/magic-pdf.json && \
    echo '{ \
        "bucket_info": { \
            "bucket-name-1": ["ak", "sk", "endpoint"], \
            "bucket-name-2": ["ak", "sk", "endpoint"] \
        }, \
        "models-dir": "/PDF-Extract-Kit/models", \
        "device-mode": "cpu", \
        "table-config": { \
            "is_table_recog_enable": false, \
            "max_time": 400 \
        } \
    }' > /root/magic-pdf.json

# 下载测试文件，出错时跳过
RUN wget https://gitee.com/myhloli/MinerU/raw/master/demo/small_ocr.pdf -O /PDF-Extract-Kit/small_ocr.pdf || true

# 设置默认工作目录
WORKDIR /PDF-Extract-Kit

# 执行容器时默认激活 conda 环境并测试 CUDA 加速
# CMD ["/bin/bash", "-c", "source activate MinerU && magic-pdf -p /root/small_ocr.pdf"]
# CMD ["/bin/bash", "-c", "source activate MinerU"]
CMD ["bash"]