# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_ANT_TASKS="ant-antlr"
JAVA_PKG_IUSE="cg doc source"

inherit java-pkg-2 java-ant-2 versionator

MY_PV=$(replace_all_version_separators '_' )
MY_PV=$(replace_version_separator 3 '-' ${MY_PV})

DESCRIPTION="Java(TM) Binding fot the OpenGL(TM) API"
HOMEPAGE="https://jogl.dev.java.net"
SRC_URI="http://download.java.net/media/jogl/builds/archive/jsr-231-${PV}/${PN}-${MY_PV}-src.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="virtual/opengl
			   x11-libs/libX11
			   x11-libs/libXxf86vm
			   cg? ( media-gfx/nvidia-cg-toolkit )"

DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		>=dev-java/cpptasks-1.0_beta4-r2
		${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
		${COMMON_DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}/${P}-fix-solaris-compiler.patch" "${FILESDIR}/${P}-libpath.patch"
	java-ant_rewrite-classpath gluegen/make/build.xml
	cd gluegen/make/lib
	rm -v *.jar || die
	java-pkg_jar-from cpptasks
}

src_compile() {
	cd make/
	local antflags="-Dantlr.jar=$(java-pkg_getjars antlr)"
	local gcp="$(java-pkg_getjars ant-core):$(java-config --tools)"
	use cg && antflags="${antflags} -Djogl.cg=1 -Dx11.cg.lib=/usr/lib"
	# -Dbuild.sysclasspath=ignore fails with missing ant dependencies.

	export ANT_OPTS="-Xmx1g"
	eant \
		-Dgentoo.classpath="${gcp}" \
		${antflags} all $(use_doc javadoc.dev.x11) $(use_doc javadoc)
}

src_install() {
	use doc && java-pkg_dojavadoc javadoc_public
	# Installed binary bundles a gluegen runtime but it's probably not worth it
	# but it's a bundled dep any way.
	use source && java-pkg_dosrc src/classes/*
	java-pkg_doso build/obj/*.so
	java-pkg_dojar build/*.jar
}

