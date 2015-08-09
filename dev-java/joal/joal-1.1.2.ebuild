# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"

WANT_ANT_TASKS="ant-antlr"
JAVA_PKG_IUSE="doc test"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java binding for OpenAL API"
HOMEPAGE="https://joal.dev.java.net/"
SRC_URI="http://download.java.net/media/joal/builds/archive/${PV}/${P}-src.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="media-libs/openal:0
		dev-java/gluegen:0"
DEPEND=">=virtual/jdk-1.4
		dev-java/antlr:0
		app-arch/unzip
		${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
		${CDEPEND}"

S="${WORKDIR}/${PN}"

java_prepare() {
	epatch "${FILESDIR}/${PF}-build.xml.patch"

	mkdir make/lib/linux-amd64
}

src_compile() {
	cd make/ || die "Unable to enter make directory"
	local antflags="-Dantlr.jar=$(java-pkg_getjars --build-only antlr)"
	local gcp="$(java-config --tools)"
	local gluegen="-Dgluegen.jar=$(java-pkg_getjar gluegen gluegen.jar)"
	local gluegen_rt="-Dgluegen-rt.jar=$(java-pkg_getjar gluegen 'gluegen-rt.jar')"

	eant -Djoal.lib.dir=/usr "${antflags}" \
		-Dgentoo.classpath="${gcp}" "${gluegen}" "${gluegen_rt}" \
		declare jar c.build.joal $(use_doc javadoc)
}

src_install() {
	#Another jar is also created, that contains
	#the generated shared library. We shouldn't need it.
	java-pkg_dojar build/${PN}.jar
	use_doc && java-pkg_dojavadoc javadoc_public
	java-pkg_doso build/obj/*.so
}

