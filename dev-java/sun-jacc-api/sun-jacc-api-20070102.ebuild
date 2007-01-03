# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java Authorization Contract for Containers"
HOMEPAGE="http://java.sun.com/j2ee/javaacc/index.html"
# cvs -d :pserver:nichoj@cvs.dev.java.net:/cvs checkout glassfish/jacc-api
# cd glassfish
# mv jacc-api sun-jacc-api-${P}
# tar --exclude=CVS -cjvf sun-jacc-api-${P}.tar.bz2 sun-jacc-api-${P}
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"


src_compile() {
	eant -Djavac.source=$(java-pkg_get-source) -Djavaee.jar=jcc-api.jar
}

src_install() {
	java-pkg_dojar jcc-api.jar
}
