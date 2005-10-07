# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-utils java-pkg

#The sources are from 
# http://java.sun.com/products/jfc/tsc/articles/treetable1/downloads/sources.zip

DESCRIPTION="TreeTables in Swing"
HOMEPAGE="http://java.sun.com/products/jfc/tsc/articles/treetable1/index.html"
SRC_URI="mirror://gentoo/sun-treetable-sources-20050508.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes source"

DEPEND="virtual/jdk
		dev-java/ant-core
		app-arch/unzip
		jikes? (dev-java/jikes)
		source? (app-arch/zip) "

RDEPEND="virtual/jre"

S=${WORKDIR}

src_unpack () {
	mkdir src
	cd src
	unpack ${A}	|| die "Failed to unpack sources"
	sed -i *.java -e "s/com.sun.java/javax/g"
}

src_compile () {
	local antflags
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	java-utils_generic-ant 1.0 ${antflags}
}

src_install () {
	use source && java-pkg_dosrc -r src/*
	use doc && java-pkg_dohtml -r doc/*
	java-pkg_dojar dist/*.jar
}
