# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="Java API compatibility testing tools"
HOMEPAGE="http://www.kaffe.org/~stuart/japi/"

SRC_URI="http://www.kaffe.org/~stuart/japi/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86"

IUSE="doc"

DEPEND="dev-java/ant-core
		virtual/jdk"

RDEPEND="virtual/jre
		dev-lang/perl"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}

	rm -fr ${S}/share/java/*.jar*
	find ${S} -name "*.class" -type f -o -type d -name "CVS" | xargs rm -fr 

	cd ${S}/bin
	rm japize.bat
	sed -e "s:../share/java:../share/${PN}/lib:" -i * \
		|| die "Failed to correct the location of the jar file in perl scripts."
}

src_compile() {
	ant jar || die "Failed to compile."
}

src_install() {
	java-pkg_dojar share/java/*.jar
	dobin bin/*	
	use doc && dodoc design/*
}
