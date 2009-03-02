# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
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
	dev-java/apple-java-extensions-bin:0
	dev-java/itext
	dev-java/j3d-core:0
	dev-java/java3dsloader:0
	dev-java/vecmath:0
	amd64? (
	    =app-emulation/emul-linux-x86-java-1.5*:1.5
	)"

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
	rm -frv lib/* || die "Cannot remove files in lib directory"
	rm -frv libtest/*.jar || die "Cannot remove files in libtest directory"

	# add dependencies into the lib dir
	cd "${S}"/lib || die "Cannot cd to lib directory"
	java-pkg_jar-from j3d-core
	java-pkg_jar-from java3dsloader
	java-pkg_jar-from itext iText.jar
	java-pkg_jar-from vecmath
	cd "${S}"/libtest || die "Cannot cd to libtest directory"
	java-pkg_jar-from apple-java-extensions-bin

	if use amd64 ; then
		einfo "Symlinking javaws.jar to libtest dir"
		ln -s /usr/lib/jvm/emul-linux-x86-java-1.5/lib/javaws.jar jnlp.jar || die
	fi
}

src_install() {
	java-pkg_dojar "${S}"/build/*.jar

	# I don't know how to do it better
	# (do not copy javaws.jar, use it from its original location)
	if use amd64; then
		java-pkg_dojar /usr/lib/jvm/emul-linux-x86-java-1.5/lib/javaws.jar
	else
		java-pkg_dojar "${JAVA_HOME}/jre/lib/javaws.jar"
	fi

	# create SweetHome3D wrapper script
	java-pkg_dolauncher ${MY_PN} --main com.eteks.sweethome3d.SweetHome3D \
		-Djava.library.path=/usr/$(get_libdir)/${PN} -Xmx256m
}
