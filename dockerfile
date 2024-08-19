# 使用 Anaconda3 Ubuntu 22.04 基础镜像
FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# 设置维护者信息
LABEL maintainer="LitaZ 2152614@tongji.edu.cn"

# 更新包列表并安装必要的软件包
RUN apt-get update && apt-get install -y --no-install-recommends \
    git-lfs \
    wget \
    libgl1-mesa-glx \
    libglib2.0-0 \
    # libgthread-2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Miniconda
RUN wget -qO Miniconda3-latest-Linux-x86_64.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda3 && \
    rm Miniconda3-latest-Linux-x86_64.sh && \
    echo "source /root/miniconda3/bin/activate" >> ~/.bashrc

# 创建 Conda 环境并安装依赖
RUN /bin/bash -c "source /root/miniconda3/bin/activate && \
    conda create -n MinerU python=3.10 -y && \
    conda activate MinerU && \
    pip install magic-pdf[full]==0.7.0b1 --extra-index-url https://wheels.myhloli.com -i https://pypi.tuna.tsinghua.edu.cn/simple"

# 克隆 Git LFS 仓库并安装 Git LFS
RUN git lfs install && \
    git clone https://github.com/opendatalab/MinerU.git

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
        "device-mode": "cuda", \
        "table-config": { \
            "is_table_recog_enable": false, \
            "max_time": 400 \
        } \
    }' > /root/magic-pdf.json

# 下载测试文件，出错时跳过
RUN wget https://gitee.com/myhloli/MinerU/raw/master/demo/small_ocr.pdf -O /PDF-Extract-Kit/small_ocr.pdf || true

# 建立挂载卷
RUN mkdir /PDF-Extract-Kit

# 设置默认工作目录
WORKDIR /PDF-Extract-Kit

# 执行容器时默认激活 conda 环境
CMD ["bash"]