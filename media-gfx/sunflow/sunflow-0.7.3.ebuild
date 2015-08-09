# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="3"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple eutils

DESCRIPTION="A rendering system for photo-realistic image synthesis."
HOMEPAGE="http://sunflow.sourceforge.net/"
SRC_URI="http://www.polyquark.com/opensource/download/binariesAndSources.zip -> ${P}.zip"
IUSE=""
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
S="${WORKDIR}"

COMMON_DEP="dev-java/janino:0"

RDEPEND=">=virtual/jre-1.5
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	${COMMON_DEP}"

JAVA_GENTOO_CLASSPATH="janino"
JAVA_SRC_DIR="src"

src_install() {
	java-pkg-simple_src_install

	java-pkg_dolauncher ${PN} --java_args "-Xmx1g" --main SunflowGUI
	make_desktop_entry ${PN} "Sunflow" {PN} Graphics
}
