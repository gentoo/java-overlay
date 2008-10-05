# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
JAVA_PKG_IUSE="doc examples source"

inherit eutils versionator java-pkg-2

MY_PV="${PV/_/-}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Java bindings for GTK and GNOME"
HOMEPAGE="http://java-gnome.sourceforge.net/"
SRC_URI="mirror://gnome/sources/${PN}/$(get_version_component_range 1-2)/${MY_P}.tar.bz2"

LICENSE="GPL-2-with-linking-exception"
SLOT="4.0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

# Minimum GNOME 2.22 dependencies
RDEPEND=">=dev-libs/glib-2.16.1
	>=x11-libs/gtk+-2.12.8
	>=gnome-base/libglade-2.6.2
	>=gnome-base/libgnome-2.22.0
	>=gnome-base/gnome-desktop-2.22.0
	>=virtual/jre-1.5
	>=x11-libs/cairo-1.6.4[svg]"
DEPEND="${RDEPEND}
	dev-java/junit:0
	dev-lang/perl
	>=virtual/jdk-1.5
	dev-util/pkgconfig"

# Needs X11
RESTRICT="test"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-4.0.8-disable-doc-snapshots.patch"
	epatch "${FILESDIR}/${P}-jardir.patch" #sent upstream
	epatch "${FILESDIR}/${PN}-gtk-214.patch"
}

src_configure() {
	# Handwritten in perl so not using econf
	./configure prefix=/usr libdir=/usr/lib/${PN}-${SLOT} jardir=/usr/share/${PN}-${SLOT}/lib|| die
}

src_compile() {
	# Fails parallel build in case GCJ is detected
	# See https://bugs.gentoo.org/show_bug.cgi?id=200550
	emake -j1 || die "Compilation of java-gnome failed"

	if use doc; then
		DISPLAY= emake -j1 doc || die "Making documentation failed"
	fi
}

src_install(){
	emake -j1 DESTDIR="${D}" install || die
	java-pkg_regjar /usr/share/${PN}-${SLOT}/lib/gtk-4.0.jar
	java-pkg_regso /usr/lib/${PN}-${SLOT}/libgtkjni-${MY_PV}.so
	# Still needed? library path is now hardcoded in the jar. 
	
	dodoc AUTHORS HACKING NEWS README || die
	use doc && java-pkg_dojavadoc doc/api
	use examples && java-pkg_doexamples doc/examples
	use source && java-pkg_dosrc src/bindings/org
	
}
