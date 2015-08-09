# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Core library for Paul Lamb's 3D Sound System"
HOMEPAGE="http://www.paulscode.com/forum/index.php?topic=4.0"
SRC_URI="http://www.paulscode.com/source/SoundSystem/${PV:6:2}JAN${PV:0:4}/SoundSystem.zip -> ${P}.zip"
LICENSE="paulscode-SoundSystem"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5
	app-arch/unzip"

S="${WORKDIR}/src"
