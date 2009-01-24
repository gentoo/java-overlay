# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="JasperReports is a powerful report-generating tool."
HOMEPAGE="http://jasperreports.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-project.zip"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="doc source"

# MISSING PACKAGES
# commons-javaflow
# mondrian
# png-encoder

COMMONDEP="
	>=dev-java/ant-core-1.5.1
	>=dev-java/antlr-2.7.5
	>=dev-java/asm-3.0
	>=dev-java/commons-beanutils-1.7
	>=dev-java/commons-collections-2.1
	>=dev-java/commons-digester-1.7
	>=dev-java/commons-logging-1.0.4
	=dev-java/eclipse-ecj-3.1*
	dev-java/glassfish-persistence
	>=dev-java/groovy-1.0_beta10
	>=dev-java/hibernate-3.2
	>=dev-java/itext-1.3.1
	>=dev-java/jcommon-1.0.0
	>=dev-java/jexcelapi-2.6
	>=dev-java/jfreechart-1.0.0
	>=dev-java/poi-2.0
	=dev-java/servletapi-2.3*
"
DEPEND=">=virtual/jdk-1.4
	>=app-arch/unzip-5.50
	${COMMONDEP}"
RDEPEND=">=virtual/jre-1.4
	${COMMONDEP}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	rm -fr "${S}/dist/*.jar"
	rm -fr "${S}/lib/*.jar"

	cd "${S}/lib"
	java-pkg_jar-from ant-core ant.jar
	java-pkg_jar-from antlr
	java-pkg_jar-from asm-3 asm.jar
	java-pkg_jar-from commons-beanutils-1.7
	java-pkg_jar-from commons-collections
	java-pkg_jar-from commons-digester
	java-pkg_jar-from commons-logging commons-logging.jar
	java-pkg_jar-from eclipse-ecj-3.1
	java-pkg_jar-from glassfish-persistence
	java-pkg_jar-from groovy-1
	java-pkg_jar-from hibernate-3.2 hibernate3.jar
	java-pkg_jar-from itext iText.jar
	java-pkg_jar-from jcommon-1.0
	java-pkg_jar-from jexcelapi-2.5
	java-pkg_jar-from jfreechart-1.0
	java-pkg_jar-from poi poi.jar
	java-pkg_jar-from xalan xalan.jar
	java-pkg_jar-from servletapi-2.4
}

src_compile() {
	# we need clean here because it seems to be already compiled
	eant clean jar ${use_doc}
}

src_install() {
	java-pkg_newjar dist/${P}.jar ${PN}.jar
	java-pkg_newjar dist/${P}-applet.jar ${PN}-applet.jar

	use doc && java-pkg_dohtml -r docs/*
	use source && java-pkg_dosrc src/*
}
