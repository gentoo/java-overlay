# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="SAC is a standard interface for CSS parser"

HOMEPAGE="http://www.w3.org/Style/CSS/SAC/"

SRC_URI="http://www.w3.org/2002/06/sacjava-${PV}.zip"

LICENSE="w3c"

SLOT="0"

KEYWORDS="~x86"

IUSE="doc"

DEPEND="virtual/jdk"

RDEPEND="virtual/jre"

src_unpack() {
	unpack $A
	cp ${FILESDIR}/build.xml $S
}
 
src_compile() {
	ant || die "Compiling failed"
}

src_install() {
	cd doc
	use doc || dohtml -r *
	cd ../dist/
	dojar sac.jar
}
