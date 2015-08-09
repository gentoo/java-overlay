# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2

DESCRIPTION="Java Image Processing Classes"
HOMEPAGE="http://www.jhlabs.com/ip/filters/ https://pixels.dev.java.net/"
MY_S="pixels-core-${PV}-SNAPSHOT"
SRC_ID="58509"
SRC_URI="https://pixels.dev.java.net/files/documents/6500/${SRC_ID}/${MY_S}-bin.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND=">=virtual/jdk-1.4
		app-arch/unzip"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${MY_S}"

src_unpack() {
	unpack "${A}"
	mkdir "${S}/src"
	cd "${S}/src"
	# unpack nested sources jar
	jar -x${JAVA_PKG_DEBUG+v}f "${S}/${MY_S}-sources.jar"
}

src_compile() {
	# create jar
	mkdir bin
	ejavac -sourcepath src -d bin $(find -name "*.java") || die "Cannot compile sources"
	mkdir dist
	jar -c${JAVA_PKG_DEBUG+v}f "${S}/dist/${PN}.jar" -C bin . || die "Cannot create JAR"

	# generate javadoc
	if use doc ; then
		cd "${S}"
		mkdir javadoc
		javadoc -d javadoc -sourcepath src -subpackages com
	fi
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use source && java-pkg_dosrc src/com
	use doc && java-pkg_dojavadoc javadoc
}
