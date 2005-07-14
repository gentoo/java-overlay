# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jmi-interface/jmi-interface-1.0.ebuild,v 1.3 2005/06/09 00:57:02 mr_bones_ Exp $

inherit java-pkg

DESCRIPTION="Java Metadata Interface Sample Class Interface"
HOMEPAGE="http://java.sun.com/products/jmi/"
SRC_URI="mirror://gentoo/jmi-${PV/./_}-fr-interfaces.zip"

LICENSE="sun-bcla-jmi"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="doc jikes source"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}

src_unpack() {
	cp ${FILESDIR}/${P}-build.xml ${S}/build.xml

	mkdir ${S}/src
	unzip -q -d ${S}/src ${DISTDIR}/${A}
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "Failed to compile"
}

src_install() {
	use doc && java-pkg_dohtml -r doc/*
	use source && java-pkg_dosrc src/*
	dojar dist/*.jar
}
