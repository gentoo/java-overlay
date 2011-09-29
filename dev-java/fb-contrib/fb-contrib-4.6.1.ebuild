# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

JAVA_PKG_IUSE="doc source examples"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Findbugs plugin with additionl detectors"
HOMEPAGE="http://fb-contrib.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEP="
	dev-java/bcel:0[findbugs]
	dev-util/findbugs:0"
DEPEND="${COMMON_DEP}
	>=virtual/jdk-1.5
	app-arch/unzip
	dev-java/asm:3"
RDEPEND="${COMMON_DEP}
	>=virtual/jre-1.5"

S="${WORKDIR}"

java_prepare() {
	find "${WORKDIR}" -name '*class' -exec rm -f {} \;
	find "${WORKDIR}" -name '*jar' -exec rm -fv {} \;
	rm -rf classes javadoc htdocs
}

JAVA_ANT_REWRITE_CLASSPATH="yes"
JAVA_ANT_CLASSPATH_TAGS="${JAVA_ANT_CLASSPATH_TAGS} javadoc"

src_compile() {
	local gcp="$(java-pkg_getjars --build-only asm-3)"
	gcp="${gcp}:$(java-pkg_getjars bcel,findbugs)"

	eant jar $(use_doc javadoc html) -Dgentoo.classpath="${gcp}"
}

src_install() {
	java-pkg_newjar ${P}.jar

	dodir /usr/share/findbugs/plugin
	dosym /usr/share/${JAVA_PKG_NAME}/lib/fb-contrib.jar \
		/usr/share/findbugs/plugin/

	if use doc ; then
		java-pkg_dojavadoc javadoc
		dohtml htdocs/*
	fi

	use source && java-pkg_dosrc src/com
	use examples && java-pkg_doexamples samples
}
