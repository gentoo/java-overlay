# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"
JAVA_PKG_IUSE="doc source"
inherit base java-pkg-2 java-ant-2

DESCRIPTION="MusicXML library for Java"
HOMEPAGE="https://proxymusic.dev.java.net/"
SRC_URI="https://proxymusic.dev.java.net/files/documents/6330/137402/${PN}-core.zip"
LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RDEPEND=">=virtual/jre-1.5"

DEPEND=">=virtual/jdk-1.6
	test? ( dev-java/junit:4 )"

S="${WORKDIR}/src"
EANT_BUILD_TARGET="build"

pkg_setup() {
	EANT_EXTRA_ARGS="-Dbuild.compile.source=$(java-pkg_get-source) -Djavac.target=$(java-pkg_get-target)"
}

src_prepare() {
	# This isn't Windows!
	sed -i "s/xjc\.exe/xjc/g" build-epilog.xml || die
}

src_install() {
	java-pkg_newjar "../dist/${P}.jar" "${PN}.jar"
	use doc && java-pkg_dojavadoc ../build/javadoc
	use source && java-pkg_dosrc main/*
	dohtml ../www/*.html || die
}

src_test() {
	eant -Djunit.jar="$(java-pkg_getjar junit-4 junit.jar)" test-all
}
