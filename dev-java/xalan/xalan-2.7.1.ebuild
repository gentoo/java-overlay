# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2 eutils versionator

MY_PN="${PN}-j"
MY_PV="$(replace_all_version_separators _)"
MY_P="${MY_PN}_${MY_PV}"
DESCRIPTION="Apache's XSLT processor for transforming XML documents into HTML, text, or other XML document types."
HOMEPAGE="http://xml.apache.org/xalan-j/index.html"
SRC_URI="mirror://apache/xml/${MY_PN}/source/${MY_P}-src.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc source"

COMMON_DEP="
	dev-java/javacup
	dev-java/bcel
	>=dev-java/xerces-2.7.1
	=dev-java/xml-commons-external-1.3*
	~dev-java/xalan-serializer-${PV}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# disable building of serializer.jar
	sed -i -e 's/depends="prepare,serializer.jar"/depends="prepare"/' \
		build.xml || die "sed build.xml failed"

	# remove the serializer sources as well
	find src/org/apache/xml/serializer -name "*.java" -delete || die

	# remove bundled jars and packed sources
	rm -v lib/*.jar tools/*.jar src/*.tar.gz || die
	cd lib || die
	java-pkg_jar-from xml-commons-external-1.3 xml-apis.jar
	java-pkg_jar-from xerces-2 xercesImpl.jar
	java-pkg_jar-from javacup javacup.jar java_cup.jar
	java-pkg_jar-from javacup javacup.jar runtime.jar
	java-pkg_jar-from bcel bcel.jar BCEL.jar

	mkdir -p "${S}/build" || die
	java-pkg_jar-from --into "${S}/build" xalan-serializer serializer.jar
}

# When version bumping Xalan make sure that the installed jar
# does not bundle .class files from dependencies
src_compile() {
	eant jar \
		-Dxsltc.bcel_jar.not_needed=true \
		-Dxsltc.runtime_jar.not_needed=true \
		-Dxsltc.regexp_jar.not_needed=true

	use doc && eant autojavadocs
}

src_install() {
	java-pkg_dojar build/${PN}.jar
	# installs symlinks to the file in /usr/share/xalan-serializer
	java-pkg_dojar build/serializer.jar
	# and records it to package.env as if it belongs to this one's
	# classpath, for maximum possible backward compatibility
	java-pkg_regjar $(java-pkg_getjar xalan-serializer serializer.jar)

	java-pkg_dolauncher ${PN} --main org.apache.xalan.xslt.Process

	dohtml readme.html || die
	use doc && java-pkg_dojavadoc build/docs/apidocs
	use source && java-pkg_dosrc src/org
}
