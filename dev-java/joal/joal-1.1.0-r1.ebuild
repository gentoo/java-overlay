# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_ANT_TASKS="ant-antlr"
JAVA_PKG_IUSE="doc"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java binding for OpenAL API"
HOMEPAGE="https://joal.dev.java.net/"
SRC_URI="http://download.java.net/media/${PN}/builds/archive/${PV}/${P}-src.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="media-libs/openal
		dev-java/gluegen"
DEPEND="${CDEPEND}
		>=virtual/jdk-1.4
		>=dev-java/ant-core-1.5
		dev-java/antlr
		app-arch/unzip"
RDEPEND="${CDEPEND}
		>=virtual/jre-1.4"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}/${PF}-build.xml.patch"

	java-ant_rewrite-classpath gluegen/make/build.xml
	cd "${S}"
	mkdir make/lib/linux-amd64
}

src_compile() {
	cd make/ || die "Unable to enter make directory"
	local antflags="-Dantlr.jar=$(java-pkg_getjars antlr)"
	local gcp="$(java-pkg_getjars ant-core):$(java-config --tools)"
	local gluegen="-Dgluegen.jar=$(java-pkg_getjar gluegen gluegen.jar)"
	local gluegen_rt="-Dgluegen-rt.jar=$(java-pkg_getjar gluegen 'gluegen-rt.jar')"

	eant -Djoal.lib.dir=/usr "${antflags}" \
		-Dgentoo.classpath="${gcp}" "${gluegen}" "${gluegen_rt}" \
		declare jar c.build.joal $(use_doc javadoc)
}

src_install() {
	java-pkg_dojar build/*.jar
	use_doc && java-pkg_dojavadoc javadoc_public
	java-pkg_doso build/obj/*.so
}

