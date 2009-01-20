# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A command-pattern framework that is used to power WebWork as well as other applications"
HOMEPAGE="http://opensymphony.com/xwork/"
SRC_URI="https://${PN}.dev.java.net/files/documents/709/28621/${P}.zip"

LICENSE="OpenSymphony-1.1"
SLOT="1.1"
KEYWORDS=""
IUSE="doc java5 source"

DEPEND="java5? ( >=virtual/jdk-1.5 )
	!java5? ( >=virtual/jdk-1.4 )
	app-arch/unzip"
RDEPEND="java5? ( >=virtual/jre-1.5 )
	!java5? ( >=virtual/jre-1.4 )
	=dev-java/ognl-2.6*
	=dev-java/oscore-2.2*
	dev-java/rife-continuations
	dev-java/commons-logging
	=dev-java/commons-attributes-2*
	=dev-java/cglib-2.0*
	=dev-java/spring-1.2*"

S="${WORKDIR}"


src_unpack() {
	unpack ${A}
	cd "${S}"

	rm *.jar
	cd lib
	rm -r *
	java-pkg_jar-from ognl-2.6
	java-pkg_jar-from oscore-2.2
	java-pkg_jar-from rife-continuations
	java-pkg_jar-from commons-logging
	java-pkg_jar-from commons-attributes-2
	java-pkg_jar-from dom4j-1
	java-pkg_jar-from cglib-2 cglib.jar
	for jar in core aop web beans context; do
		java-pkg_jar-from spring spring-${jar}.jar
	done
}

src_compile() {
	local antflags="-Dskip.ivy=false jar"
	use java5 && antflags="${antflags} tiger"
	eant ${antflags} $(use_doc javadocs)
}

src_install() {
	java-pkg_newjar build/${P}.jar ${PN}.jar
	use java5 && java-pkg_newjar build/${PN}-tiger-${PV}.jar ${PN}-tiger.jar
	use doc && java-pkg_dohtml -r dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
