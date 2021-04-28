FROM ubuntu

MAINTAINER Santiago Millan Gonzalez <santiago.millang@udc.es>

#
# Install pre-requistes
#
COPY tophat-2.1.0.Linux_x86_64.tar.gz /data/tophat-2.1.0.Linux_x86_64.tar.gz

RUN apt-get update --fix-missing && \
  apt-get install -q -y samtools python && \
  apt-get install -y wget && \
  apt-get install -y unzip && \
  apt-get install -y python3-pip && \
  apt-get install -y openjdk-8-jre && \
  apt-get install -y fastqc 
#
# RNA-Seq tools 
# 

RUN wget -q -O bowtie.zip https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.7/bowtie2-2.2.7-linux-x86_64.zip/download && \
  unzip bowtie.zip -d /opt/ && \
  ln -s /opt/bowtie2-2.2.7/ /opt/bowtie && \
  rm bowtie.zip 

RUN \
  cd /data && \
  tar -zxvf tophat-2.1.0.Linux_x86_64.tar.gz -C /opt/ && \
  ln -s /opt/tophat-2.1.0.Linux_x86_64/ /opt/tophat
  
RUN \
  wget -q http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz -O- \
  | tar -xz -C /opt/ && \
  ln -s /opt/cufflinks-2.2.1.Linux_x86_64/ /opt/cufflinks

RUN \
  pip3 install multiqc
   
#
# Finalize environment
#
ENV PATH=$PATH:/opt/bowtie:/opt/tophat:/opt/cufflinks
