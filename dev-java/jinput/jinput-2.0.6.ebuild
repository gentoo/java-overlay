# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# svn export https://svn.java.net/svn/jinput~svn/trunk jinput-r${REV}
# rm -r jinput-r${REV}/lib/*
# tar Jcf jinput-r${REV}{.tar.xz,}

REV="247"
MY_P="${PN}-r${REV}"

EAPI="4"
WANT_ANT_TASKS="ant-nodeps"
JAVA_PKG_IUSE="source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="An implementation of an API for game controller discovery and polled input"
HOMEPAGE="https://jinput.dev.java.net"
SRC_URI="http://dev.gentooexperimental.org/~chewi/distfiles/${MY_P}.tar.xz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.4
	dev-java/jutils"

RDEPEND=">=virtual/jre-1.4
	dev-java/jutils"

S="${WORKDIR}/${MY_P}"

JAVA_PKG_BSFIX="off"
EANT_BUILD_TARGET="dist"

src_prepare() {
	java-pkg_jar-from --into lib jutils

	epatch "${FILESDIR}/jinput-remove-getDeviceUsageBits.patch" # http://java.net/jira/browse/JINPUT-44
	epatch "${FILESDIR}/jinput-javah-classpath.patch" # http://java.net/jira/browse/JINPUT-45

	sed -i \
		-e "s/-O[0-9]/${CFLAGS} ${LDFLAGS}/g" \
		-e '/<apply .*executable="strip"/,/<\/apply>/d' \
		plugins/linux/src/native/build.xml || die
}

src_install() {
	java-pkg_dojar dist/jinput.jar
	java-pkg_doso dist/*.so

	use source && java-pkg_dosrc */src/java/* */**/src/java/*
}
