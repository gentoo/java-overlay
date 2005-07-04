# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/iso-relax/iso-relax-20041111.ebuild,v 1.4 2005/05/12 21:45:23 luckyduck Exp $

inherit java-pkg

DESCRIPTION="Aspect-Oriented Programming (AOP) Alliance classes"
#SRC_URI="mirror://gentoo/${P}.tar.bz2"
SRC_URI="http://sigmachi.yi.org/~nichoj/projects/java/${P}.tar.bz2"
HOMEPAGE="http://aopalliance.sourceforge.net/"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? (dev-java/jikes)"
RDEPEND=">=virtual/jre-1.4"

src_compile() {
	local antflags="-Dproject.name=${PN} jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "ant failed"
}

src_install() {
	java-pkg_dojar build/aopalliance.jar || die "dojar failed"
	use doc && java-pkg_dohtml -r build/api || die "dohtml failed"
}
