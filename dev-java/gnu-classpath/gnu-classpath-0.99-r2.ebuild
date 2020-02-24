# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit eutils java-pkg-2 multilib

MY_P=${P/gnu-/}
DESCRIPTION="Free core class libraries for use with VMs and compilers for the Java language"
SRC_URI="mirror://gnu/classpath/${MY_P}.tar.gz"
HOMEPAGE="https://www.gnu.org/software/classpath"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64"

IUSE="alsa debug doc dssi examples gconf +gjdoc +gmp +gtk qt4 xml"
REQUIRED_USE="doc? ( gjdoc )"

RDEPEND="alsa? ( media-libs/alsa-lib )
		dssi? ( >=media-libs/dssi-0.9 )
		gconf? ( gnome-base/gconf:2= )
		gjdoc? ( >=dev-java/antlr-2.7.7-r7:0 )
		gmp? ( >=dev-libs/gmp-4.2.4:0= )
		gtk? (
				>=x11-libs/gtk+-2.8:2=
				dev-libs/glib:2=
				media-libs/freetype:2=
				>=x11-libs/cairo-1.1.9:=
				x11-libs/libICE
				x11-libs/libSM
				x11-libs/libX11
				x11-libs/libXrandr
				x11-libs/libXrender
				x11-libs/libXtst
				x11-libs/pango
		)
		xml? ( >=dev-libs/libxml2-2.6.8:2= >=dev-libs/libxslt-1.1.11 )"

# java-config >2.1.11 needed for ecj version globbing
DEPEND="app-arch/zip
		dev-java/eclipse-ecj
		>=dev-java/java-config-2.1.11
		gtk? (
			x11-base/xorg-proto
			x11-libs/libXrender
			>=x11-libs/libXtst-1.1.0
		)
		>=virtual/jdk-1.5
		${RDEPEND}"

RDEPEND=">=virtual/jre-1.5
	${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	# Adds support for building with the version of gjdoc in GNU Classpath
	epatch "${FILESDIR}/gjdoc_support.patch"
	# Fix a number of build issues, including turning Werror off by default
	epatch "${FILESDIR}/pr55182.patch"
	# Fix Gtk+ peer code to work with modern Freetype
	epatch "${FILESDIR}/freetype.patch"
	autoreconf
}

src_configure() {
	local ecj_pkg="eclipse-ecj"

	# We require ecj anyway, so force it to avoid problems with bad versions of javac
	export JAVAC="${EPREFIX}/usr/bin/ecj"
	export JAVA="${EPREFIX}/usr/bin/java"
	# build takes care of them itself, duplicate -source -target kills ecj
	export JAVACFLAGS="-nowarn"
	# build system is passing -J-Xmx768M which ecj however ignores
	# this will make the ecj launcher do it (seen case where default was not enough heap)
	export gjl_java_args="-Xmx768M"

	local myconf
	if use gjdoc; then
		local antlr=$(java-pkg_getjar antlr antlr.jar)
		myconf="--with-antlr-jar=${antlr}"
	fi

	if use doc; then
		# Avoid a cyclic dependency on gjdoc by building gjdoc before
		# the docs. First we need to trick configure. Hack alert!
		echo -e "#!/bin/sh\necho gjdoc 0.8" > tools/gjdoc.build || die
		chmod 755 tools/gjdoc.build || die
	fi

	# gstreamer-peer disabled as still requires 0.10 API
	ANTLR= econf \
		$(use_enable alsa) \
		$(use_enable debug ) \
		$(use_enable examples) \
		$(use_enable gconf gconf-peer) \
		$(use_enable gjdoc) \
		$(use_enable gmp) \
		$(use_enable gtk gtk-peer) \
		$(use_enable xml xmlj) \
		$(use_enable dssi ) \
		$(use_with doc gjdoc "${S}/tools/gjdoc.build") \
		--enable-jni \
		--disable-dependency-tracking \
		--disable-plugin \
		--disable-gstreamer-peer \
		--bindir="${EPREFIX}"/usr/libexec/${PN} \
		--includedir="${EPREFIX}"/usr/include/classpath \
		--with-ecj-jar=$(java-pkg_getjar --build-only ${ecj_pkg}-* ecj.jar) \
		${myconf}
}

src_compile() {
	if use doc; then
		# Build gjdoc before the docs. We need to hack the real gjdoc
		# script to run from the build directory instead.
		sed -r "s:^(tools_dir=).*:\1${S}/tools:" tools/gjdoc > tools/gjdoc.build || die
		emake -C lib
		emake -C tools
	fi

	default
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS BUGS ChangeLog* HACKING NEWS README THANKYOU TODO
	java-pkg_regjar /usr/share/classpath/glibj.zip
	java-pkg_regjar /usr/share/classpath/tools.zip

	if use doc; then
		# Strangely the Makefile doesn't install these.
		insinto "/usr/${PN}-${SLOT}/share/classpath/api"
		doins -r doc/api/html/*
	fi
}
