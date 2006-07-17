# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2

MY_DMF="R-3.2-200606291905"
MY_VERSION="3.2"

DESCRIPTION="GTK based SWT Library"
HOMEPAGE="http://www.eclipse.org/swt/"
SRC_URI="x86? ( http://download.eclipse.org/downloads/drops/${MY_DMF}/swt-${MY_VERSION}-gtk-linux-x86.zip )
		 amd64? ( http://download.eclipse.org/downloads/drops/${MY_DMF}/swt-${MY_VERSION}-gtk-linux-x86_64.zip )
		 ppc? ( http://download.eclipse.org/downloads/drops/${MY_DMF}/swt-${MY_VERSION}-gtk-linux-ppc.zip )"

SLOT="3"
LICENSE="CPL-1.0 LGPL-2.1 MPL-1.1"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="accessibility cairo gnome seamonkey opengl source"
COMMON=">=dev-libs/glib-2.6
		>=x11-libs/gtk+-2.6.8
		accessibility? ( >=dev-libs/atk-1.10.2 )
		||	(
				(
					x11-libs/libX11
					x11-libs/libXtst
				)
				virtual/x11
			)
		cairo? ( >=x11-libs/cairo-1.0.2 )
		gnome?	(
					=gnome-base/libgnome-2*
					=gnome-base/gnome-vfs-2*
					=gnome-base/libgnomeui-2*
				)
		seamonkey? ( www-client/seamonkey )
		opengl?	(
					virtual/opengl
					virtual/glu
				)"
DEPEND=">=virtual/jdk-1.4
		${COMMON}
		>=dev-util/pkgconfig-0.9
		  dev-java/ant-core
		  app-arch/unzip"
RDEPEND=">=virtual/jre-1.4
		 ${COMMON}"

S="${WORKDIR}"

src_unpack() {
	unzip -jq "${DISTDIR}/${A}" "*src.zip" || die "unable to extract distfile"

	# Unpack the sources
	einfo "Unpacking src.zip to ${S}"
	unzip -q src.zip || die "Unable to extract sources"

	# Cleanup the redirtied directory structure
	rm -rf about_files/
	rm -f .classpath .project

	# Replace the build.xml to allow compilation without Eclipse tasks
	cp ${FILESDIR}/build.xml ${S}/build.xml || die "Unable to update build.xml"

	# Patch for GCC 4.x warnings
	epatch ${FILESDIR}/${P}-gcc-4.x-warning-fix.patch
	use amd64 \
		&& epatch ${FILESDIR}/${P}-cairo-signedness-x64.patch \
		|| epatch ${FILESDIR}/${P}-cairo-signedness.patch
}

src_compile() {
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

	# Fix the pointer size for AMD64
	[[ ${ARCH} == 'amd64' ]] && export SWT_PTR_CFLAGS=-DSWT_PTR_SIZE_64

	einfo "Building AWT library"
	emake -f make_linux.mak make_awt || die "Failed to build AWT support"

	einfo "Building SWT library"
	emake -f make_linux.mak make_swt || die "Failed to build SWT support"

	if use accessibility ; then
		einfo "Building JAVA-AT-SPI bridge"
		emake -f make_linux.mak make_atk || die "Failed to build ATK support"
	fi

	if use gnome ; then
		einfo "Building GNOME VFS support"
		emake -f make_linux.mak make_gnome || die "Failed to build GNOME VFS support"
	fi

	if use seamonkey ; then
		# TODO should this be using pkg-config?
		export GECKO_SDK="$(pkg-config seamonkey-xpcom --variable=libdir)"
		export GECKO_INCLUDES="$(pkg-config seamonkey-gtkmozembed --cflags)"
		export GECKO_LIBS="-L${GECKO_SDK} -lgtkembedmoz"

		einfo "Building the Mozilla component"
		emake -f make_linux.mak make_mozilla || die "Failed to build Browser support"
	fi

	if use cairo ; then
		einfo "Building CAIRO support"
		emake -f make_linux.mak make_cairo || die "Unable to build CAIRO support"
	fi

	if use opengl ; then
		einfo "Building OpenGL component"
		emake -f make_linux.mak make_glx || die "Unable to build OpenGL component"
	fi

	einfo "Building JNI libraries"
	eant jar || die "Failed to create JNI jar"
}

src_install() {
	java-pkg_dojar swt.jar

	java-pkg_sointo /usr/$(get_libdir)
	java-pkg_doso *.so

	dohtml about.html

	java-pkg_dosrc ${S}/org
}

pkg_postinst() {
	if use cairo; then
		ewarn
		ewarn "CAIRO Support is experimental! We are not responsible if"
		ewarn "enabling support for CAIRO corrupts your Gentoo install,"
		ewarn "if it blows up your computer, or if it becomes sentient"
		ewarn "and chases you down the street yelling random binary!"
		ewarn
		ebeep 5
	fi
}
