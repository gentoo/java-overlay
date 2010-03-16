# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

JAVA_ANT_REWRITE_CLASSPATH="yes"
JAVA_ANT_CLASSPATH_TAGS="javac javadoc"
JAVA_PKG_IUSE="doc source"

inherit versionator java-pkg-2 java-ant-2

MY_PV="$(replace_all_version_separators -)"

DESCRIPTION="Saxon - The XSLT and XQuery Processor"
HOMEPAGE="http://saxon.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}he${MY_PV}source.zip"

LICENSE="MPL-1.0"
# do not interfere with old releases
SLOT="9"
KEYWORDS="~amd64 ~x86"

IUSE=""

# sub-optimal, but o well:
#
# if you change the jdk and/or jdom slots
# update their javadoc links in build.xml!
CDEPEND="dev-java/ant-core
	dev-java/dom4j:1
	dev-java/jdom:1.0
	dev-java/xom"
RDEPEND=">=virtual/jre-1.6
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.6
	app-arch/unzip
	${CDEPEND}"

S="${WORKDIR}"

EANT_GENTOO_CLASSPATH="ant-core,dom4j-1,jdom-1.0,xom"
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

	# copy data
	for f in build.xml; do # manpages: ${PN}.1 ${PN}q.1; do
		cp -v "${FILESDIR}/${version}-${f}" "${S}/${f}"
	done
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

	# manual
	#doman *.1
}
