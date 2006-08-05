# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-gnome autotools

DESCRIPTION="Java bindings for vte"

SLOT="0.12"
KEYWORDS="~amd64"

DEPS=">=dev-java/libgtk-java-2.8.1
		>=x11-libs/vte-0.12.1"
DEPEND="${DEPS}"
RDEPEND="${DEPS}"

src_unpack() {
	unpack ${A}
	cd ${S}
	# patch to fix JNI compilation. should be fixed with next upstream release
	epatch ${FILESDIR}/${P}-jni_includes.patch
	# fix bug in install-data-hook which doesn't respect jardir
	epatch ${FILESDIR}/${P}-jardir.patch
}
