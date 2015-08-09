# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="A rendering system for photo-realistic image synthesis."
HOMEPAGE="http://sunflow.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-src/v${PV}/${PN}-src-v${PV}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

COMMON_DEP="dev-java/janino:0"

RDEPEND=">=virtual/jre-1.5
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	${COMMON_DEP}"

S="${WORKDIR}/${PN}"

java_prepare() {
	java-pkg_jar-from janino janino.jar
}

EANT_BUILD_TARGET="jars"

src_install() {
	java-pkg_dojar "release/${PN}.jar"
	use doc && java-pkg_dojavadoc release/javadoc
	use source && java-pkg_dosrc src/*

	mv resources/golden_0040.png "resources/${PN}.png"
	doicon "resources/${PN}.png"

	java-pkg_dolauncher ${PN} --java_args "-Xmx1g" --main SunflowGUI
	make_desktop_entry ${PN} "Sunflow" "${PN}.png" Graphics
}

