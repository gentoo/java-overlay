# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

# Uses the javah task.
WANT_ANT_TASKS="ant-nodeps"
JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="The Lightweight Java Game Library (LWJGL)"
HOMEPAGE="http://www.lwjgl.org"
SRC_URI="mirror://sourceforge/java-game-lib/${PN}-source-${PV}.zip"
LICENSE="BSD"
SLOT="2.6"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/apple-java-extensions-bin
	dev-java/apt-mirror
	dev-java/jinput
	dev-java/jutils
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXrandr
	x11-libs/libXxf86vm"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.5
	x11-proto/xproto"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5
	media-libs/openal
	virtual/opengl"

S="${WORKDIR}"

JAVA_PKG_BSFIX_NAME="build.xml build-generator.xml"
JAVA_ANT_REWRITE_CLASSPATH="true"

EANT_GENTOO_CLASSPATH="apple-java-extensions-bin apt-mirror jinput jutils"
EANT_BUILD_TARGET="all"

src_prepare() {
	# libXext isn't actually needed. Respect CFLAGS and LDFLAGS. Don't
	# prestrip. Gentoo doesn't have a static version of libXxf86vm.
	sed -i \
		-e 's/-lXext//g' \
		-e "s/-O[0-9]/${CFLAGS} ${LDFLAGS}/g" \
		-e '/<apply .*executable="strip"/,/<\/apply>/d' \
		-e "s/-Wl,-static,-lXxf86vm,-call_shared/-lXxf86vm/g" \
		platform_build/linux_ant/build.xml || die
}

src_install() {
	java-pkg_dojar libs/lwjgl*jar
	java-pkg_doso libs/linux/*.so

	use doc && java-pkg_dojavadoc doc/javadoc
	use source && java-pkg_dosrc src/java/org
}
