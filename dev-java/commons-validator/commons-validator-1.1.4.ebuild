# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_P=${P}-src
DESCRIPTION="Jakarta component to validate user input, or data input"
HOMEPAGE="http://jakarta.apache.org/commons/validator/"
SRC_URI="mirror://apache/jakarta/commons/validator/source/${MY_P}.tar.gz mirror://gentoo/${P}-gentoo-missingfiles.tar.bz2"
# 1) Download commons-validator-1.1.3-gentoo-missingfiles.tar.bz2
# 2) Extract
# 3) mv commons-validator-1.1.3 commons-validator-1.1.4
# 4) tar cjvf commons-validator-1.1.4-gentoo-missingfiles.tar.bz2
# commons-validator-1.1.4
# 5) copy to /usr/portage/distfiles
# Why, oh why, does upstream not include everything to build!?
# TODO: report this travesty

DEPEND=">=virtual/jdk-1.3
	>=dev-java/ant-core-1.4
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.3
	=dev-java/jakarta-oro-2.0*
	>=dev-java/commons-digester-1.5
	>=dev-java/commons-collections-2.1
	>=dev-java/commons-logging-1.0.3
	=dev-java/commons-beanutils-1.6*
	>=dev-java/xerces-2.6.2-r1"
LICENSE="Apache-1.1"
# TODO slot me?
SLOT="0"
KEYWORDS="~amd64 ~ppc ppc64 ~sparc ~x86"
IUSE="doc examples jikes source"

src_unpack() {
	unpack ${A}
	cd ${S}
	#dirty hack
	sed -e 's:target name="compile" depends="static":target name="compile" depends="prepare":' -i build.xml

	echo "oro.jar=`java-config --classpath=jakarta-oro-2.0`" >> build.properties
	echo "commons-digester.jar=`java-config --classpath=commons-digester`" >> build.properties
	echo "commons-collections.jar=`java-config --classpath=commons-collections`" >> build.properties
	echo "commons-logging.jar=`java-config --classpath=commons-logging | sed s/.*://`" >> build.properties
	echo "commons-beanutils.jar=`java-config --classpath=commons-beanutils-1.6 | sed s/.*://`" >> build.properties
	echo "xerces.jar=`java-config --classpath=xerces-2`" >> build.properties
}

src_compile() {
	local antflags="compile"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	ant ${antflags} || die "build failed"
	jar -cvf ${PN}.jar -C target/classes/ . || die "could not create jar"
}

src_install() {
	java-pkg_dojar ${PN}.jar

	if use doc; then
		java-pkg_dohtml -r dist/docs/
		java-pkg_dohtml PROPOSAL.html STATUS.html
		dodoc LICENSE.txt
	fi
	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r src/example/* ${D}/usr/share/doc/${PF}/examples
	fi
	use source && java-pkg_dosrc src/share/*
}
