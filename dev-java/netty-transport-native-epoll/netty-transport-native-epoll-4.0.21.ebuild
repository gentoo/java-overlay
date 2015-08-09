# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
JAVA_PKG_IUSE="doc source"

inherit multilib toolchain-funcs java-pkg-2 java-pkg-simple

MY_PN="netty"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Native Netty transport for Linux using JNI"
HOMEPAGE="http://netty.io/wiki/native-transports.html"
SRC_URI="https://github.com/${MY_PN}/${MY_PN}/archive/${MY_P}.Final.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/${MY_PN}-buffer:0
	dev-java/${MY_PN}-common:0
	~dev-java/${MY_PN}-transport-${PV}:0"

RDEPEND=">=virtual/jre-1.6
	${CDEPEND}"

DEPEND=">=virtual/jdk-1.6
	${CDEPEND}"

S="${WORKDIR}/${MY_PN}-${MY_P}.Final/${PN/${MY_PN}-}/src"
JAVA_SRC_DIR="main/java"
JAVA_GENTOO_CLASSPATH="${MY_PN}-buffer,${MY_PN}-common,${MY_PN}-transport"

src_compile() {
	mkdir -p target/classes/META-INF/native || die
	$(tc-getCC) -shared -fPIC -Wall -Wl,-z -Wl,defs ${CFLAGS} ${LDFLAGS} $(java-pkg_get-jni-cflags) main/c/*.c -o "target/classes/META-INF/native/lib${PN}$(get_libname)" || die
	java-pkg-simple_src_compile
}
