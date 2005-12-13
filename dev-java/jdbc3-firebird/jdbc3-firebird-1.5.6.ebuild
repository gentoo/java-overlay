# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jdbc3-firebird/jdbc3-firebird-1.5.3-r1.ebuild,v 1.1 2005/12/13 05:38:20 nichoj Exp $

inherit java-pkg

At="FirebirdSQL-${PV}-src"
DESCRIPTION="JDBC3 driver for Firebird SQL server"
HOMEPAGE="http://firebird.sourceforge.net"
SRC_URI="mirror://sourceforge/firebird/${At}.zip"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE="doc examples jikes source"

RDEPEND=">=virtual/jre-1.4
		dev-java/concurrent-util
		dev-java/log4j"
DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		${RDEPEND}
		jikes? ( dev-java/jikes )
		source? ( app-arch/zip )"

S="${WORKDIR}/client-java"

src_unpack() {
	unpack "${A}"
	rm "${S}"/lib/*.jar

	cd "${S}/src/lib/"
	rm *.jar *.zip
	java-pkg_jar-from concurrent-util
	java-pkg_jar-from log4j log4j.jar log4j-core.jar
}

src_compile() {
	antflags="jars"
	use doc && antflags="${antflags} javadocs"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "Building failed."
}

src_install() {
	cd "${S}/output/lib"
	rm mini-concurrent.jar
	java-pkg_dojar *.jar

	cd "${S}"
	if use examples; then
		insinto /usr/share/doc/${PF}/
		doins -r examples || die "installing examples failed"
	fi

	use source && java-pkg_dosrc "${S}"/src/*/org

	dodoc ChangeLog

	cd "${S}/output"
	use doc && java-pkg_dohtml -r docs/
	dodoc etc/{*.txt,default.mf}
	dohtml etc/*.html
}

#src_test() {
	# Probably needs a firebird database
	# ant || die "unit tests failed"
#}
