FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# The value of TORCH_CUDA_ARCH_LIST should be changed according to your GPU type.
# Please refer to the following for setting values.
# https://developer.nvidia.com/cuda-gpus#compute
ENV TORCH_CUDA_ARCH_LIST=6.1

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
ENV FORCE_CUDA="1"
ENV CUDA_VISIBLE_DEVICES=0

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y libglib2.0-0 wget build-essential libbz2-dev libdb-dev libreadline-dev libffi-dev libgdbm-dev liblzma-dev libncursesw5-dev libsqlite3-dev libssl-dev zlib1g-dev uuid-dev tk-dev git g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tgz && \
    tar xzf Python-3.10.6.tgz && \
    cd Python-3.10.6 && \
    ./configure && make && make install && \
    pip3 install torch==1.12.1+cu113 torchvision==0.13.1+cu113 --extra-index-url https://download.pytorch.org/whl/cu113 && \
    pip3 install transformers==4.19.2 diffusers invisible-watermark --prefer-binary && \
    pip3 install git+https://github.com/TencentARC/GFPGAN.git@8d2447a2d918f8eba5a4a01463fd48e45126a379 --prefer-binary && \
    pip3 install git+https://github.com/openai/CLIP.git@d50d76daa670286dd6cacf3bcd80b5e4823fc8e1 --prefer-binary && \
    pip3 install -U numpy  --prefer-binary

# AUTOMATIC111 clone & setup
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui && \
    cd stable-diffusion-webui && \
    ln -s /mnt/outputs outputs && \
    mkdir repositories && \
    git clone https://github.com/facebookresearch/xformers.git repositories/xformers && cd repositories/xformers && git submodule update --init --recursive && pip3 install -r requirements.txt && pip3 install -e . && cd /stable-diffusion-webui && \
    pip3 install git+https://github.com/KichangKim/DeepDanbooru.git@edf73df4cdaeea2cf00e9ac08bd8a9026b7a7b26#egg=deepdanbooru[tensorflow] tensorflow==2.10.0 tensorflow-io==0.27.0 && \
    git clone https://github.com/CompVis/stable-diffusion.git repositories/stable-diffusion && \
    git clone https://github.com/CompVis/taming-transformers.git repositories/taming-transformers && \
    git clone https://github.com/crowsonkb/k-diffusion.git repositories/k-diffusion && \
    git clone https://github.com/sczhou/CodeFormer.git repositories/CodeFormer && cd repositories/CodeFormer && git checkout c5b4593074ba6214284d6acd5f1719b6c5d739af && cd /stable-diffusion-webui && \
    git clone https://github.com/salesforce/BLIP.git repositories/BLIP && cd repositories/BLIP && git checkout 48211a1594f1321b00f14c9f7a5b4813144b2fb9 && cd /stable-diffusion-webui && \
    pip3 install -r repositories/CodeFormer/requirements.txt --prefer-binary && \
    pip3 install -r repositories/k-diffusion/requirements.txt --prefer-binary && \
    pip3 install -r requirements.txt  --prefer-binary && \
    mkdir /stable-diffusion-webui/models/SwinIR && \
    wget --quiet https://github.com/JingyunLiang/SwinIR/releases/download/v0.0/003_realSR_BSRGAN_DFOWMFC_s64w8_SwinIR-L_x4_GAN.pth -O /stable-diffusion-webui/models/SwinIR/003_realSR_BSRGAN_DFOWMFC_s64w8_SwinIR-L_x4_GAN.pth && \
    wget --quiet https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth -O /stable-diffusion-webui/GFPGANv1.3.pth

# ckpt download
RUN wget --quiet https://huggingface.co/crumb/pruned-waifu-diffusion/resolve/main/model-pruned.ckpt -O /stable-diffusion-webui/models/Stable-diffusion/wd-v1-2.ckpt && \
    wget --quiet https://huggingface.co/hakurei/waifu-diffusion-v1-3/resolve/main/wd-v1-3-float32.ckpt -O /stable-diffusion-webui/models/Stable-diffusion/wd-v1-3-float32.ckpt && \
    wget --quiet https://www.googleapis.com/storage/v1/b/aai-blog-files/o/sd-v1-4.ckpt?alt=media -O /stable-diffusion-webui/models/Stable-diffusion/sd_model.ckpt

EXPOSE 7860

COPY ./entrypoint.sh /
ENTRYPOINT /entrypoint.sh
