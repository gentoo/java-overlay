# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/cairo-java/cairo-java-1.0.2.ebuild,v 1.3 2006/01/11 01:43:12 karltk Exp $

# Must be before the gnome.org inherit
GNOME_TARBALL_SUFFIX="gz"

inherit java-pkg eutils gnome.org

DESCRIPTION="Java bindings for cairo"
HOMEPAGE="http://java-gnome.sourceforge.net/"

# Not on gnome.org mirrors yet :-(
SRC_URI="http://research.operationaldynamics.com/linux/java-gnome/dist/${PF}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="1.0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc gcj source"

DEPS=">=x11-libs/cairo-1.0.0-r2
	  >=dev-java/glib-java-0.2.2
	  >=media-libs/fontconfig-2.3.1
	  >=dev-libs/glib-2.6.0
	    dev-util/pkgconfig"

DEPEND=">=virtual/jdk-1.4
		>=sys-apps/sed-4
		source? ( app-arch/zip )
		${DEPS}"
RDEPEND=">=virtual/jre-1.4
		 ${DEPS}"

pkg_setup() {
	if use gcj ; then
		if ! built_with_use sys-devel/gcc gcj ; then
			ewarn
			ewarn "You must build gcc with the gcj support to build with gcj"
			ewarn
			ebeep 5
			die "No GCJ support found!"
		fi
	fi
}

src_compile() {
	# JARDIR is a hack for java-config
	econf $(use_with gcj gcj-compile) \
		  $(use_with doc javadocs) \
		  --with-jardir=/usr/share/${PN}-${SLOT}/lib \
		  || die "configure failed"

	emake || die "compile failed"

	# Fix the broken pkgconfig file
	sed -i \
		-e "s:classpath.*$:classpath=\${prefix}/share/${PN}-${SLOT}/lib/${PF}.jar:" \
		${S}/${PN}.pc
}

src_install() {
	emake DESTDIR=${D} install || die "install failed"

	# use java-pkg_dojar to install the jar
	rm -rf ${D}/usr/share/${PN}-${SLOT}

	mv ${S}/cairo${SLOT}.jar ${S}/${PF}.jar
	java-pkg_dojar ${S}/${PF}.jar

	if use doc ; then
		java-pkg_dohtml -r ${S}/doc
	fi

	if use source ; then
		java-pkg_dosrc ${S}/src/java/org
	fi
}
