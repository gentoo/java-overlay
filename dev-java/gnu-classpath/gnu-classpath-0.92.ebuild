# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/gnu-classpath/gnu-classpath-0.90.ebuild,v 1.11 2006/07/18 21:52:19 hansmi Exp $

inherit eutils

MY_P=${P/gnu-/}
DESCRIPTION="Free core class libraries for use with virtual machines and compilers for the Java programming language"
SRC_URI="mirror://gnu/classpath/${MY_P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/classpath"

LICENSE="GPL-2-with-linking-exception"
SLOT="0.92"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

# Add the doc use flag after the upstream build system is improved
# See their bug 24025

IUSE="alsa cairo debug dssi examples gtk xml"

RDEPEND="alsa? ( media-libs/alsa-lib )
		dssi? ( >=media-libs/dssi-0.9 )
		gtk? ( >=x11-libs/gtk+-2.4
				>=dev-libs/glib-2.0
				|| ( (
					   x11-libs/libICE
					   x11-libs/libSM
					   x11-libs/libX11
					   x11-libs/libXtst
					 )
				     virtual/x11
				   )
				cairo? ( >=x11-libs/cairo-0.5.0 )
		     )
		xml? ( >=dev-libs/libxml2-2.6.8 >=dev-libs/libxslt-1.1.11 )"

DEPEND="app-arch/zip
		dev-java/jikes
		gtk? ( || ( (
					  x11-libs/libXrender
					  x11-proto/xextproto
					  x11-proto/xproto
					)
					virtual/x11
				  )
			 )
		${REPEND}"

S=${WORKDIR}/${MY_P}

src_compile() {
	# Note: This is written in a way to easily support GCJ and other compilers
	# at a later point. Currently Gentoo uses mainly GCJ 3.3 (from the
	# corresponding GCC) which cannot compile GNU Classpath correctly.
	# Another possibility would be ECJ (from Eclipse).
	local compiler="--with-jikes"

	# Now this detects fastjar automatically and some people have broken
	# wrappers in /usr/bin by eselect-compiler. Unfortunately
	# --without-fastjar does not seem to work.
	# http://bugs.gentoo.org/show_bug.cgi?id=135688
	./configure ${compiler} \
		$(use_enable alsa) \
		$(use_enable cairo gtk-cairo) \
		$(use_enable debug ) \
		$(use_enable examples) \
		$(use_enable gtk gtk-peer) \
		$(use_enable xml xmlj) \
		$(use_enable dssi ) \
		--enable-jni \
		--disable-dependency-tracking \
		--prefix=/opt/${PN}-${SLOT} \
		|| die "configure failed"
# disabled for now... see above.
#		$(use_with   doc   gjdoc) \

	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS BUGS ChangeLog* HACKING NEWS README THANKYOU TODO
}

pkg_postinst() {
	if use gtk && use cairo; then
		einfo "GNU Classpath was compiled with preliminary cairo support."
		einfo "To use that functionality set the system property"
		einfo "gnu.java.awt.peer.gtk.Graphics to Graphics2D at runtime."
	fi
}
