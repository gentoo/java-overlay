# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jdbc-mysql/jdbc-mysql-3.1.10.ebuild,v 1.4 2005/09/08 23:52:53 axxo Exp $

inherit eutils java-pkg

At=mysql-connector-java-${PV}

DESCRIPTION="MySQL JDBC driver"
HOMEPAGE="http://www.mysql.com"
SRC_URI="mirror://mysql/Downloads/Connector-J/${At}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc x86"
IUSE="log4j c3p0"
RDEPEND=">=virtual/jre-1.2
	dev-java/jta
	log4j? ( dev-java/log4j )
	c3p0? ( dev-java/c3p0 )
	dev-java/jdbc2-stdext"
DEPEND=">=virtual/jdk-1.2
	${RDEPEND}
	dev-java/junit
	dev-java/ant-core"

S=${WORKDIR}/${At}

src_unpack() {
	unpack ${A}
	cd ${S}
	rm -f *.jar
	epatch ${FILESDIR}/compile-without-log4j.patch

	# Need to change what dist depends on, because it tries to build unit tests.
	# One of these use a Sun-specific class, which won't be available on
	# non-Sun/Blackdown JDK's.
	sed -i -e 's,{buildDir}/MANIFEST.MF,{buildDir}/META-INF/MANIFEST.MF,' \
		-e's/name=\"dist\" depends="init, compile\"/name=\"dist\" depends="init, compile-driver\"/' \
		build.xml || die "sed failed"

	mkdir src/lib-nodist
	cd src/lib
	rm -f *.jar
	java-pkg_jar-from jta
	java-pkg_jar-from jdbc2-stdext
	use log4j && java-pkg_jar-from log4j
	use c3p0 && java-pkg_jar-from c3p0
}

src_compile() {
	local antflags="dist"
	ant ${antflags} || die "build failed!"
}

src_install() {
	java-pkg_newjar build/${At}/${At}-bin.jar ${PN}.jar
	dodoc README CHANGES COPYING
}

