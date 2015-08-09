# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="JOrbis codec plug-in for Paul Lamb's 3D Sound System"
HOMEPAGE="http://www.paulscode.com/forum/index.php?topic=4.0"
SRC_URI="http://www.paulscode.com/source/SoundSystem/${PV:6:2}NOV${PV:0:4}/CodecJOrbis.zip -> ${P}.zip"
LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/paulscode-soundsystem:0
	dev-java/jorbis:0"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.5
	app-arch/unzip"

S="${WORKDIR}/src"
JAVA_GENTOO_CLASSPATH="paulscode-soundsystem,jorbis"

java_prepare() {
	# Remove JOrbis sources.
	rm -rv com || die
}
