# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools eutils flag-o-matic multilib

MY_P=${P/gnu-/}
DESCRIPTION="Free core class libraries for use with VMs and compilers for the Java programming language"
SRC_URI="mirror://gnu/classpath/${MY_P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/classpath"

LICENSE="GPL-2-with-linking-exception"
SLOT="0.97"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

IUSE="alsa debug doc dssi examples gconf gtk gstreamer nsplugin qt4 xml"

GTK_DEPS="
		>=x11-libs/gtk+-2.8
		>=dev-libs/glib-2.0
		|| (
				x11-libs/libICE
				x11-libs/libSM
				x11-libs/libX11
				x11-libs/libXtst
		)
"

RDEPEND="alsa? ( media-libs/alsa-lib )
		doc? ( >=dev-java/gjdoc-0.7.9 )
		dssi? ( >=media-libs/dssi-0.9 )
		gconf? ( gnome-base/gconf )
		gtk? ( ${GTK_DEPS} )
		nsplugin? (
			${GTK_DEPS}
			|| (
				www-client/mozilla-firefox
				net-libs/xulrunner
				www-client/seamonkey
			)
		)
		qt4? ( >=x11-libs/qt-4.3.1 )
		xml? ( >=dev-libs/libxml2-2.6.8 >=dev-libs/libxslt-1.1.11 )"

DEPEND="app-arch/zip
		>=dev-java/eclipse-ecj-3.2.1
		gtk? ( || (
					x11-libs/libXrender
					x11-proto/xextproto
					x11-proto/xproto
				)
			)
		${REPEND}"

S=${WORKDIR}/${MY_P}

src_compile() {
	# Now this detects fastjar automatically and some people have broken
	# wrappers in /usr/bin by eselect-compiler. Unfortunately
	# --without-fastjar does not seem to work.
	# http://bugs.gentoo.org/show_bug.cgi?id=135688

	# don't use econf, because it ends up putting things under /usr, which may
	# collide with other slots of classpath
	./configure ${compiler} \
		$(use_enable alsa) \
		$(use_enable debug ) \
		$(use_enable examples) \
		$(use_enable gconf gconf-peer) \
		$(use_enable gtk gtk-peer) \
		$(use_enable gstreamer gstreamer-peer) \
		$(use_enable nsplugin plugin) \
		$(use_enable qt4 qt-peer) \
		$(use_enable xml xmlj) \
		$(use_enable dssi ) \
		$(use_with doc gjdoc) \
		${myconf} \
		--enable-jni \
		--disable-dependency-tracking \
		--host=${CHOST} \
		--prefix=/usr/${PN}-${SLOT} \
		--with-ecj-jar=$(ls -r /usr/share/eclipse-ecj-3.*/lib/ecj.jar|head -n 1) \
		|| die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "einstall failed"
	dodoc AUTHORS BUGS ChangeLog* HACKING NEWS README THANKYOU TODO || die
}
