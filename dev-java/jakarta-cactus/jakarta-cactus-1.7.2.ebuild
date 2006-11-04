# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit java-pkg-2 java-ant-2

DESCRIPTION="Cactus is a simple test framework for unit testing server-side java code (Servlets, EJBs, Tag Libs, Filters, ...)."
HOMEPAGE="http://jakarta.apache.org/cactus/"
SRC_URI="mirror://apache/jakarta/cactus/source/${PN}-src-${PV}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

COMMON_DEPEND="
	>=dev-java/aspectj-1.2
	=dev-java/commons-httpclient-2*
	>=dev-java/commons-logging-1.0.3
	=dev-java/junit-3.8*
	=dev-java/sun-j2ee-1.3*
	"
DEPEND="=virtual/jdk-1.4*
	app-arch/unzip
	dev-java/ant-core
	source? ( app-arch/zip )
	${COMMON_DEPEND}"
RDEPEND="=virtual/jre-1.4*
	${COMMON_DEPEND}"

S="${WORKDIR}/${PN}-src-${PV}"
JAVA_PKG_BSFIX="off"

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${P}-gentoo.patch
	cp ${FILESDIR}/${P}-build.properties ${S}/build.properties

	mkdir ${S}/lib && cd ${S}/lib
	java-pkg_jar-from aspectj aspectjrt.jar
	java-pkg_jar-from aspectj aspectjtools.jar aspectj-tools.jar
	java-pkg_jar-from commons-httpclient
	java-pkg_jar-from commons-logging commons-logging.jar
	java-pkg_jar-from junit
	java-pkg_jar-from sun-j2ee-1.3 j2ee.jar j2ee-1.3.jar
}

src_compile() {
	cd ${S}/framework
	eant jar $(use_doc doc)
}

src_install() {
	java-pkg_newjar framework/target-13/cactus-${PV}.jar ${PN}.jar

	dodoc README
	java-pkg_dohtml *.html
	use doc && java-pkg_dohtml -r framework/target-13/doc/api
	use source && java-pkg_dosrc framework/src/java/*
}
