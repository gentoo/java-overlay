# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/libgtk-java/libgtk-java-2.6.2-r1.ebuild,v 1.3 2005/07/19 09:35:09 axxo Exp $

#
# WARNING: Because java-gnome is a set of bindings to native GNOME libraries, 
# it has, like any GNOME project, a massive autoconf setup, and unlike many 
# other java libraries, it has its own [necessary] `make install` step.
# As a result, this ebuild is VERY sensitive to the internal layout of the
# upstream project. Because these issues are currently evolving upstream,
# simply version bumping this ebuild is not likely to work but FAILURES WILL
# BE VERY SUBTLE IF IT DOES NOT WORK.
# 

GNOME_TARBALL_SUFFIX="gz"

inherit eutils gnome.org

DESCRIPTION="Java bindings for GTK libraries (allow GTK applications to be written in Java)"
HOMEPAGE="http://java-gnome.sourceforge.net/"

# temporary until we get back to using ftp.gnome.org
SRC_URI="http://research.operationaldynamics.com/linux/java-gnome/dist/${P}.tar.gz"

RDEPEND=">=x11-libs/gtk+-2.8.3
	>=dev-java/glib-java-0.2.1
	>=dev-java/cairo-java-1.0.1
	>=virtual/jre-1.4"

DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	app-arch/zip"

#
# Critical that this match gtkapiversion
#
SLOT="2.8"
LICENSE="LGPL-2.1"
KEYWORDS="~ppc ~amd64 ~x86"
IUSE="gcj"

src_unpack() {
	unpack ${A}
	cd ${S}

	# adjust for Gentoo Java policy locations
	# thanks to yselkowitz@hotmail.com for the suggestion of using sed
	sed -i \
		-e "s:/share/${PN}/:/share/${PN}-${SLOT}/:" \
		-e "s:/share/java/:/share/${PN}-${SLOT}/lib/:" \
		configure || die "sed configure error"
}

src_compile() {
	local conf

	use gcj	|| conf="${conf} --without-gcj-compile"

	cd ${S}

	#
	# Ordinarily, moving things around post `make install` would do 
	# the trick, but there are paths hard coded in .pc files and in the
	# `make install` step itself that need to be influenced.
	#
	# NOTE: THIS RELIES ON PORTAGE PASSING $PN AND $SLOT IN THE ENVIRONMENT
	#

	export JAVADOC_OPTIONS="-use"

	./configure \
		--host=${CHOST} \
		--prefix=/usr \
		--with-jardir=/usr/share/${PN}-${SLOT}/lib \
			${conf} || die "./configure failed"
	make || die
}

src_install() {
	make DESTDIR=${D} install || die "install step failed"

	mv ${D}/usr/share/doc/libgtk${SLOT}-java ${D}/usr/share/doc/${PF}

	# the upstream install scatters things around a bit. The following cleans
	# that up to make it policy compliant.

	dodir /usr/share/${PN}-${SLOT}/src
	cd ${S}/src/java
	find . -name '*.java' | xargs zip ${D}/usr/share/${PN}-${SLOT}/src/libgtk-java-${PV}.src.zip

	# again, with dojar misbehaving, better do to this manually for the 
	# time being.

	echo "DESCRIPTION=${DESCRIPTION}" \
		>  ${D}/usr/share/${PN}-${SLOT}/package.env

	echo "CLASSPATH=/usr/share/${PN}-${SLOT}/lib/gtk${SLOT}.jar" \
		>> ${D}/usr/share/${PN}-${SLOT}/package.env
}
