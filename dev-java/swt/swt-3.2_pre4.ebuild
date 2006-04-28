# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/swt/swt-3.2_pre1.ebuild,v 1.8 2006/02/04 06:06:05 compnerd Exp $

inherit toolchain-funcs eutils java-pkg

DESCRIPTION="GTK based SWT Library"
HOMEPAGE="http://www.eclipse.org/swt/"

MY_ARCH="${ARCH}"
[[ "${MY_ARCH}" == "amd64" ]] && MY_ARCH="x86_64"

MY_VERSION="3.2M4"
ZIP_FILE="swt-${MY_VERSION}-gtk-linux-${MY_ARCH}.zip"
SRC_URI="http://download.eclipse.org/downloads/drops/S-${MY_VERSION}-200512151506/${ZIP_FILE}"

SLOT="3"
LICENSE="CPL-1.0 LGPL-2.1 MPL-1.1"
KEYWORDS="~amd64 ~ppc ~x86"

IUSE="cairo firefox gnome mozilla"
RDEPEND=">=virtual/jre-1.4
		 >=x11-libs/gtk+-2.6.8
		 dev-libs/atk
		 || ( virtual/x11 x11-libs/libXtst )
		 mozilla? (
		 			 firefox?	(
					 				>=www-client/mozilla-firefox-1.0.6
									!>=www-client/mozilla-firefox-1.5
								)
					!firefox? ( >=www-client/mozilla-1.4 )
				  )
		 gnome? ( =gnome-base/gnome-vfs-2* =gnome-base/libgnomeui-2* )
		 cairo? ( >=x11-libs/cairo-1.0.2 )"
DEPEND=">=virtual/jdk-1.4
		${RDEPEND}
		dev-util/pkgconfig
		dev-java/ant-core
		app-arch/unzip"

S=${WORKDIR}

src_unpack() {
	unzip -jq "${DISTDIR}/${ZIP_FILE}" "*src.zip" || die "Failed to unzip ${ZIP_FILE}"
	unzip -q src.zip

	# Replace the build.xml to allow compilation without Eclipse tasks
	cp ${FILESDIR}/build.xml ${S}/build.xml || die "Unable to update build.xml"
	mkdir ${S}/src && mv ${S}/org ${S}/src || die "Unable to restructure SWT sources"
}

src_compile() {
	# Identify the AWT path
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

	# Identity the XTEST library location
	export XTEST_LIB_PATH=/usr/$(get_libdir)/X11

	# Fix the pointer size for AMD64
	[[ ${ARCH} == 'amd64' ]] && export SWT_PTR_CFLAGS=-DSWT_PTR_SIZE_64

	einfo "Building AWT library"
	emake -f make_linux.mak make_awt || die "Failed to build AWT support"

	einfo "Building SWT library"
	emake -f make_linux.mak make_swt || die "Failed to build SWT support"

	# Building this always as azureus does not start without this
	einfo "Building JAVA-AT-SPI bridge"
	emake -f make_linux.mak make_atk || die "Failed to build ATK support"

	if use gnome ; then
		einfo "Building GNOME VFS support"
		emake -f make_linux.mak make_gnome || die "Failed to build GNOME VFS support"
	fi

	if use mozilla || use firefox; then
		if use firefox ; then
			GECKO_SDK="$(pkg-config firefox-xpcom --variable=libdir)"
		else
			GECKO_SDK="$(pkg-config mozilla-xpcom --variable=libdir)"
		fi

		export GECKO_INCLUDES="-include ${GECKO_SDK}/include/mozilla-config.h \
						-I${GECKO_SDK}/include \
						-I${GECKO_SDK}/include/java \
						-I${GECKO_SDK}/include/nspr -I${GECKO_SDK}/include/nspr/include \
						-I${GECKO_SDK}/include/xpcom -I${GECKO_SDK}/include/xpcom/include \
						-I${GECKO_SDK}/include/string -I${GECKO_SDK}/include/string/include \
						-I${GECKO_SDK}/include/embed_base -I${GECKO_SDK}/include/embed_base/include \
						-I${GECKO_SDK}/include/embedstring -I${GECKO_SDK}/include/embedstring/include"
		export GECKO_LIBS="-L${GECKO_SDK} -lgtkembedmoz"

		einfo "Building the Mozilla component"
		emake -f make_linux.mak make_mozilla || die "Failed to build Mozilla support"
	fi

	if use cairo ; then
		einfo "Building CAIRO support"
		emake -f make_linux.mak make_cairo || die "Unable to build CAIRO support"
	fi

	einfo "Building JNI libraries"
	ant compile || die "Failed to compile JNI interfaces"

	einfo "Creating missing files"
	cp ${FILESDIR}/SWTMessages.properties ${S}/build/org/eclipse/swt/internal/

	einfo "Packing JNI libraries"
	ant jar || die "Failed to create JNI jar"
}

src_install() {
	java-pkg_dojar swt.jar

	java-pkg_sointo /usr/$(get_libdir)
	java-pkg_doso *.so

	dohtml about.html
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
