#!/bin/bash
set -x
set -e

# Diees Script erzeugt ein rust bindings file für paho mqtt für armv5te, welcher im dvf99 verwendet wird.
# Es wird eine installierte rust-lang-Umgebung benötigt, sowie ein mit yocto übersetztes paho mqtt c.
# Das AGFEO docker build image hub.agfeo.de:4567/builder/yocto-thud enthaält die entsprechende Buildumgebung.
# Es kann dazu benutzt werden manuell das bindings file zu erzeugen.
# ggf- müssen die nachstehenden Variablen angepasst werden!
# siehe auch https://gitlab.agfeo.de/mirror/paho.mqtt.rust#rust-c-bindings

# TARGET wird für bindgen benötigt, um die entsprechende zielarchitektur zu bestimmen.
export TARGET=armv5te-unknown-linux-gnueabi

# Pfad der bereits übersetzten paho mqtt c lib für das target
YOCTO_BUILD_DIR="/home/builder/workspace/build.t2xsip"
YOCTO_PAHO_MQTT_C_DIR="tmp/work/armv5te-dspg-linux-gnueabi/paho-mqtt-c/1.3.2-r0"

# Name des zu erzegenden bindings file
TARGET_BINDINGS_FILE="bindings_paho_mqtt_c_1.3.2-${TARGET}.rs"

# TMPDIR=$(mktemp -d)
BASEDIR=$(dirname $(cd ${0%/*} && echo $PWD/${0##*/}))
DSTDIR="${BASEDIR}/paho-mqtt-sys/bindings"

#cd $TMPDIR
#git clone git@gitlab.agfeo.de:mirror/paho.mqtt.rust.git

cd paho.mqtt.rust
#git checkout tags/v0.7.1

cd paho-mqtt-sys
bindgen wrapper.h -o ${DSTDIR}/${TARGET_BINDINGS_FILE} -- \
    -Ipaho.mqtt.c/src \
    -I${YOCTO_BUILD_DIR}/${YOCTO_PAHO_MQTT_C_DIR}/sysroot-destdir/usr/include \
    -I${YOCTO_BUILD_DIR}/${YOCTO_PAHO_MQTT_C_DIR}/recipe-sysroot/usr/include

cat ${DSTDIR}/${TARGET_BINDINGS_FILE}
echo "### bindings file: ${DSTDIR}/${TARGET_BINDINGS_FILE}"
