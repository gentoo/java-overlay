# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils git-2 java-pkg-2 base multilib

MY_P=${P/gnu-/}
DESCRIPTION="Free core class libraries for use with virtual machines and compilers for the Java language"
EGIT_REPO_URI="git://git.savannah.gnu.org/classpath.git"
HOMEPAGE="http://www.gnu.org/software/classpath"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS=""

IUSE="alsa debug doc dssi examples gconf +gjdoc +gmp +gtk gstreamer qt4 xml"

RDEPEND="alsa? ( media-libs/alsa-lib )
		doc? ( || ( >=dev-java/gjdoc-0.7.9-r2 >=dev-java/gnu-classpath-0.98:* ) )
		dssi? ( >=media-libs/dssi-0.9 )
		gconf? ( gnome-base/gconf )
		gjdoc? ( >=dev-java/antlr-2.7.1:0 )
		gmp? ( >=dev-libs/gmp-4.2.4:* )
		gstreamer? (
			>=media-libs/gstreamer-0.10.10:0.10
			>=media-libs/gst-plugins-base-0.10.10:0.10
			x11-libs/gtk+:2
		)
		gtk? (
				>=x11-libs/gtk+-2.8:2
				>=dev-libs/glib-2.0
				media-libs/freetype
				>=x11-libs/cairo-1.1.9
				x11-libs/libICE
				x11-libs/libSM
				x11-libs/libX11
				x11-libs/libXrandr
				x11-libs/libXrender
				x11-libs/libXtst
				x11-libs/pango
		)
		qt4? ( dev-qt/qtgui:4 )
		xml? ( >=dev-libs/libxml2-2.6.8 >=dev-libs/libxslt-1.1.11 )"

# java-config >2.1.11 needed for ecj version globbing
# We should make the build not pickup the wrong antlr binary from pccts
DEPEND="app-arch/zip
		|| ( dev-java/eclipse-ecj dev-java/ecj-gcj )
		>=dev-java/java-config-2.1.11
		gjdoc? ( !!dev-util/pccts )
		gtk? (
			x11-libs/libXrender
			>=x11-libs/libXtst-1.1.0
			x11-proto/xproto
		)
		>=virtual/jdk-1.5
		${RDEPEND}"

RDEPEND=">=virtual/jre-1.5
	${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	git-2_src_unpack
}

src_prepare() {
	./autogen.sh
}

src_configure() {
	local ecj_pkg=""

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

	# fallback on ecj-gcj if eclipse-ecj is not available
	if java-config --classpath=eclipse-ecj &> /dev/null ; then
		ecj_pkg="eclipse_ecj"
	else
		ecj_pkg="ecj-gcj"
	fi

	ANTLR= econf \
		$(use_enable alsa) \
		$(use_enable debug ) \
		$(use_enable examples) \
		$(use_enable gconf gconf-peer) \
		$(use_enable gjdoc) \
		$(use_enable gmp) \
		$(use_enable gtk gtk-peer) \
		$(use_enable gstreamer gstreamer-peer) \
		$(use_enable qt4 qt-peer) \
		$(use_enable xml xmlj) \
		$(use_enable dssi ) \
		$(use_with doc gjdoc) \
		--enable-jni \
		--disable-dependency-tracking \
		--disable-plugin \
		--bindir="${EPREFIX}"/usr/libexec/${PN} \
		--includedir="${EPREFIX}"/usr/include/classpath \
		--with-ecj-jar=$(java-pkg_getjar --build-only ${ecj_pkg}-* ecj.jar) \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS BUGS ChangeLog* HACKING NEWS README THANKYOU TODO
	java-pkg_regjar /usr/share/classpath/glibj.zip
	java-pkg_regjar /usr/share/classpath/tools.zip
}
