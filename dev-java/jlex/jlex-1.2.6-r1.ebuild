# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jlex/jlex-1.2.6.ebuild,v 1.11 2006/10/05 17:43:32 gustavoz Exp $

inherit java-pkg-2

DESCRIPTION="JLex: a lexical analyzer generator for Java"
SRC_URI="mirror://gentoo/${P}.tar.bz2"
HOMEPAGE="http://www.cs.princeton.edu/~appel/modern/java/JLex/"
KEYWORDS="~x86 ~ppc ~amd64"
LICENSE="jlex"
SLOT="0"
DEPEND=">=virtual/jdk-1.4
	jikes? ( dev-java/jikes )"
RDEPEND=">=virtual/jre-1.4"
IUSE="doc"

src_compile() {
	ejavac -nowarn Main.java
}

src_install() {
	dodoc README Bugs
	use doc && dohtml manual.html
	use doc && dodoc sample.lex
	mkdir JLex && mv *.class JLex/
	jar cf jlex.jar JLex/ || die "failed to jar"
	java-pkg_dojar jlex.jar
}
