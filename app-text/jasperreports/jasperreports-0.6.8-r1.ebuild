# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="JasperReports is a powerful report-generating tool that has the ability to deliver rich content onto the screen, to the printer or into PDF, HTML, XLS, CSV and XML files."
HOMEPAGE="http://jasperreports.sourceforge.net/"
SRC_URI="mirror://sourceforge/jasperreports/${P}-project.zip"
LICENSE="LGPL-2.1"
SLOT="0.6"
KEYWORDS="~amd64 ~x86"
IUSE="doc"
COMMON_DEPEND="=dev-java/itext-1.3*
	>=dev-java/bsh-1.99
	=dev-java/commons-beanutils-1.6*
	>=dev-java/commons-collections-3.1
	>=dev-java/commons-digester-1.5
	>=dev-java/commons-logging-1.0.4
	dev-db/hsqldb
	>=dev-java/poi-2
	~dev-java/servletapi-2.3
	>=dev-java/xalan-2.5.2
	=dev-java/eclipse-ecj-3.1*
	=dev-java/xerces-2*
	=dev-java/xml-commons-external-1.3*"
DEPEND=">=virtual/jdk-1.4
	>=app-arch/unzip-5.50
	>=dev-java/ant-core-1.4
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
	${COMMMON_DEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-eclipse-3.1.patch

	cd ${S}/lib
	rm -f *.jar

	java-pkg_jar-from itext iText.jar
	java-pkg_jar-from bsh bsh.jar
	java-pkg_jar-from commons-beanutils-1.6
	java-pkg_jar-from commons-collections
	java-pkg_jar-from commons-digester
	java-pkg_jar-from commons-logging
	java-pkg_jar-from hsqldb hsqldb.jar
	java-pkg_jar-from poi poi.jar
	java-pkg_jar-from servletapi-2.3
	java-pkg_jar-from eclipse-ecj-3.1
	java-pkg_jar-from xalan
	java-pkg_jar-from xerces-2 xercesImpl.jar
	java-pkg_jar-from xml-commons-external-1.3
	java-pkg_jar-from ant-core ant.jar
}

src_compile() {
	# we need clean here because it seems to be already compiled
	eant clean jar $(use_doc docs)
#	antflags="${antflags} -lib /usr/lib/eclipse-3/plugins/org.eclipse.jdt.core_3.0.1/jdtcore.jar"
#	antflags="${antflags} -lib $(java-pkg_getjar poi poi.jar)"
}

src_install() {
	java-pkg_newjar dist/${P}.jar ${PN}.jar
	java-pkg_newjar dist/${P}-applet.jar ${PN}-applet.jar

	use doc && java-pkg_dohtml -r docs/*
}
