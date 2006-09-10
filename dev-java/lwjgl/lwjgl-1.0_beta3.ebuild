# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 versionator eutils
# svn export
# https://svn.sourceforge.net/svnroot/java-game-lib/tags/lwjgl1.0beta3 lwjgl-1.0_beta3/
# rm www/*
# tar -cf lwjgl-1.0_beta3.tar lwjgl-1.0_beta3/ && gzip lwjgl-1.0_beta3.tar

# ogl/oal = required
# <Mazon> fmod, devil = optional
# <Mazon> jinput is req too
#  Xrandr, Xxf86vm and Xcursor
#  build requires apt within sun-jdk-1.5*
MY_PV="$(delete_version_separator 2)"
DESCRIPTION="The Lightweigth Java Game Library (LWJGL)"
HOMEPAGE="http://www.lwjgl.org"
SRC_URI="http://www.counties.co.nz/alistair/distfiles/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc devil"

CDEPEND="virtual/opengl
		media-libs/openal
		dev-java/jinput
		dev-java/jutils
		devil? ( media-libs/devil )"
DEPEND=">=virtual/jdk-1.5
		>=dev-java/ant-core-1.5
		${CDEPEND}"
RDEPEND=">=virtual/jre-1.5
		${CDEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/fix-linux-build.patch #FIXED in next version :)
	eant clean clean-generated
	
	#lets do some something that should be in done in ant
	#mkdir bin
	rm -r libs/*
	mkdir libs/linux
	cd libs
	java-pkg_jarfrom jinput
	java-pkg_jarfrom jutils
	cd linux

}

src_compile() {
	eant -Djava.home=`java-config -o` generate-all all $(use_doc javadoc)
}

src_install() {
	cd libs
	java-pkg_dojar lwjgl.jar lwjgl_util.jar
	use devil && java-pkg_dojar lwjgl_devil.jar
	if use amd64; then
		cp linux/liblwjgl64.so linux/liblwjgl.so
	fi
	java-pkg_doso linux/liblwjgl.so
	if use_doc; then
		cd ${S}/doc
		mv javadoc api
		java-pkg_dohtml -r api
	fi
}
