# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit java-vm-2

dist="http://dev.gentoo.org/~caster/distfiles/"
DESCRIPTION="A Gentoo-made binary build of the icedtea6 JDK"
SRC_URI="amd64? ( ${dist}/${PN}-core-${PVR}-amd64.tbz2 )
	x86? ( ${dist}/${PN}-core-${PVR}-x86.tbz2 )
	doc? ( ${dist}/${PN}-doc-${PVR}.tbz2 )
	examples? (
		amd64? ( ${dist}/${PN}-examples-${PVR}-amd64.tbz2 )
		x86? ( ${dist}/${PN}-examples-${PVR}-x86.tbz2 )
	)
	nsplugin? (
		amd64? ( ${dist}/${PN}-nsplugin-${PVR}-amd64.tbz2 )
		x86? ( ${dist}/${PN}-nsplugin-${PVR}-x86.tbz2 )
	)
	source? ( ${dist}/${PN}-src-${PVR}.tbz2 )"
HOMEPAGE="http://icedtea.classpath.org"

IUSE="X alsa doc examples nsplugin source"
# JTReg doesn't pass at present
RESTRICT="strip test"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/${PF}"

RDEPEND="
	>=sys-libs/glibc-2.6.1
	>=media-libs/giflib-4.1.6-r1
	>=media-libs/jpeg-6b-r8
	>=media-libs/libpng-1.2.33
	>=sys-libs/zlib-1.2.3-r1
	alsa? ( >=media-libs/alsa-lib-1.0.16 )
	X? (
		>=media-libs/freetype-2.3.7:2
		>=x11-libs/libXext-1.0.3
		>=x11-libs/libXi-1.1.3
		>=x11-libs/libXtst-1.0.3
		>=x11-libs/libX11-1.1.4
	)
	nsplugin? (
		>=dev-libs/atk-1.22.0
		>=dev-libs/glib-2.16.5:2
		>=dev-libs/nspr-4.7.3
		>=x11-libs/cairo-1.6.4-r1
		>=x11-libs/gtk+-2.12.11:2
		>=x11-libs/pango-1.20.5
	)"
DEPEND=""

QA_EXECSTACK_amd64="opt/${P}/jre/lib/amd64/server/libjvm.so"
QA_EXECSTACK_x86="opt/${P}/jre/lib/i386/server/libjvm.so
	opt/${P}/jre/lib/i386/client/libjvm.so"

src_install() {
	local dest="/opt/${P}"
	local ddest="${D}/${dest}"
	dodir "${dest}" || die

	local arch=${ARCH}

	# doins can't handle symlinks.
	cp -pRP bin include jre lib man "${ddest}" || die "failed to copy"

	dodoc ../doc/{ASSEMBLY_EXCEPTION,THIRD_PARTY_README} || die
	if use doc ; then
		dohtml -r ../doc/html/* || die "Failed to install documentation"
	fi

	if use examples; then
		cp -pRP share/{demo,sample} "${ddest}" || die
	fi

	if use source ; then
		cp src.zip "${ddest}" || die
	fi

	if use nsplugin ; then
		use x86 && arch=i386;
		install_mozilla_plugin "${dest}/jre/lib/${arch}/IcedTeaPlugin.so";
	fi

	set_java_env
	java-vm_revdep-mask
}

pkg_postinst() {
	if use nsplugin; then
		elog "The icedtea6-bin browser plugin can be enabled using eselect java-nsplugin"
		elog "Note that the plugin works only in browsers based on xulrunner-1.9"
		elog "such as Firefox 3 or Epiphany 2.24 and not in older versions!"
	fi
}
