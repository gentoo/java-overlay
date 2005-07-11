# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# The jar / task seems a little broken at this moment, so packages shouldn't
# replace their packed version of it for now
#
# Basically, if a package use's this task's multipleAnt or whatever target, it
# doesn't actually get done, as far as I can tell

inherit java-pkg

DESCRIPTION="ObjectWeb Ant Tasks"
HOMEPAGE="http://forge.objectweb.org/projects/monolog/"
SRC_URI="http://download.fr2.forge.objectweb.org/monolog/${P//-/_}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="jikes"

DEPEND="virtual/jdk
	jikes? (dev-java/jikes)"
RDEPEND="virtual/jre
	dev-java/ant-core"
S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd externals
	rm *.jar
	java-pkg_jar-from ant-core ant.jar
}

src_compile() {
	local antflags="clean jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_dojar output/lib/*.jar
	dodir /usr/share/ant-core/lib
	dosym /usr/share/ow-util-ant-tasks/lib/ow_util_ant_tasks.jar \
		/usr/share/ant-core/lib
}
