# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="The Google Data APIs (GData) provide a simple protocol for reading and writing data on the web"
HOMEPAGE="http://code.google.com/p/gdata-java-client/"
SRC_URI="http://${PN}-java-client.googlecode.com/files/${PN}-src.java-${PV}.zip"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/guava:0
	dev-java/jsr305:0
	java-virtuals/jaf:0
	java-virtuals/javamail:0
	java-virtuals/jdk-with-com-sun:0"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"

DEPEND="${CDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.5"

S="${WORKDIR}/${PN}/java"

JAVA_PKG_BSFIX="no"
JAVA_ANT_REWRITE_CLASSPATH="yes"

EANT_BUILD_XML="build-src.xml"
EANT_BUILD_TARGET="all"
EANT_DOC_TARGET=""
EANT_NEEDS_TOOLS="yes"
EANT_GENTOO_CLASSPATH="guava jaf javamail jsr305"
EANT_EXTRA_ARGS="-Dactivation.jar= -Dmail.jar="

java_prepare() {
	# Make this work with Guava instead of Google Collections.
	sed -i "s/ImmutableMultimap/ImmutableListMultimap/g" \
		src/com/google/gdata/util/common/net/UriParameterMap.java || die

	# Delete bundled JARs.
	find -iname "*.jar" -delete || die

	# Fix all the build files.
	java-ant_bsfix_files build-src.xml build-src/*.xml
}

src_install() {
	dodoc ../INSTALL-src.txt ../README-src.txt ../RELEASE_NOTES.txt

	use doc && java-pkg_dojavadoc doc
	use source && java-pkg_dosrc src/*

	local JAR
	cd lib || die

	for JAR in *.jar; do
		java-pkg_newjar "${JAR}" "${JAR%-*}.jar"
	done
}
