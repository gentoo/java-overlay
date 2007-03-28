# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/pmd/pmd-3.7.ebuild,v 1.2 2006/10/05 14:40:20 gustavoz Exp $

JAVA_PKG_IUSE="doc source test"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A Java source code analyzer. It finds unused variables, empty catch blocks, unnecessary object creation and so forth."
HOMEPAGE="http://pmd.sourceforge.net"
SRC_URI="mirror://sourceforge/pmd/${PN}-src-${PV}.zip"

LICENSE="pmd"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

COMMON_DEPEND="
	dev-java/ant-core
	>=dev-java/asm-3.0
	>=dev-java/backport-util-concurrent-3.0
	>=dev-java/jaxen-1.1_beta10"

RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"

# NOTE: they include regression tests in the main jar so junit is needed on the cp even for src_compile

# Fails unit tests with sun-jdk-1.6
DEPEND="
	app-arch/unzip
	=dev-java/junit-3.8*
	test? ( 
		dev-java/ant-junit
		dev-java/ant-trax
		=virtual/jdk-1.5*
	)
	!test? ( >=virtual/jdk-1.5 )
	${COMMON_DEPEND}"

src_unpack() {
	unpack "${A}"

	# We patch build.xml to include all jars in lib dir
	cd "${S}"
	epatch "${FILESDIR}/${PN}-3.9-build.xml.patch"

	cd "${S}/lib/"
	rm -v *.jar || die
	java-pkg_jar-from ant-core
	java-pkg_jar-from asm-3 asm.jar
	java-pkg_jar-from backport-util-concurrent
	java-pkg_jar-from jaxen-1.1 jaxen.jar
	java-pkg_jar-from --build-only junit
}

EANT_BUILD_XML="bin/build.xml"

src_test() {
	# fails with sun-jdk-1.6
	# http://sourceforge.net/tracker/index.php?func=detail&aid=1690135&group_id=56262&atid=479921
	ANT_TASKS="ant-junit ant-trax" eant -f bin/build.xml test -DoutputTestResultsToFile=true
}

src_install() {
	java-pkg_newjar lib/${P}.jar
	java-pkg_register-ant-task

	# Create launchers and copy rulesets
	java-pkg_dolauncher ${PN} --main net.sourceforge.pmd.PMD --java_args "-Xmx512m" \
		-pre ${FILESDIR}/${P}-launcher-pre-commands
	java-pkg_dolauncher ${PN}-designer --main net.sourceforge.pmd.util.designer.Designer
	cp -r rulesets ${D}/usr/share/${PN}

	use doc && java-pkg_dojavadoc docs/api
	use source && java-pkg_dosrc src/*
}

pkg_postinst() {
	einfo
	einfo "Example rulesets can be found under"
	einfo "/usr/share/pmd/rulesets/"
	einfo
}
