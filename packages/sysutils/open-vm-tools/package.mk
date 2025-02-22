# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2011 Anthony Nash (nash.ant@gmail.com)
# Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="open-vm-tools"
PKG_VERSION="12.1.0"
PKG_SHA256="4c867a3f8b6c636eb98c9faa76c4280b0fdb75e2923dc0deec77dd24dd3f43b1"
PKG_ARCH="x86_64"
[ "${DISTRO}" = "Lakka" ] && PKG_ARCH+=" i386" || true
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/vmware/open-vm-tools"
PKG_URL="https://github.com/vmware/open-vm-tools/archive/stable-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain fuse glib:host glib libdnet libtirpc"
PKG_LONGDESC="open-vm-tools: open source implementation of VMware Tools"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--disable-docs \
                           --disable-tests \
                           --disable-containerinfo \
                           --disable-deploypkg \
                           --without-pam \
                           --without-gtk2 \
                           --without-gtkmm \
                           --without-ssl \
                           --without-x \
                           --without-xerces \
                           --without-icu \
                           --without-kernel-modules \
                           --with-udev-rules-dir=/usr/lib/udev/rules.d/ \
                           --with-sysroot=${SYSROOT_PREFIX}"

configure_package() {
  PKG_CONFIGURE_SCRIPT="${PKG_BUILD}/open-vm-tools/configure"
}

post_unpack() {
  # Hack to allow package to be bumped without linking against old libraries
  rm -f ${SYSROOT_PREFIX}/usr/lib/libvmtools*
}

pre_configure_target() {
  export LIBS="-ldnet -ltirpc"
}

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/sbin
  rm -rf ${INSTALL}/usr/share
  rm -rf ${INSTALL}/etc/vmware-tools/scripts/vmware/network

  chmod -x ${INSTALL}/usr/lib/udev/rules.d/*.rules

  find ${INSTALL}/etc/vmware-tools/ -type f | xargs sed -i '/.*expr.*/d'
}

post_install() {
  enable_service vmtoolsd.service
  enable_service vmware-vmblock-fuse.service
}
