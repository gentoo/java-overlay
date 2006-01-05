# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /cvsroot/xins/xins-ebuild/xins-1.3.0.ebuild,v 1.1 2005/12/16 13:03:19 znerd Exp $

inherit java-pkg eutils

DESCRIPTION="Performance-optimized XML output library for Java"
HOMEPAGE="http://xmlenc.sourceforge.net/"
SRC_URI="mirror://sourceforge/xmlenc/${P}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="debug doc jikes source"

RDEPEND=">=virtual/jre-1.3"

DEPEND=">=virtual/jdk-1.3
	>=dev-java/ant-core-1.6
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )"

src_unpack() {
	unpack "${A}"
	rm -rf "${S}/build" || die "Failed to remove ${S}/build"
}

src_compile() {
	local antflags="jar"
	use debug && antflags="-Djavac.debug=true ${antflags}"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc-public"
	ant ${antflags} || die "Processing of Ant build file failed."

	if use doc; then
		mv build/javadoc build/api || "Renaming javadoc failed."
	fi
}

src_install() {
	java-pkg_dojar build/*.jar
	use doc && java-pkg_dohtml -r build/api
	use source && java-pkg_dosrc src/main/*
}
