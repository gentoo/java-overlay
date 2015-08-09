# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"
inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Java3D 3DS FileLoader"
HOMEPAGE="http://sourceforge.net/projects/java3dsloader/"
SRC_URI="mirror://sourceforge/java3dsloader/Loader3DS${PV/./_}src.jar"
LICENSE="LGPL-2"
IUSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="
	dev-java/j3d-core:0
	dev-java/vecmath:0"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEPEND}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}

	# copy new build.xml
	cp -f "${FILESDIR}/build-${PV}.xml" build.xml

	# create directory for dependencies
	mkdir lib
	cd lib

	# add dependencies into the lib dir
	java-pkg_jar-from j3d-core
	java-pkg_jar-from vecmath
}

src_install() {
	java-pkg_dojar "${S}/target/loader3ds.jar"
}
