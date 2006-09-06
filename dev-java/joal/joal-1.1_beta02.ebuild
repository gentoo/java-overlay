# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java binding for OpenAL API"
HOMEPAGE="https://joal.dev.java.net/"
SRC_URI="http://www.counties.co.nz/alistair/distfiles/${P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

CDEPEND="media-libs/openal"
DEPEND="${CDEPEND}
		>=virtual/jdk-1.4
		>=dev-java/ant-core-1.5*
		>=dev-java/junit-3.8*
		dev-java/antlr
		app-arch/unzip"
RDEPEND="${CDEPEND}
		>=virtual/jre-1.4"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd ${S}
	mkdir make/lib/linux-amd64
}

src_compile() {
	cd make/
	local antflags="-Dantlr.jar=$(java-pkg_getjars antlr) -Djoal.lib.dir=/usr"
	use doc && docs="javadoc"
	eant ${antflags} all $(use_doc javadoc) || die "Failed to compile"
}

src_install() {
	cd ${S}

	if use doc; then
		mv javadoc_public api
		java-pkg_dohtml -r api
	fi
	java-pkg_doso build/obj/*.so
}

src_test() {
	eant runtest
}

