# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-digester/commons-digester-1.6-r1.ebuild,v 1.5 2005/11/05 11:14:53 betelgeuse Exp $

inherit eutils java-pkg

DESCRIPTION="Reads XML configuration files to provide initialization of various Java objects within the system."
HOMEPAGE="http://jakarta.apache.org/commons/digester/"
SRC_URI="mirror://apache/jakarta/commons/digester/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes junit source"

# 1.3 support might be possible by adding an additional depend on xml-commons[-external]
RDEPEND=">=virtual/jre-1.4
	=dev-java/commons-beanutils-1.6*
	>=dev-java/commons-collections-2.1
	>=dev-java/commons-logging-1.0.2"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.4
	junit? ( >=dev-java/junit-3.7 )
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )
	${RDEPEND}"

S=${WORKDIR}/${P}-src

src_unpack() {
	unpack "${A}"
	cd  "${S}"
	epatch "${FILESDIR}/${PV}-build.xml-jar-target.patch"
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} javadoc"
	use junit && antflags="${antflags} test"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"

	use junit && antflags="${antflags} -Djunit.jar=$(java-pkg_getjars junit)"
	antflags="${antflags} -Dcommons-beanutils.jar=$(java-pkg_getjar commons-beanutils-1.6 commons-beanutils.jar)"
	antflags="${antflags} -Dcommons-collections.jar=$(java-pkg_getjars commons-collections)"
	antflags="${antflags} -Dcommons-logging.jar=$(java-pkg_getjar commons-logging commons-logging.jar)"
	ant ${antflags} || die "compilation failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	dodoc RELEASE-NOTES.txt

	use doc && java-pkg_dohtml -r dist/docs/api
	use source && java-pkg_dosrc src/java/org
}
