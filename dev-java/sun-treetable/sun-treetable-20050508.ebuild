# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-utils

DESCRIPTION="TreeTables in Swing"
HOMEPAGE="http://java.sun.com/products/jfc/tsc/articles/treetable1/index.html"
#The sources are from 
# http://java.sun.com/products/jfc/tsc/articles/treetable1/downloads/sources.zip
SRC_URI="mirror://gentoo/sun-treetable-sources-20050508.zip"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes source"
DEPEND="virtual/jdk
		app-arch/unzip"
RDEPEND="virtual/jre"

S=${WORKDIR}

src_unpack () {
	mkdir src
	cd src
	unpack ${A}	
	sed -i "s/com.sun.java/javax/g" *
}

src_compile () {
	local antflags
	use jikes && antflags="${antflags} -Dbuild.compile=jikes"
	use doc && antflags="${antflags} javadoc"
	java-utils_generic-ant 1.0 ${antflags}
}

src_install () {
	echo "foo"
}
