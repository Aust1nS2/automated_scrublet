FROM mambaorg/micromamba:latest

# need to do this becuase micromamba switched the default user to not be root which makes it impossible to update or install stuff to the the image with apt-get
USER root

#ENV PATH=/opt/conda/bin:$PATH
SHELL ["/bin/bash","-l", "-c"]

WORKDIR /code
ENV SETUP_HOME=/code
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive

#RUN apt-get update --fix-missing && apt-get install -y software-properties-common python3-launchpadlib 
    #apt-cache search openjdk-8 >&2 && \
#RUN add-apt-repository -y ppa:openjdk-r/ppa 
#RUN add-apt-repository -y ppa:webupd8team/java
#RUN apt-get update
#RUN apt-get install -y autotools-dev automake cmake curl grep sed dpkg \
#    #fuse zip openjdk-11-jre pkg-config python3 python3-dev python3-pip vim \
#    fuse zip openjdk-8-jdk pkg-config vim \
#    wget bzip2 build-essential sudo \
#    ca-certificates git libglib2.0-0 libxext6 libsm6 \
#    libxrender1 mercurial subversion \
#    zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
#    libssl-dev libreadline-dev libffi-dev libsqlite3-dev \
#    libbz2-dev liblzma-dev libcurl3-dev checkinstall \
#    less unzip unrar-free tar gzip && \
#    apt-get clean

RUN apt-get update --fix-missing && \
    apt-get install -y autotools-dev automake cmake curl grep sed dpkg \
    #fuse zip openjdk-11-jre pkg-config python3 python3-dev python3-pip vim \
    fuse zip openjdk-17-jdk pkg-config vim \
    wget bzip2 build-essential sudo \
    ca-certificates git libglib2.0-0 libxext6 libsm6 \
    libxrender1 mercurial subversion \
    zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
    libssl-dev libreadline-dev libffi-dev libsqlite3-dev \
    libbz2-dev liblzma-dev libcurl3-dev checkinstall \
    software-properties-common less unzip unrar-free tar gzip && \
    apt-get clean
COPY . /code/.

# do not need to figure out  which version of python is present because this is intended for R.
# RUN which python >&2
#
# do not need since you are starting with an env that has appropriate python (not needed)
#RUN conda update -n base -c defaults conda
#RUN echo "python 3.11.*" > /opt/conda/conda-meta/pinned
#
#
#if you were setting up outside of the base env then do the following to create clone of env 
#RUN conda create -n ggplotGATK -y --file r4.3.2_seurat5.0.1_CosMx1.2.2_Xenium_spec_file_20240301_163320.txt
# starting by just installing the necessary R base and packages in the base env.
#
RUN micromamba env update --file /code/docker/py3.9_docker_20250207.yml && micromamba clean
# not needed because we are not using conda build  
#RUN echo "python 3.11.*" > /opt/conda/conda-meta/pinned
#COPY /diskmnt/Projects/Users/austins2/software/anaconda3/conda-bld/linux-64/r-seuratdisk-0.0.0.9021-r43_0.tar.bz2 /opt/conda/conda-bld/linux-64/.
#SHELL ["conda", "run", "-n", "seurat5", "/bin/bash", "-c"]
#SHELL ["/bin/bash", "--login", "-c"]
# do not need because this image is not building inside of the image.
#RUN conda create -n building -y conda-build
#RUN conda install -n building -y conda-build
#RUN conda run --no-capture-output -n building conda skeleton cran https://github.com/Aust1nS2/seurat-disk
#RUN conda run --no-capture-output -n building conda build --R=4.3.2 r-seurat-disk
#RUN conda install -n seurat5 -y /opt/conda/conda-bld/linux-64/r-seuratdisk-0.0.0.9021-r43_0.tar.bz2
#RUN conda install -n seurat5 -y /code/r-seuratdisk-0.0.0.9021-r43_0.tar.bz2
#
#
# we are installing packages directly into the base environment here so we do not need to do the following I think.
#RUN echo "conda activate base" >> ~/.bashrc && cp ~/.bashrc /code/bashrc
#ENV PATH=/opt/conda/bin:$PATH
#ENV PATH="/opt/conda/envs/base/bin:$PATH"
#SHELL ["conda", "run", "--no-capture-output", "-n", "base", "/bin/bash", "-c"]
# switched to useing micromamba instead of conda base image since I can install whatever verson of python I want in it.
# in the docker image the micromamba executable is located at /usr/bin/micromamba
RUN echo "micromamba activate base" >> ~/.bashrc && cp ~/.bashrc /code/bashrc
ENV PATH=/usr/bin/micromamba:$PATH
ENV PATH=/opt/conda/bin:$PATH
#RUN echo "LOOK AT ME LOOK AT ME LOOK AT ME LOOK AT ME LOOK AT ME LOOK AT ME LOOK AT ME" >&2
#RUN which python >&2
# ENV PATH="/opt/conda/envs/base/bin:$PATH" If you are only using the base environment with micromamba then everything is isntalled in the /opt/conda/bin folder
# /opt/conda/envs/ is only created if you install an environment named something other than "base"
SHELL ["micromamba", "run", "--no-capture-output", "-n", "base", "/bin/bash", "-c"]

# USER mambauser

# the following is for if we are building and I never fully got it working.
#RUN /opt/conda/bin/python3.11 conda skeleton cran https://github.com/Aust1nS2/seurat-disk
#RUN /opt/conda/bin/python3.11 conda build --R=4.3.2 r-seurat-disk
#RUN /opt/conda/bin/python3.11 conda install -y /opt/conda/conda-bld/linux-64/r-seuratdisk-0.0.0.9021-r43_0.tar.bz2
#ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "myenv", "python", "run.py"]
