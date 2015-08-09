# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit eutils java-pkg-2 java-ant-2

MY_PN="TuxGuitar-alsa"

DESCRIPTION="ALSA plugin for TuxGuitar"
HOMEPAGE="http://www.herac.com.ar/soluciones/tuxguitar.htm"
SRC_URI="mirror://sourceforge/tuxguitar/${MY_PN}-${PV}-src.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64"

RDEPEND=">=virtual/jre-1.5
	 	dev-java/swt
	 	>=media-sound/tuxguitar-0.8"
DEPEND=">=virtual/jdk-1.5
		dev-java/ant-core
		sys-devel/gcc
		${RDEPEND}"

IUSE=""

S="${WORKDIR}/${MY_PN}-${PV}-src"

src_unpack() {
	unpack ${A}

	SWT_JAR_PATH=$(java-pkg_getjar swt-3 swt.jar)
	TUXGUITAR_JAR_PATH=$(java-pkg_getjar tuxguitar TuxGuitar.jar)

	echo "swt.jar=${SWT_JAR_PATH}" > ${S}/build.properties
	echo "tuxguitar.jar=${TUXGUITAR_JAR_PATH}" >> ${S}/build.properties
}

src_compile() {
	cd "${S}/src"
	gcc -shared jni_ReceiverJNI.c -o libReceiverJNI.so -lasound \
	    -I/usr/lib/jvm/${GENTOO_VM}/include/ \
	    -I/usr/lib/jvm/${GENTOO_VM}/include/linux/

	cd "${S}"
	eant
}

src_install() {
	TUXGUITAR_INST_PATH=$(dirname $(java-pkg_getjar tuxguitar TuxGuitar.jar))

	dodir ${TUXGUITAR_INST_PATH}/lib
	dodir ${TUXGUITAR_INST_PATH}/share/plugins

	insinto ${TUXGUITAR_INST_PATH}/lib
	doins TuxGuitar-alsa.jar
	doins src/libReceiverJNI.so

	insinto ${TUXGUITAR_INST_PATH}/share/plugins
	doins plugin_tuxguitar-alsa.properties
}
