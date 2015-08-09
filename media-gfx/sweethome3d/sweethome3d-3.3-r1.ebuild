# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="3"
inherit eutils java-pkg-2 java-ant-2 java-pkg-simple

MY_PN="SweetHome3D"

DESCRIPTION="Sweet Home 3D is a free interior design application."
HOMEPAGE="http://${PN}.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_PN}-${PV}-src.zip
	http://dev.gentoo.org/~fordfrog/distfiles/${PN}.png
	http://www.polyquark.com/opensource/download/binariesAndSources.zip -> sunflow-0.7.3.zip"
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
	dev-java/janino:0
	dev-java/java3dsloader:0
	dev-java/jmf-bin:0
	dev-java/jnlp-api
	dev-java/vecmath:0"

DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	${COMMON_DEPEND}"

RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}-src"
SUNFLOW_PATCH="sunflow-0.07.3g-src-diff"

# sunflow variables
JAVA_GENTOO_CLASSPATH="janino"
JAVA_SRC_DIR="${WORKDIR}/${SUNFLOW_PATCH}/src"

# sweethome variables
EANT_BUILD_TARGET="build furniture textures help"

src_unpack() {
	unpack ${MY_PN}-${PV}-src.zip

	# prepare modified sources of sunflow
	mkdir ${SUNFLOW_PATCH} || die
	pushd ${SUNFLOW_PATCH} >/dev/null || die
	unpack sunflow-0.7.3.zip
	popd >/dev/null || die
	unpack ./SweetHome3D-${PV}-src/${SUNFLOW_PATCH}.zip

	einfo "Removing bundled jars..."
	find -name "*.jar" -type f | xargs rm -v
}

java_prepare() {
	# add dependencies into the lib dir
	pushd "${S}"/lib >/dev/null || die
	java-pkg_jar-from freehep-graphics2d
	java-pkg_jar-from freehep-graphicsio
	java-pkg_jar-from freehep-graphicsio-svg
	java-pkg_jar-from freehep-util
	java-pkg_jar-from itext iText.jar
	java-pkg_jar-from j3d-core
	java-pkg_jar-from java3dsloader
	java-pkg_jar-from jmf-bin
	java-pkg_jar-from jnlp-api
	java-pkg_jar-from vecmath
	popd >/dev/null || die
	pushd "${S}"/libtest >/dev/null || die
	java-pkg_jar-from apple-java-extensions-bin
	popd >/dev/null || die

	# add dependency for sunflow
	java-pkg_jar-from --into "${WORKDIR}"/${SUNFLOW_PATCH} janino
}

src_compile() {
	# to prevent QA warning, renaming build.xml for a while
	mv build.xml build.xml.bak || die

	# compile and link sunflow
	java-pkg-simple_src_compile
	mv "${S}"/${PN}.jar "${S}"/lib/sunflow.jar || die

	# rename build.xml back
	mv build.xml.bak build.xml || die

	java-pkg-2_src_compile
}

src_install() {
	java-pkg_dojar build/*.jar
	java-pkg_dojar lib/sunflow.jar

	# create SweetHome3D wrapper script
	java-pkg_dolauncher ${MY_PN} --main com.eteks.sweethome3d.SweetHome3D \
		-Djava.library.path=/usr/$(get_libdir)/${PN} -Xmx256m

	doicon "${DISTDIR}"/${PN}.png || die
	make_desktop_entry SweetHome3D "Sweet Home 3D" ${PN} Graphics
}
