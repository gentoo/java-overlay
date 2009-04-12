# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit java-pkg-2 toolchain-funcs

DESCRIPTION="A LALR(1) parser generator: Berkeley yacc retargeted to C# and Java"
HOMEPAGE="http://www.cs.rit.edu/~ats/projects/lp/doc/jay/package-summary.html"
SRC_URI="http://www.cs.rit.edu/~ats/projects/lp/doc/jay/doc-files/src.zip -> ${P}.zip"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4"

S="${WORKDIR}/jay"

java_prepare() {
	# Fix up ugly makefiles.
	sed -i -r \
		-e "s:^CC\s*=.*:CC = `tc-getCC`:" \
		-e '/^CFLAGS\s*=/d' \
		 src/makefile || die

	sed -i -r \
		-e 's:^v4\s*=.*:v4 = ${JAVA_HOME}/bin:' \
		-e 's:JAVAC\s*=.*:\0 ${JAVACFLAGS}:' \
		yydebug/makefile || die
}

src_compile() {
	emake -C src jay || die "failed to build jay executable"
	emake -C yydebug yydebug.jar || die "failed to build yydebug.jar"
}

src_install() {
	dobin src/jay || die
	doman jay.1 || die
	dodoc README || die
	java-pkg_dojar yydebug/yydebug.jar
}
