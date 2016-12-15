FROM ubuntu:14.04

MAINTAINER Nirmal Prasad "nirmalp@valyoo.in"

# Install java8
RUN apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:webupd8team/java && \
  (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  apt-get clean && \
  rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Deps
RUN dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get install -y --force-yes expect git wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl libqt5widgets5 libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386 libsdl1.2debian:i386 && \
  apt-get clean && \
  rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install vnc, xvfb in order to create a 'fake' display and firefox
RUN apt-get update && \
  apt-get install -y x11vnc xvfb firefox && \
  mkdir ~/.vnc && \
  apt-get clean && \
  rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup a password
RUN x11vnc -storepasswd 1234 ~/.vnc/passwd

# Autostart firefox (might not be the best way to do it, but it does the trick)
RUN bash -c 'echo "firefox" >> /.bashrc'

# Copy install tools
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

# Install Android SDK
RUN cd /opt && \
  wget --output-document=android-sdk.tgz http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \
  tar xzf android-sdk.tgz && \
  rm -f android-sdk.tgz && \
  chown -R root.root android-sdk-linux && \
  /opt/tools/android-accept-licenses.sh "android-sdk-linux/tools/android update sdk --all --no-ui --filter platform-tools,tools,build-tools-24.0.3,build-tools-24.0.1,build-tools-22.0.1,android-24,android-23,android-22,extra-android-support,extra-android-m2repository,extra-google-m2repository,sys-img-x86_64-android-24,sys-img-x86-android-24,sys-img-arm64-v8a-android-24,sys-img-armeabi-v7a-android-24,sys-img-armeabi-v7a-android-22"

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN which adb
RUN which android

# Create emulator
RUN echo "no" | android create avd --force --device "Nexus 5" --name Nexus_5_armeabi-v7a --target android-24 --abi armeabi-v7a --skin WVGA800 --sdcard 512M
RUN echo "no" | android create avd --force --device "Nexus 5" --name Nexus_5_arm64-v8a --target android-24 --abi arm64-v8a --skin WVGA800 --sdcard 512M
RUN echo "no" | android create avd --force --device "Nexus 5" --name Nexus_5_x86 --target android-24 --abi x86 --skin WVGA800 --sdcard 512M
RUN echo "no" | android create avd --force --device "Nexus 5" --name Nexus_5_x86_64 --target android-24 --abi x86_64 --skin WVGA800 --sdcard 512M
RUN echo "no" | android create avd --force --device "Nexus 5" --name Nexus_5_22_armeabi-v7a --target android-22 --abi armeabi-v7a --skin WVGA800 --sdcard 512M

# Cleaning
RUN apt-get clean
