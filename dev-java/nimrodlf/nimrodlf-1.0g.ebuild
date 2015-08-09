# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="NimROD Look and Feel."
HOMEPAGE="http://personales.ya.com/nimrod/"
SRC_URI="http://personales.ya.com/nimrod/data/${PN}-src-${PV}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"

S="${WORKDIR}/${PN}-src-${PV}"

EANT_BUILD_TARGET="hazjar"

src_install() {
	java-pkg_dojar "dist/${PN}.jar"
	use source && java-pkg_dosrc src/*
}

