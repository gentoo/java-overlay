# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-osgi java-pkg-2 java-ant-2

S="${WORKDIR}"
MY_PV="${PV/.0}"
DMF="R-${MY_PV}-200806172000"

DESCRIPTION="GTK based SWT Library"
HOMEPAGE="http://www.eclipse.org/swt/"
SRC_URI="amd64? ( http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${PN}-${MY_PV}-gtk-linux-x86_64.zip )
	x86? ( http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${PN}-${MY_PV}-gtk-linux-x86.zip )
	x86-fbsd? ( http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${PN}-${MY_PV}-gtk-linux-x86.zip )
	ppc? ( http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${PN}-${MY_PV}-gtk-linux-ppc.zip )
	ppc64? ( http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${PN}-${MY_PV}-gtk-linux-x86_64.zip )"

SLOT="3.4"
LICENSE="CPL-1.0 LGPL-2.1 MPL-1.1"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="cairo gnome opengl seamonkey xulrunner"

CDEPEND=">=dev-libs/glib-2.10
	>=x11-libs/gtk+-2.8
	>=dev-libs/atk-1.10.2
	cairo? ( >=x11-libs/cairo-1.0.2 )
	gnome? (
		=gnome-base/libgnome-2*
		=gnome-base/gnome-vfs-2*
		=gnome-base/libgnomeui-2*
	)
	seamonkey? ( >=www-client/seamonkey-1.0.2 >=dev-libs/nspr-4.6.2 )
	xulrunner? ( >=net-libs/xulrunner-1.9_beta5 >=dev-libs/nspr-4.7.1_beta2 )
	opengl? ( virtual/opengl virtual/glu )"
DEPEND="${CDEPEND}
	>=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/unzip
	x11-libs/libX11
	x11-libs/libXrender
	x11-libs/libXt
	x11-proto/inputproto
	x11-proto/xextproto"
RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

src_unpack() {
	unzip -jq ${DISTDIR}/${A} "*src.zip" || die "unable to extract distfile"
	unpack ./src.zip

	# replace build.xml to skip eclipse tasks
	cp ${FILESDIR}/build.xml ${S}/build.xml || die "Failed to update build.xml"
	mkdir ${S}/src && mv ${S}/org ${S}/src || die "Failed to restructure SWT sources"

	epatch ${FILESDIR}/swt-3.3-callback-pointer-dereferencing.patch

	sed -r -e "s/(CFLAGS = -O -Wall)/\1 ${CFLAGS} /" -i make_linux.mak \
		|| die "Failed to tweak make_linux.mak"
	sed -r -e "s/(MOZILLACFLAGS =) -O/\1 ${CXXFLAGS} /" -i make_linux.mak \
		|| die "Failed to tweak make_linux.mak"
}

src_compile() {
	local jvmarch="${ARCH}"
	use x86 && jvmarch="i386"
	use ppc64 && jvmarch="ppc"
	
	# set awt library path
	AWT_LIB_PATH="$(java-config --jdk-home)/jre/lib/${jvmarch}"
	[[ $(java-pkg_get-vm-vendor) == "ibm" ]] \
		&& AWT_LIB_PATH="$(java-config --jdk-home)/jre/bin"
	[[ ! -f ${AWT_LIB_PATH}/libjawt.so ]] \
		&& die "Could not find libjawt.so native library"
	export AWT_LIB_PATH

	# fix pointer size
	[[ ${ARCH} = *64 ]] && export SWT_PTR_CFLAGS=-DSWT_PTR_SIZE_64

	# set targets
	local target="awt swt atk"
	use gnome && target="${target} gnome"
	use xulrunner && target="${target} mozilla xulrunner"
	use cairo && target="${target} cairo"
	use opengl && target="${target} glx"

	# browser setup
	if use xulrunner; then
		export XULRUNNER_INCLUDES="$(pkg-config mozilla-gtkmozembed --cflags)"
		export XULRUNNER_LIBS="$(pkg-config mozilla-gtkmozembed --libs)"
		export MOZILLA_INCLUDES="${XULRUNNER_INCLUDES}"
		export MOZILLA_LIBS="${XULRUNNER_LIBS}"
	elif use seamonkey; then
		export MOZILLA_INCLUDES="$(pkg-config seamonkey-gtkmozembed --cflags)"
		export MOZILLA_LIBS="$(pkg-config seamonkey-gtkmozembed --cflags)"
	fi

	# build libs
	for lib in ${target} ; do
		einfo "building ${lib} library"
		emake -f make_linux.mak NO_STRIP=y make_${lib} || die "failed to build ${lib} library"
	done

	# jni lib
	einfo "building jni library"
	eant compile

	# copy missing files
	cp ${S}/version.txt ${S}/build/version.txt
	cp ${FILESDIR}/fragment.properties ${S}/build/fragment.properties
	cp ${S}/src/org/eclipse/swt/internal/SWTMessages.properties \
		${S}/build/org/eclipse/swt/internal/

	einfo "jarring jni library"
	eant jar
}

src_install() {
	local arch=${ARCH}
	use amd64 && arch=x86_64
	use x86-fbsd && arch=x86

	sed -e "s:ARCH:${arch}:" \
		"${FILESDIR}/swt-3.4-manifest-2" > manifest
	java-osgi_newjar-fromfile --no-auto-version swt.jar manifest \
		"Standard Widget Toolkit for GTK 2.0"

	java-pkg_sointo /usr/$(get_libdir)
	java-pkg_doso *.so

	dohtml about.html
}
