# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/pmd/pmd-3.7.ebuild,v 1.2 2006/10/05 14:40:20 gustavoz Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A Java source code analyzer. It finds unused variables, empty catch blocks, unnecessary object creation and so forth."
HOMEPAGE="http://pmd.sourceforge.net"
SRC_URI="mirror://sourceforge/pmd/${PN}-src-${PV}.zip"

LICENSE="pmd"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc source test"

COMMON_DEPEND="
	>=dev-java/asm-3.0
	dev-java/backport-util-concurrent
	>=dev-java/jaxen-1.1_beta10"

RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"

# NOTE: they include regression tests in the main jar so junit is needed on the cp even for src_compile

DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	dev-java/ant
	=dev-java/junit-3.8*
	source? ( app-arch/zip )
	${COMMON_DEPEND}"

src_unpack() {
	unpack "${A}"

	# We patch build.xml to include all jars in lib dir
	cd "${S}"
	epatch "${FILESDIR}/${P}-build.xml.patch"

	cd "${S}/lib/"
	rm -f *.jar
	java-pkg_jar-from ant-core
	java-pkg_jar-from asm-3 asm.jar asm-3.0.jar
	java-pkg_jar-from backport-util-concurrent
	java-pkg_jar-from jaxen-1.1 jaxen.jar jaxen-1.1-beta-10.jar
	java-pkg_jar-from --build-only junit
}

src_compile() {
	eant -f bin/build.xml jar $(use_doc)
}

src_test() {
	eant -f bin/build.xml test
}

src_install() {
	# Install jar to its default location + to ant's location
	java-pkg_newjar lib/${P}.jar ${PN}.jar
	dodir /usr/share/ant-core/lib/
	dosym /usr/share/${PN}/lib/${PN}.jar /usr/share/ant-core/lib/${PN}.jar

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
