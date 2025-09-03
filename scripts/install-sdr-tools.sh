#!/bin/bash
#
# Author  : Gaston Gonzalez
# Date    : 4 June 2025
# Purpose : Install SDR tools
set -e

et-log "Installing SDR tools..."
apt install \
  rtl-sdr \
  librtlsdr-dev \
  -y

. ./env.sh

APP=rtl-sdr
REPO_SRC_DIR="${ET_SRC_DIR}/${APP}"

[[ ! -e ${ET_SRC_DIR} ]] && mkdir ${ET_SRC_DIR}

CWD_DIR=`pwd`

et-log "Installing ${APP} build dependencies..."
apt purge ^librtlsdr -y
rm -rvf /usr/lib/librtlsdr* /usr/include/rtl-sdr* /usr/local/lib/librtlsdr* /usr/local/include/rtl-sdr* /usr/local/include/rtl_* /usr/local/bin/rtl_*

apt-get install \
    libusb-1.0-0-dev \
    git \
    cmake \
    pkg-config \
    -y

et-log "Cloning ${APP} repository..."
if [[ ! -e ${REPO_SRC_DIR} ]]; then
  cd ${ET_SRC_DIR} && git clone ${REPO}
fi

cd ${REPO_SRC_DIR}

et-log "Building ${APP}..."
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON
make
make install
cp ../rtl-sdr.rules /etc/udev/rules.d/
ldconfig

echo 'blacklist dvb_usb_rtl28xxu' | tee --append /etc/modprobe.d/blacklist-dvb_usb_rtl28xxu.conf

cd ${CWD_DIR}
