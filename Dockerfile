FROM tensorflow/tensorflow:2.4.2-gpu

# correct errors of CUDA GPG key
RUN rm /etc/apt/sources.list.d/cuda.list \
    && rm /etc/apt/sources.list.d/nvidia-ml.list \
    && apt-key del 7fa2af80 \
    && apt-get update && apt-get install -y --no-install-recommends wget \
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb \
    && dpkg -i cuda-keyring_1.0-1_all.deb

# System packages.
RUN apt-get update && apt-get install -y \
  ffmpeg \
  libgl1-mesa-dev \
  python3-pip \
  unrar \
  wget \
  git \
  libosmesa6-dev \
  libgl1-mesa-glx \
  libglfw3 \
  patchelf \
  htop \
  nano \
  tmux \
  && apt-get clean

# Miniconda
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh

# MuJoCo.
ENV MUJOCO_GL egl
ENV MUJOCO_RENDERER egl
RUN mkdir -p /root/.mujoco && \
  wget -nv https://www.roboti.us/download/mujoco200_linux.zip -O mujoco.zip && \
  unzip mujoco.zip -d /root/.mujoco && \
  rm mujoco.zip
RUN cp -r /root/.mujoco/mujoco200_linux /root/.mujoco/mujoco200
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/root/.mujoco/mujoco200/bin

# MuJoCo key.
RUN wget https://www.roboti.us/file/mjkey.txt \
    && mv mjkey.txt /root/.mujoco/

# Lexa environment
RUN git clone https://github.com/orybkin/lexa-benchmark.git
RUN git clone https://github.com/arkoll/lexa.git
RUN conda env create -f lexa/environment.yml

ENV PYTHONPATH=/lexa/lexa:/lexa-benchmark
ENV CUDA_VISIBLE_DEVICES 0
WORKDIR /lexa/lexa
