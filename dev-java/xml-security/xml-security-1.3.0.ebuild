# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PV=${PV//./_}
MY_P=${PN}-${MY_PV}

DESCRIPTION="The XML Security project is aimed at providing implementation of
security standards for XML."
HOMEPAGE="http://xml.apache.org/security/Java/index.html"
SRC_URI="http://xml.apache.org/security/dist/java-library/xml-security-src-${MY_PV}.zip"

LICENSE="Apache-2.0"
SLOT="1.3"
KEYWORDS="~x86"
IUSE="doc examples"

# TODO check if junit is only needed at buildtime
RDEPEND=">=virtual/jre-1.4
	dev-java/commons-logging
	dev-java/log4j
	=dev-java/xml-commons-external-1.3*
	dev-java/xalan
	>=dev-java/xerces-2.7
	dev-java/bcprov
	dev-java/junit"

DEPEND="${RDEPEND}
		>=virtual/jdk-1.4
		app-arch/unzip"

COMMONS_LOGGING="commons-logging commons-logging.jar"
COMMONS_LOGGING_API="commons-logging commons-logging-api.jar"
LOG4J="log4j log4j.jar"
XALAN="xalan xalan.jar"
XML_APIS="xml-commons-external-1.3 xml-apis.jar"
XERCES_IMPL="xerces-2 xercesImpl.jar"
JCE="bcprov bcprov.jar"
JUNIT="junit junit.jar"
S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}

	cd ${S}

	echo lib.logging=`java-pkg_getjar ${COMMONS_LOGGING}` > build.properties
	echo lib.logging-api=`java-pkg_getjar ${COMMONS_LOGGING_API}` >> build.properties
	echo lib.log4j=`java-pkg_getjar ${LOG4J}` >> build.properties
	echo lib.xalan.1=`java-pkg_getjar ${XALAN}` >> build.properties
	echo lib.xalan.2=`java-pkg_getjar ${XML_APIS}` >> build.properties
	echo lib.xerces.1=`java-pkg_getjar ${XERCES_IMPL}` >> build.properties
	echo lib.jce=`java-pkg_getjar ${JCE}` >> build.properties
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} -Ddir.build.javadoc=./build/docs/html/api javadoc"
	eant ${antflags} || die "Compile failed"
}

src_install() {
	for jar in xmlsec xmlsecTests; do
		java-pkg_newjar build/${jar}-${PV}.jar ${jar}.jar
	done

	if use examples; then
		dodir "/usr/share/doc/${PF}/examples"
		cp -r xmlsecSamples-${PV}.jar "${D}/usr/share/doc/${PF}/examples/xmlsecSamples-.jar"\
			|| die "cp failed"
	fi

	dodoc INSTALL KEYS NOTICE README TODO
	dohtml Readme.html
	use doc && java-pkg_dohtml -r build/docs/html/api
}
