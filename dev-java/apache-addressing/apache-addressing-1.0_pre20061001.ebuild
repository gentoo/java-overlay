# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/asm/asm-2.0-r1.ebuild,v 1.2 2006/07/22 21:26:56 nelchael Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Apache Addressing is an implementation of the Web Services Addressing (WS-Addressing), published by the IBM, Microsoft and BEA as a joint specification, on top of Apache Axis (The Next Generation SOAP)."
HOMEPAGE="http://ws.apache.org/ws-fx/addressing/"
SRC_URI="http://dev.gentoo.org/~caster/distfiles/${P}.tar.bz2"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

COMMON_DEPS=">=www-servers/axis-1.2.1
	dev-java/wsdl4j
	>=dev-java/commons-discovery-0.2
	>=dev-java/commons-logging-1.0.4"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	source? ( app-arch/zip )
	${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPS}"

src_unpack() {
	unpack ${A}

	cp ${FILESDIR}/${P}-build.xml ${S}/build.xml

	mkdir -p ${S}/target/lib && cd ${S}/target/lib
	java-pkg_jar-from axis-1
	java-pkg_jar-from wsdl4j
	java-pkg_jar-from commons-discovery
	java-pkg_jar-from commons-logging commons-logging.jar
}

src_compile() {
	eant jar $(use_doc javadoc)
}

src_install() {
	java-pkg_dojar target/addressing.jar
	use doc && java-pkg_dohtml -r output/dist/doc/javadoc/user/*
	use source && java-pkg_dosrc src/*
}

