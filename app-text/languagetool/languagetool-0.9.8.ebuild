# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
JAVA_PKG_IUSE="doc source test"

inherit eutils java-pkg-2 java-ant-2 openoffice-ext

DESCRIPTION="An Open Source language checker for English, German, Polish, Dutch, and other languages."
HOMEPAGE="http://www.languagetool.org/"
SRC_URI="http://dev.gentoo.org/~serkan/distfiles/${PF}.tar.bz2"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="openoffice"

COMMON_DEPEND="dev-java/jdictrayapi:0
	dev-java/jaminid:0
	>=dev-java/morfologik-stemming-1.1.4:0
	>=dev-java/jwordsplitter-2.2:0
	openoffice? ( >=virtual/ooo-3.0.1[java] )"

DEPEND=">=virtual/jdk-1.5
	test? ( dev-java/ant-junit:0 )
	${COMMON_DEPEND}"

RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"

OOO_EXTENSIONS="${PN}.oxt"

EANT_GENTOO_CLASSPATH="jdictrayapi,jaminid,morfologik-stemming,jwordsplitter"
JAVA_ANT_REWRITE_CLASSPATH="true"

src_prepare() {
	epatch "${FILESDIR}"/${P}-build.xml.patch
	rm -vr src/test/de/danielnaber/languagetool/server/HTTPServerTest.java || die "failed removing HTTPServerTest"
	java-pkg-2_src_prepare
}

src_compile() {
	local build_target="init build"
	use openoffice && build_target="dist"
	eant -Dgentoo.classpath=$(java-pkg_getjars ${EANT_GENTOO_CLASSPATH}) \
		-Dopenoffice.root.dir=${OOO_ROOT_DIR} \
		${build_target}
		
}

src_test() {
	ANT_TASKS="ant-junit" \
		eant \
		-Dgentoo.classpath="$(java-pkg_getjars ${EANT_GENTOO_CLASSPATH}):$(java-pkg_getjars --build-only junit)" \
		-Dopenoffice.root.dir=${OOO_ROOT_DIR} \
		test
}

src_install() {
	java-pkg_dojar dist/LanguageTool.jar
	java-pkg_dojar dist/LanguageToolGUI.jar

	java-pkg_dolauncher ${PN} --main de.danielnaber.languagetool.Main
	java-pkg_dolauncher ${PN}-gui --main de.danielnaber.languagetool.gui.Main

	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/de
	dodoc {README,CHANGES}.txt || die "dodoc failed"
	if use openoffice; then
		mv dist/LanguageTool-${PV}.oxt ${PN}.oxt || die
	fi
	openoffice-ext_src_install
}

pkg_postinst() {
	openoffice-ext_pkg_postinst
	ewarn "HTTPServer of LanguageTool works unexpectedly with ASCII encoding."
}
