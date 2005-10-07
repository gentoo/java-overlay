# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

# TODO use versionator
MY_PV=${PV//./_}
MY_P=${PN}-${MY_PV}

# TODO find a description. Doesn't seem to be any on website.
DESCRIPTION=""
HOMEPAGE="http://xml.apache.org/security/Java/index.html"
SRC_URI="http://xml.apache.org/security/dist/java-library/xml-security-src-1_2_1.zip"

LICENSE="Apache-2.0"
SLOT="1.2"
KEYWORDS="~x86"
IUSE="jikes doc"

# TODO check if junit is only needed at buildtime
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? (dev-java/jikes)
	app-arch/unzip"
RDEPEND=">=virtual/jre-1.4
	dev-java/commons-logging
	dev-java/log4j
	dev-java/xalan
	=dev-java/xerces-2*
	dev-java/bcprov
	dev-java/junit"
#	dev-java/ant-clover-bin"

COMMONS_LOGGING="commons-logging commons-logging.jar"
COMMONS_LOGGING_API="commons-logging commons-logging-api.jar"
LOG4J="log4j log4j.jar"
XALAN="xalan xalan.jar"
XML_APIS="xerces-2 xml-apis.jar"
XERCES_IMPL="xerces-2 xercesImpl.jar"
JCE="bcprov bcprov.jar"
JUNIT="junit junit.jar"
CLOVER="clover-ant-bin clover.jar"
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
#	echo lib.clover=`java-pkg_getjar ${CLOVER}` >> build.properties
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} -Ddir.build.javadoc=./build/docs/html/api javadoc"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"

	ant ${antflags} || die "Compile failed"
}

src_install() {
	# TODO install samples based on use flag
	for jar in xmlsec xmlsecSamples xmlsecTests; do
		java-pkg_newjar build/${jar}-${PV}.jar ${jar}.jar
	done

	dodoc INSTALL KEYS NOTICE README TODO
	dohtml Readme.html
	use doc && java-pkg_dohtml -r build/docs/html/api
}
