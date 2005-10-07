# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="HOWL is a logger implementation providing features required by the ObjectWeb JOTM project, with a public API that is generally usable by any Transaction Manager"
HOMEPAGE="http://howl.objectweb.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"
# cvs -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/howl login
# cvs -z3 -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/howl export -r HOWL_0_1_9 howl/logger
# tar cjvf howl-0.1.9.tar.bz2 howl

LICENSE="howl-logger"
SLOT="0.1"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk
	dev-java/ant-core
	jikes? (dev-java/jikes)"
RDEPEND="virtual/jre"

S="${WORKDIR}/howl/logger"

src_compile() {
	local antflags="compile-lib"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} jdoc-all -Djdoc.dir=doc/api"

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_dojar bin/howl.jar

	use doc && java-pkg_dohtml -r doc/api
}
