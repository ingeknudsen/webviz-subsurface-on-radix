FROM python:3.7.5

RUN pip install webviz-config
RUN pip install webviz-subsurface

RUN apt-get update 
RUN apt-get install -y sudo

#Download AzCopy
RUN wget https://aka.ms/downloadazcopy-v10-linux

#Expand Archive
RUN tar -xvf downloadazcopy-v10-linux

#Move AzCopy to the destination you want to store it
RUN sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

RUN pip install ecl
RUN pip install webviz-config-equinor