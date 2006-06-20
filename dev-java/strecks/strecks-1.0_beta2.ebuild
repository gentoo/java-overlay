# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PV="${PV//_beta/-beta-}"
MY_P="${PN}-${MY_PV}"
DESCRIPTION="A set of extensions to the Struts web development framework aimed at Java 5 users."
HOMEPAGE="http://strecks.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}-src.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

COMMON_DEPEND="
	=dev-java/spring-1*
	dev-java/poi
	=dev-java/commons-beanutils-1.7*
	dev-java/commons-digester
	dev-java/commons-logging
	dev-java/commons-validator
	=dev-java/jakarta-oro-2.0*
	=dev-java/struts-1.2*
	~dev-java/servletapi-2.4 "
DEPEND=">=virtual/jdk-1.5
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"

S="${WORKDIR}"

ant_src_unpack() {
	unpack ${A}
	cd lib/extension
	rm *.jar
	java-pkg_jar-from spring spring.jar
	java-pkg_jar-from poi

	cd ../runtime
	rm *.jar
	java-pkg_jar-from commons-beanutils-1.7
	java-pkg_jar-from commons-digester
	java-pkg_jar-from commons-logging
	java-pkg_jar-from commons-validator
	java-pkg_jar-from jakarta-oro-2.0
	java-pkg_jar-from struts-1.2

	cd ../support
	rm *.jar
	java-pkg_jar-from servletapi-2.4
}

src_compile() {
	eant jar $(use_doc javadocs)
}

src_install() {
	java-pkg_newjar dist/${MY_P}.jar ${PN}.jar
	
	use doc && java-pkg_dojavadocs dist/javadocs
	use source && java-pkg_dosrc framework/src/java
}
