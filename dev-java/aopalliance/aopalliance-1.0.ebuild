# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/iso-relax/iso-relax-20041111.ebuild,v 1.4 2005/05/12 21:45:23 luckyduck Exp $

inherit java-pkg

DESCRIPTION="Aspect-Oriented Programming (AOP) Alliance classes"
SRC_URI="http://gentooexperimental.org/distfiles/${P}.tar.bz2"
#SRC_URI="mirror://gentoo/${P}.tar.bz2"
#cvs -d:pserver:anonymous@cvs.sourceforge.net:/cvsroot/aopalliance login 
# cvs -z3 -d:pserver:anonymous@cvs.sourceforge.net:/cvsroot/aopalliance export -r interception_1_0 aopalliance
# tar cjvf aopalliance-1.0.tar.bz2 aopalliance
HOMEPAGE="http://aopalliance.sourceforge.net/"
LICENSE="public-domain"
SLOT="1"
KEYWORDS="~x86"
IUSE="doc jikes"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? (dev-java/jikes)"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${PN}"

src_compile() {
	local antflags="jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "ant failed"
}

src_install() {
	java-pkg_dojar build/${PN}.jar
	use doc && java-pkg_dohtml -r build/api 
}
