# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit eutils java-pkg-2 java-ant-2

MY_PN="SweetHome3D"

DESCRIPTION="Sweet Home 3D is a free interior design application."
HOMEPAGE="http://${PN}.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_PN}-${PV}-src.zip"
LICENSE="GPL-3"
IUSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="
	>=dev-java/apple-java-extensions-bin-1.5:0
	dev-java/freehep-graphics2d:0
	dev-java/freehep-graphicsio:0
	dev-java/freehep-graphicsio-svg:0
	dev-java/freehep-util:0
	dev-java/itext:0
	dev-java/j3d-core:0
	dev-java/java3dsloader:0
	dev-java/jmf-bin:0
	dev-java/vecmath:0"
#	>=media-gfx/sunflow-0.7.3e:0

DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	${COMMON_DEPEND}"

RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}-src"

EANT_BUILD_TARGET="build furniture textures help"

src_unpack() {
	unpack ${A}

	cd "${S}" || die "Can not change directory to ${S}"

	# clean lib directory
	# keeping sunflow*jar as we do not have any replacement for it for now
	cp lib/sunflow*.jar "${T}" || die
	rm -frv lib/* || die "Cannot remove files in lib directory"
	rm -frv libtest/*.jar || die "Cannot remove files in libtest directory"
	cp "${T}"/sunflow*.jar lib/ || die

	# add dependencies into the lib dir
	cd "${S}"/lib || die "Cannot cd to lib directory"
	java-pkg_jar-from freehep-graphics2d
	java-pkg_jar-from freehep-graphicsio
	java-pkg_jar-from freehep-graphicsio-svg
	java-pkg_jar-from freehep-util
	java-pkg_jar-from itext iText.jar
	java-pkg_jar-from j3d-core
	java-pkg_jar-from java3dsloader
	java-pkg_jar-from jmf-bin
	#java-pkg_jar-from sunflow
	java-pkg_jar-from vecmath
	cd "${S}"/libtest || die "Cannot cd to libtest directory"
	java-pkg_jar-from apple-java-extensions-bin
}

src_install() {
	java-pkg_dojar build/*.jar
	java-pkg_newjar lib/sunflow*.jar sunflow.jar

	# create SweetHome3D wrapper script
	java-pkg_dolauncher ${MY_PN} --main com.eteks.sweethome3d.SweetHome3D \
		-Djava.library.path=/usr/$(get_libdir)/${PN} -Xmx256m
}
