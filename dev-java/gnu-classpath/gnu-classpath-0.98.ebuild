# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1

inherit eutils flag-o-matic java-pkg-2 multilib

MY_P=${P/gnu-/}
DESCRIPTION="Free core class libraries for use with virtual machines and compilers for the Java programming language"
SRC_URI="mirror://gnu/classpath/${MY_P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/classpath"

LICENSE="GPL-2-with-linking-exception"
SLOT="0.98"
KEYWORDS="~amd64 ~ppc"

IUSE="alsa debug doc dssi examples gconf gjdoc gmp gtk gstreamer nsplugin qt4 xml"

RDEPEND="alsa? ( media-libs/alsa-lib )
		doc? ( >=dev-java/gjdoc-0.7.9 )
		dssi? ( >=media-libs/dssi-0.9 )
		gconf? ( gnome-base/gconf )
		gjdoc? ( >=dev-java/antlr-2.7.1 )
		gmp? ( >=dev-libs/gmp-4.2.4 )
		gstreamer? (
			>=media-libs/gstreamer-0.10.10
			>=media-libs/gst-plugins-base-0.10.10
			dev-libs/glib
		)
		gtk? (
				>=x11-libs/gtk+-2.8
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
		nsplugin? (
			>=x11-libs/gtk+-2.8
			|| (
				www-client/mozilla-firefox
				net-libs/xulrunner
				www-client/seamonkey
			)
		)
		qt4? ( || ( x11-libs/qt-gui:4 >=x11-libs/qt-4.0 ) )
		xml? ( >=dev-libs/libxml2-2.6.8 >=dev-libs/libxslt-1.1.11 )
		dev-java/eclipse-ecj:3.3
		sys-apps/file"

DEPEND="app-arch/zip
		gtk? ( || (
					x11-libs/libXrender
					x11-proto/xextproto
					x11-proto/xproto
				)
			)
		${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_compile() {
	# We require ecj anyway, so force it to avoid problems with bad versions of javac
	export JAVAC="/usr/bin/ecj-3.3 -nowarn"
	export JAVA="/usr/bin/java"

	# don't use econf, because it ends up putting things under /usr, which may
	# collide with other slots of classpath
	./configure \
		$(use_enable alsa) \
		$(use_enable debug ) \
		$(use_enable examples) \
		$(use_enable gconf gconf-peer) \
		$(use_enable gjdoc) \
		$(use_enable gmp) \
		$(use_enable gtk gtk-peer) \
		$(use_enable gstreamer gstreamer-peer) \
		$(use_enable nsplugin plugin) \
		$(use_enable qt4 qt-peer) \
		$(use_enable xml xmlj) \
		$(use_enable dssi ) \
		$(use_with doc gjdoc) \
		--enable-jni \
		--disable-dependency-tracking \
		--host=${CHOST} \
		--prefix=/usr/${PN}-${SLOT} \
		--with-ecj-jar=$(java-pkg_getjar eclipse-ecj:3.3 ecj.jar) \
		|| die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS BUGS ChangeLog* HACKING NEWS README THANKYOU TODO || die
}
