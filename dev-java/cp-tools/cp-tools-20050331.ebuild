# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

DESCRIPTION="Several java equivalent tools: javah, javap, ..."

HOMEPAGE="http://www.gnu.org/software/cp-tools/"

# GNU Kawa version to use for gnu.bytecode library
KAWA_PV=1.7

SRC_URI="http://www.cs.mcgill.ca/~dbelan2/ebuilds/distfiles/${P}.tar.gz ftp://ftp.gnu.org/pub/gnu/kawa/kawa-${KAWA_PV}.tar.gz"

LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~x86 ~ppc"

IUSE=""

DEPEND="dev-java/sablevm
	dev-java/fastjar"

#RDEPEND=""

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/javah-patch.diff
	cp -R ../kawa-${KAWA_PV}/gnu/bytecode src/gnu
}

src_compile() {
	mkdir classes
	(cd src &&
		find . -name '*.java' | xargs javac-sablevm -d ../classes) || die
	(cd classes && jar -cvf ../cp-tools.jar .)
}

src_install() {
	java-pkg_dojar ${PN}.jar

	for f in bin/* ; do
		sed -i -e 's:^java :`java-config --java` -classpath `java-config --classpath=cp-tools` :g' $f
		dobin $f
	done
}
