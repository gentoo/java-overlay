# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"
REV="c8d01bc1b0b2fe34cfd45a08d66c499222caf423"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java preprocessor with cpp-like syntax and Ant support"
HOMEPAGE="http://www.slashdev.ca/${PN}/"
SRC_URI="http://git.slashdev.ca/${PN}/snapshot/${PN}-${REV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/ant-core:0
	dev-java/jython:2.5"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"

DEPEND="${CDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.5"

S="${WORKDIR}/${PN}-${REV}"

JAVA_ANT_REWRITE_CLASSPATH="yes"
EANT_BUILD_TARGET="build"
EANT_GENTOO_CLASSPATH="ant-core jython-2.5"
JYTHON_LIB="/usr/share/jython-2.5/Lib"

src_unpack() {
	default_src_unpack

	mkdir -p "${S}/deps/plex" || die
	cd "${S}/deps/plex" || die
	unpack ./../plex-*.zip
}

java_prepare() {
	sed \
		-e '/ant\.library\.dir/d' \
		-e '/<copy [^>]* \/>/d' \
		-e '/<copy /,/<\/copy>/d' \
		-i build.xml || die

	mkdir -p build/Lib || die
	ln -snf "${S}"/src/python/* "${S}"/deps/plex/Plex build/Lib/ || die
}

src_install() {
	java-pkg_dojar "${PN}.jar"
	java-pkg_addcp "${JYTHON_LIB}"
	dodoc AUTHORS CHANGELOG CREDITS README
}

src_test() {
	ANT_TASKS="jython-2.5" CLASSPATH="${JYTHON_LIB}" eant test
}
