# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2 java-ant-2

DESCRIPTION="HOWL is a logger implementation for the ObjectWeb JOTM project and
TransactionManagers"
HOMEPAGE="http://howl.objectweb.org/"
SRC_URI="http://dev.gentoo.org/~nichoj/distfiles/${P}.tar.bz2"
# cvs -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/howl login
# cvs -z3 -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/howl export -r HOWL_0_1_9 howl/logger
# tar cjvf howl-logger-0.1.9.tar.bz2 howl

LICENSE="BSD"
SLOT="0.1"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/howl/logger"

src_compile() {
	eant compile-lib $(use_doc jdoc-all -Djdoc.dir=doc/api)
}

src_install() {
	java-pkg_dojar bin/howl.jar

	use doc && java-pkg_dohtml -r doc/api
}
