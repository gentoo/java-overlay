# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/libgconf-java/libgconf-java-2.10.1.ebuild,v 1.3 2005/07/19 11:58:20 axxo Exp $

#
# WARNING: Because java-gnome is a set of bindings to native GNOME libraries, 
# it has, like any GNOME project, a massive autoconf setup, and unlike many 
# other java libraries, it has its own [necessary] `make install` step.
# As a result, this ebuild is VERY sensitive to the internal layout of the
# upstream project. Because these issues are currently evolving upstream,
# simply version bumping this ebuild is not likely to work but FAILURES WILL
# BE VERY SUBTLE IF IT DOES NOT WORK.
# 

inherit eutils gnome.org

DESCRIPTION="Java bindings for GConf (allows GNOME/GTK applications writen in Java to store configuration information in gconf)"
HOMEPAGE="http://java-gnome.sourceforge.net/"
RDEPEND=">=gnome-base/gconf-2.10.0
	>=dev-java/libgtk-java-2.6.2
	>=dev-java/libgnome-java-2.10.1
	>=virtual/jre-1.2"

DEPEND=">=virtual/jdk-1.2
	${RDEPEND}
	app-arch/zip"

#
# Critical that this match gconf's apiversion
#
SLOT="2.10"
LICENSE="LGPL-2.1"
KEYWORDS="~ppc ~x86"
IUSE="gcj"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${FILESDIR}/libgconf-java-2.10.0_fix-install-dir.patch

	sed -i \
		-e "s:/share/${PN}/:/share/${PN}-${SLOT}/:" \
		-e "s:/share/java/:/share/${PN}-${SLOT}/lib/:" \
		configure || die "sed configure error"
}

src_compile() {
	local conf

	use gcj	|| conf="${conf} --without-gcj-compile"

	cd ${S}

	./configure \
		--host=${CHOST} \
		--prefix=/usr \
		--with-jardir=/usr/share/${PN}-${SLOT}/lib \
			${conf} || die "./configure failed"
	make || die
}

src_install() {
	make DESTDIR=${D} install || die "install failed"

	mkdir ${D}/usr/share/${PN}-${SLOT}/src
	cd ${S}/src/java
	find . -name '*.java' | xargs zip ${D}/usr/share/${PN}-${SLOT}/src/libgconf-java-${PV}.src.zip

	# with dojar misbehaving, better do to this manually for the 
	# time being. Yes, this is bad hard coding, but what in this ebuild isn't?

	echo "DESCRIPTION=${DESCRIPTION}" \
		>  ${D}/usr/share/${PN}-${SLOT}/package.env

	echo "CLASSPATH=/usr/share/${PN}-${SLOT}/lib/gconf${SLOT}.jar" \
		>> ${D}/usr/share/${PN}-${SLOT}/package.env
}
