# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A javadoc compatible Java source documentation generator."

HOMEPAGE="http://www.gnu.org/software/cp-tools/"

SRC_URI="ftp://ftp.gnu.org/gnu/classpath/gjdoc-${PV}.tar.gz"

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

DEPEND=">=dev-java/antlr-2.7.1
	virtual/jdk
	"

#RDEPEND=""

src_unpack() {
	unpack ${A}
	sed -i -e 's:${datadir}/java/:${datadir}/gjdoc/:g' ${S}/gjdoc.sh.in
}

src_compile() {
	econf --with-antlr-jar=/usr/share/antlr/lib/antlr.jar \
	  || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	# TODO: explore java-pkg eclass, could be of some use
	make DESTDIR=${D} jardir=/usr/share/${PN} install || die
}
