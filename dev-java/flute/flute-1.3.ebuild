# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="Flute is an implementation for SAC"

HOMEPAGE="http://www.w3.org/Style/CSS/SAC/"

SRC_URI="http://www.w3.org/2002/06/flutejava-${PV}.zip"

LICENSE="w3c"

SLOT="0"

KEYWORDS="~x86"

IUSE="doc jikes source"

DEPEND="app-arch/unzip
		virtual/jdk
		jikes? (dev-java/jikes)
		dev-java/sac
		"

RDEPEND="
		dev-java/sac
		virtual/jre"

src_unpack() {
	unpack $A
	cp ${FILESDIR}/build.xml $S
	cd $S
	rm -fr flute.jar
	mkdir src
	mv org src
	java-pkg_jar-from sac
}
 
src_compile() {
	local antflags
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant || die "Compiling failed"
}

src_install() {
	use doc && java-pkg_dohtml -r ./doc/*
	dohtml COPYRIGHT.html

	if use source; then
		java-pkg_dosrc src/org || die "Failed to package sources"
	fi

	cd dist
	dojar flute.jar
}
