# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

# prepare eclass variables
JAVA_ANT_REWRITE_CLASSPATH="yes"
JAVA_ANT_CLASSPATH_TAGS="javac javadoc"
JAVA_PKG_IUSE="doc source"

inherit versionator java-pkg-2 java-ant-2

# fix tarball version string
MY_PV="$(replace_all_version_separators -)"

# virtual/jdk slot for external javadoc
JDK_VER="6"

# dev-java/jdom slot for external javadoc
JDOM_VER="1.0"

# dev-java/dom4j slot
DOM4J_VER="1"

DESCRIPTION="Saxon - The XSLT and XQuery Processor"
HOMEPAGE="http://saxon.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}he${MY_PV}source.zip"

LICENSE="MPL-1.0"
# do not interfere with old releases
SLOT="9"
KEYWORDS="~amd64 ~x86"

IUSE=""

CDEPEND="dev-java/ant-core
	dev-java/dom4j:${DOM4J_VER}
	dev-java/jdom:${JDOM_VER}
	dev-java/xom"
RDEPEND=">=virtual/jre-1.${JDK_VER}
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.${JDK_VER}
	app-arch/unzip
	${CDEPEND}"

S="${WORKDIR}"

EANT_GENTOO_CLASSPATH="ant-core,dom4j-${DOM4J_VER},jdom-${JDOM_VER},xom"
EANT_BUILD_TARGET="jar"
EANT_DOC_TARGET="javadoc"

src_unpack() {
	# <major>.<minor> version
	local version="$(get_version_component_range 1-2)"

	# unpack
	unpack "${A}"

	### fedora remove

	# deadNET
	rm -rv net/sf/saxon/dotnet

	# Depends on XQJ (javax.xml.xquery)
	rm -rv net/sf/saxon/xqj

	# This requires a EE edition feature (com.saxonica.xsltextn)
	rm -v net/sf/saxon/option/sql/SQLElementFactory.java

	### end

	# generate build.xml with external javadoc links
	sed -e "s:@JDK@:${JDK_VER}:" \
		-e "s:@JDOM@:${JDOM_VER}:" \
		< "${FILESDIR}/${version}-build.xml" \
		> "${S}/build.xml" \
		|| die "build.xml generation failed!"
}

java_prepare() {
	# <major>.<minor> version
	local version="$(get_version_component_range 1-2)"

	# prepare
	eant prepare

	# properties
	cp -v \
		"${FILESDIR}/${version}-edition.properties" \
		"${S}/build/classes/edition.properties"
}

src_install() {
	java-pkg_dojar build/lib/"${PN}.jar"

	# launcher
	java-pkg_dolauncher ${PN}${SLOT}-transform --main net.sf.saxon.Transform
	java-pkg_dolauncher ${PN}${SLOT}-query --main net.sf.saxon.Query

	# api
	use doc && java-pkg_dojavadoc build/api

	# source
	use source && java-pkg_dosrc src
}
