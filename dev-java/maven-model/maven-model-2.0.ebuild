# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://gentooexperimental.org/distfiles/${P}.tar.bz2"

LICENSE=""
SLOT="2"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/plexus-utils dev-java/xpp3"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
	${CDEPEND}"

S="${WORKDIR}/${PN}"

src_compile() {
	local antflags="jar"
	antflags="${antflags} -Dmaven.mode.offline=true"
	antflags="${antflags} -Dclasspath=$(java-config -p plexus-utils,xpp3)"
	ant ${antflags} || die "ant failed"
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar
}
