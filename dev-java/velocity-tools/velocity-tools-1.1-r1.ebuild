# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc"
inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="A collection of Velocity subprojects with a common goal of creating tools and infrastructure for building both web and non-web applications using the Velocity template engine."
HOMEPAGE="http://jakarta.apache.org/velocity/tools/"
SRC_URI="http://archive.apache.org/dist/jakarta/${PN}/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
COMMON_DEPEND="
=dev-java/commons-beanutils-1.6*
dev-java/commons-collections
dev-java/commons-digester
dev-java/commons-logging
dev-java/commons-validator
=dev-java/dom4j-1*
dev-java/dvsl
=dev-java/jaxen-1.1*
=dev-java/servletapi-2.3*
=dev-java/struts-1.1*
=dev-java/struts-sslext-1.1*
dev-java/velocity
dev-java/dvsl
"
DEPEND=">=virtual/jdk-1.4
${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
${COMMON_DEPEND}"

EANT_GENTOO_CLASSPATH="
commons-beanutils-1.6
commons-collections
commons-digester
commons-logging
commons-validator
dom4j-1
jaxen-1.1
servletapi-2.3
struts-1.1
struts-sslext-1.1
velocity
dvsl
"
EANT_DOC_TARGET="javadoc"
EANT_EXTRA_ARGS="-Dproject.name=${PN}"
EANT_BUILD_TARGET="jar.struts jar.view jar.generic"

src_unpack() {
	mkdir "${S}" || die
	cd "${S}" || die
	unpack ${A}

	rm "${S}"/lib/*.jar || die

	java-ant_rewrite-classpath "${S}/build.xml"

}

src_install() {
	java-pkg_newjar dist/${P}.jar ${PN}.jar
	java-pkg_newjar dist/${PN}-generic-${PV}.jar ${PN}-generic.jar
	java-pkg_newjar dist/${PN}-view-${PV}.jar ${PN}-view.jar

	use doc && java-pkg_dojavadoc "${S}/docs/javadoc"
}
