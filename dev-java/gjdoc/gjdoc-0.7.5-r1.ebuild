# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="A javadoc compatible Java source documentation generator."
HOMEPAGE="http://www.gnu.org/software/cp-tools/"
SRC_URI="ftp://ftp.gnu.org/gnu/classpath/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~ppc"

# Possible USE flags.
#
# xml:    to --enable-xmldoclet (disabled by default)
# native: to --enable-native (native code - probably through gcj) - so maybe
#         could name USE flags gcj.
# doc:    to generate javadoc
# debug:  There is a debug doclet installed by default but maybe could
#         have a wrapper that uses it.
#
IUSE=""

# TODO use a specific version of jdk/jre
DEPEND=">=dev-java/antlr-2.7.1
	virtual/jdk"

RDEPEND="virtual/jre"

src_compile() {
	# I think that configure will do --enable-native if it finds gcj
	# so we'll disable it explicitly
	local myc="--with-antlr-jar=$(java-config --classpath=antlr) --disable-native"
	econf ${myc} || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	local jars="com-sun-tools-doclets-Taglet gnu-classpath-tools-gjdoc com-sun-javadoc"
	for jar in ${jars}; do
		java-pkg_newjar ${jar}-${PV}.jar ${jar}.jar
	done
	dobin ${FILESDIR}/gjdoc
}
