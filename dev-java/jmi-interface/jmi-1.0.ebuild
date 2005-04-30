# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="Java Metadata Interface Sample Class Interface"

HOMEPAGE="http://java.sun.com/products/jmi/"

SRC_URI="mirror://gentoo/jmi-${PV/./_}-fr-interfaces.zip"

LICENSE="sun-bcla+supplemental"

SLOT="0"

KEYWORDS="~x86"

IUSE="doc source"

DEPEND="app-arch/unzip
		virtual/jdk"

RDEPEND="virtual/jre"

S=${WORKDIR}

src_unpack() {
	cp ${FILESDIR}/build.xml .
	mkdir src
	cd src 
	unpack ${A}
}

src_compile() {
	ant || die "Failed to compile"
	use doc && ( ant javadoc || die "Failed to make javadoc" )
}

src_install() {
	use doc && java-pkg_dohtml -r doc/*
	use source && java-pkg_dosrc src/*
	dojar dist/jmi.jar
}
