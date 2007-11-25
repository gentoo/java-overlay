# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/pmd/pmd-3.9.ebuild,v 1.2 2007/05/24 13:38:03 flameeyes Exp $

JAVA_PKG_IUSE="doc source test"
inherit java-pkg-2 java-ant-2

DESCRIPTION="A Java source code analyzer. It finds unused variables, empty catch blocks, unnecessary object creation and so forth."
HOMEPAGE="http://pmd.sourceforge.net"
SRC_URI="mirror://sourceforge/pmd/${PN}-src-${PV}.zip"

LICENSE="pmd"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-fbsd"
IUSE=""

COMMON_DEPEND="
	dev-java/ant-core
	>=dev-java/asm-3.0
	>=dev-java/jaxen-1.1_beta10"

RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"

# NOTE: they include regression tests in the main jar so junit is needed on the cp even for src_compile
DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	>=dev-java/junit-4.4
	test? (
		dev-java/ant-junit
		dev-java/ant-trax
		dev-java/hamcrest
	)
	${COMMON_DEPEND}"

pkg_setup() {
	use test && ewarn "Please note that tests currently fail"

	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack "${A}"

	# We patch build.xml to include all jars in lib dir
	cd "${S}/bin"
	epatch "${FILESDIR}/${P}-build.xml.patch"

	cd "${S}"
	find -name "*.jar" | xargs rm -v

	cd "${S}/lib"
	java-pkg_jar-from ant-core
	java-pkg_jar-from asm-3 asm.jar
	java-pkg_jar-from jaxen-1.1 jaxen.jar
	java-pkg_jar-from --build-only junit-4
	java-pkg_jar-from --build-only hamcrest
}

EANT_BUILD_XML="bin/build.xml"

src_test() {
	ANT_TASKS="ant-junit ant-trax" eant -f bin/build.xml test -DoutputTestResultsToFile=true
}

src_install() {
	java-pkg_newjar lib/${P}.jar
	java-pkg_register-ant-task

	# Create launchers and copy rulesets
	java-pkg_dolauncher ${PN} --main net.sourceforge.pmd.PMD --java_args "-Xmx512m" \
		-pre "${FILESDIR}"/${P}-launcher-pre-commands
	java-pkg_dolauncher ${PN}-designer --main net.sourceforge.pmd.util.designer.Designer
	cp -r rulesets "${D}"/usr/share/${PN}
	mkdir "${D}"/usr/share/${PN}/etc
	cp -r etc/xslt "${D}"/usr/share/${PN}/etc/

	use doc && java-pkg_dojavadoc docs/api
	use source && java-pkg_dosrc src/*
}

pkg_postinst() {
	elog "Example rulesets can be found under"
	elog "/usr/share/pmd/rulesets/"
}
