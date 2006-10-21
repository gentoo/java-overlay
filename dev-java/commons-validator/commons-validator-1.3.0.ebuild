# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_P=${P}-src
DESCRIPTION="Jakarta component to validate user input, or data input"
HOMEPAGE="http://jakarta.apache.org/commons/validator/"
SRC_URI="mirror://apache/jakarta/commons/validator/source/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="1.3"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

IUSE="doc examples source"

# Was not able to test on 1.3 jdk at this point. Feel free to to lower this
# back to 1.3 if you have tested it on one and proved working. Then you
# probably need to bring the xerces dependency back.

RDEPEND=">=virtual/jre-1.4
	=dev-java/jakarta-oro-2.0*
	>=dev-java/commons-digester-1.6
	>=dev-java/commons-collections-3.1
	>=dev-java/commons-logging-1.0.4
	=dev-java/commons-beanutils-1.7*"

DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-1.6
	${RDEPEND}
	source? ( app-arch/zip )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	
	cd ${S}

	epatch ${FILESDIR}/validator-1.3.build.xml.patch
	
	echo "oro.jar=$(java-pkg_getjars jakarta-oro-2.0)" >> build.properties
	echo "commons-digester.jar=$(java-pkg_getjars commons-digester)" >> build.properties
	echo "commons-beanutils.jar=$(java-pkg_getjars commons-beanutils-1.6)" >> build.properties
	echo "commons-logging.jar=$(java-pkg_getjars commons-logging)" >> build.properties
	echo "commons-collections.jar=$(java-pkg_getjars commons-collections)" >> build.properties
}

src_compile() {
	local antflags="-Dskip.download=true compile"

	use doc && antflags="${antflags} javadoc"

	eant ${antflags} || die "build failed"
	jar -cf ${PN}.jar -C target/classes/ . || die "could not create jar"
}

src_install() {
	java-pkg_dojar ${PN}.jar

	if use doc; then
		java-pkg_dohtml -r dist/docs/
	fi

	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -r src/example/* ${D}/usr/share/doc/${PF}/examples
	fi

	use source && java-pkg_dosrc src/share/*
}
