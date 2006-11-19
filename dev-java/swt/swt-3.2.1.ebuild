# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/swt/swt-3.2-r2.ebuild,v 1.5 2006/10/22 16:24:11 dertobi123 Exp $

inherit eutils java-pkg-2 java-ant-2

MY_DMF="R-${PV}-200609210945"

DESCRIPTION="GTK based SWT Library"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="x86? ( http://download.eclipse.org/downloads/drops/${MY_DMF}/swt-${PV}-gtk-linux-x86.zip )
		amd64? ( http://download.eclipse.org/downloads/drops/${MY_DMF}/swt-${PV}-gtk-linux-x86_64.zip )
		ppc? ( http://download.eclipse.org/downloads/drops/${MY_DMF}/swt-${PV}-gtk-linux-ppc.zip )"

SLOT="3"
LICENSE="CPL-1.0 LGPL-2.1 MPL-1.1"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="cairo gnome seamonkey opengl"
COMMON=">=dev-libs/glib-2.6
		>=x11-libs/gtk+-2.6.8
		>=dev-libs/atk-1.10.2
		cairo? ( >=x11-libs/cairo-1.0.2 )
		gnome?	(
					=gnome-base/libgnome-2*
					=gnome-base/gnome-vfs-2*
					=gnome-base/libgnomeui-2*
				)
		seamonkey? (
					>=www-client/seamonkey-1.0.2
					>=dev-libs/nspr-4.6.2
				)
		opengl?	(
					virtual/opengl
					virtual/glu
				)"
DEPEND=">=virtual/jdk-1.4
		${COMMON}
		dev-java/ant-core
		app-arch/unzip
		x11-libs/libX11
		x11-libs/libXrender
		x11-libs/libXt
		x11-proto/xextproto"

RDEPEND=">=virtual/jre-1.4
		x11-libs/libXtst
		${COMMON}"

S="${WORKDIR}"

src_unpack() {
	unzip -jq "${DISTDIR}/${A}" "*src.zip" || die "unable to extract distfile"

	# Unpack the sources
	einfo "Unpacking src.zip to ${S}"
	unpack ./src.zip

	# Cleanup the redirtied directory structure
	rm -rf about_files/
	rm -f .classpath .project

	# Replace the build.xml to allow compilation without Eclipse tasks
	cp "${FILESDIR}"/build.xml ${S}/build.xml || die "Unable to update build.xml"
	mkdir ${S}/src && mv ${S}/org ${S}/src || die "Unable to restructure SWT sources"

	# Patch for GCC 4.x warnings
	epatch "${FILESDIR}"/${PN}-3.2-gcc-4.x-warning-fix.patch

	# https://bugs.eclipse.org/bugs/show_bug.cgi?id=165097
	epatch "${FILESDIR}"/${PN}-3.2.1-remove-stripping.patch

	epatch "${FILESDIR}"/${PN}-3.2.1-libswt-xpcomgcc4.patch

	epatch "${FILESDIR}"/${PN}-3.2.1-firefox.patch

	if [[ ${ARCH} == "amd64" ]] ; then
		epatch "${FILESDIR}"/${PN}-3.2-cairo-signedness-x86_64.patch
	else
		epatch "${FILESDIR}"/${PN}-3.2-cairo-signedness-x86.patch
	fi

	sed -i "s/CFLAGS = -O -Wall/CFLAGS = ${CFLAGS} -Wall/" \
		make_linux.mak \
		|| die "Failed to tweak make_linux.mak"

	sed -i "s/MOZILLACFLAGS = -O/MOZILLACFLAGS = ${CXXFLAGS}/" \
		make_linux.mak \
		|| die "Failed to tweak make_linux.mak"
}

src_compile() {
	# Drop jikes support as it seems to be unfriendly with SWT
	java-pkg_filter-compiler jikes

	# Identify the AWT path
	# The IBM VMs and the GNU GCC implementations do not store the AWT libraries
	# in the same location as the rest of the binary VMs.
	if [[ ! -z "$(java-config --java-version | grep 'IBM')" ]] ; then
		export AWT_LIB_PATH=$JAVA_HOME/jre/bin
	elif [[ ! -z "$(java-config --java-version | grep 'GNU libgcj')" ]] ; then
		export AWT_LIB_PATH=$JAVA_HOME/$(get_libdir)
	else
		if [[ ${ARCH} == 'x86' ]] ; then
			export AWT_LIB_PATH=$JAVA_HOME/jre/lib/i386
		elif [[ ${ARCH} == 'ppc' ]] ; then
			export AWT_LIB_PATH=$JAVA_HOME/jre/lib/ppc
		else
			export AWT_LIB_PATH=$JAVA_HOME/jre/lib/amd64
		fi
	fi

	# Fix the GTK+ Library path
	export GTKLIBS="$(pkg-config --libs-only-L gtk+-2.0 gthread-2.0) \
		-lgtk-x11-2.0 -lgthread-2.0 -L/usr/$(get_libdir)/X11 -lXtst"

	# Fix the pointer size for AMD64
	[[ ${ARCH} == 'amd64' ]] && export SWT_PTR_CFLAGS=-DSWT_PTR_SIZE_64

	local make="emake -f make_linux.mak NO_STRIP=y"

	einfo "Building AWT library"
	${make} make_awt || die "Failed to build AWT support"

	einfo "Building SWT library"
	${make} make_swt || die "Failed to build SWT support"

	einfo "Building JAVA-AT-SPI bridge"
	${make} make_atk || die "Failed to build ATK support"

	if use gnome ; then
		einfo "Building GNOME VFS support"
		${make} make_gnome || die "Failed to build GNOME VFS support"
	fi

	if use seamonkey ; then
		export GECKO_SDK="$(pkg-config seamonkey-xpcom --variable=libdir)"
		export GECKO_INCLUDES="-I/usr/$(get_libdir)/seamonkey/include/xpcom \
								-I/usr/include/nspr \
								-I/usr/$(get_libdir)/seamonkey/include/embed_base \
								-I/usr/$(get_libdir)/seamonkey/include/string"
		export GECKO_LIBS="-L${GECKO_SDK} -lgtkembedmoz"

		einfo "Building the Mozilla component"
		${make} make_mozilla || die "Failed to build Mozilla support"
	fi

	if use cairo ; then
		einfo "Building CAIRO support"
		${make} make_cairo || die "Unable to build CAIRO support"
	fi

	if use opengl ; then
		einfo "Building OpenGL component"
		${make} make_glx || die "Unable to build OpenGL component"
	fi

	einfo "Building JNI libraries"
	eant compile

	einfo "Copying missing files"
	cp ${S}/version.txt ${S}/build/version.txt
	cp ${S}/src/org/eclipse/swt/internal/SWTMessages.properties ${S}/build/org/eclipse/swt/internal/

	einfo "Packing JNI libraries"
	eant jar
}

src_install() {
	java-pkg_dojar swt.jar

	java-pkg_sointo /usr/$(get_libdir)
	java-pkg_doso *.so

	dohtml about.html
}

