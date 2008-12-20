# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/jubler/jubler-3.9.6.ebuild,v 1.5 2008/12/20 00:54:50 gentoofan23 Exp $

EAPI="2"
inherit gnome2 eutils java-pkg-2 java-ant-2 toolchain-funcs

MY_PN=${PN/#j/J}
DESCRIPTION="Java subtitle editor"
HOMEPAGE="http://www.jubler.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_PN}-src-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="mplayer nls spell"

RDEPEND=">=virtual/jre-1.5
	>=media-video/ffmpeg-0.4.9_p20080326
	mplayer? ( media-video/mplayer[ass] )
	spell?
	(
		app-text/aspell
		>=dev-java/zemberek-2.0[linguas_tr]
	)
	dev-java/jupidator"

DEPEND=">=virtual/jdk-1.5
	media-video/ffmpeg
	app-text/docbook-sgml-utils
	dev-util/pkgconfig
	nls? ( sys-devel/gettext )
	dev-java/jupidator"

S=${WORKDIR}/${MY_PN}-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	epatch "${FILESDIR}/${P}.patch"
	chmod +x resources/installers/linux/iconinstall
	java-ant_rewrite-classpath
	java-ant_rewrite-classpath nbproject/build-impl.xml
}

src_compile() {
	java-pkg_filter-compiler ecj-3.2
	eant -Dgentoo.classpath="$(java-pkg_getjars jupidator)" distbased $(use nls && echo i18n) jar faq changelog || die "eant failed"
	cp -v dist/help/jubler-faq.html build/classes/help || die "cp failed"
	cd resources/ffdecode || die
	CC=$(tc-getCC) NOSTRIP=true emake linuxdyn || die "make failed"
}

src_install() {
	java-pkg_dojar dist/Jubler.jar
	use spell && java-pkg_register-dependency zemberek zemberek2-cekirdek.jar
	use spell && java-pkg_register-dependency zemberek zemberek2-tr.jar
	java-pkg_doso resources/ffdecode/libffdecode.so
	doicon resources/installers/linux/jubler.png
	domenu resources/installers/linux/jubler.desktop

	DESTDIR="${D}" eant linuxdesktopintegration
	rm -vr "${D}/usr/share/menu" || die

	java-pkg_dolauncher jubler --main com.panayotis.jubler.Main
	doman resources/installers/linux/jubler.1
	insinto /usr/share/jubler/help
	doins dist/help/*
}

pkg_preinst() {
	gnome2_pkg_preinst
	java-pkg-2_pkg_preinst
}
