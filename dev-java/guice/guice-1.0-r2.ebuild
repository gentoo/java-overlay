# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Guice is a lightweight dependency injection framework for Java 5 and above."
HOMEPAGE="http://code.google.com/p/google-guice/"
SRC_URI="http://google-guice.googlecode.com/files/${P}-src.zip"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="servletapi"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="dev-java/aopalliance
	dev-java/asm:3
	dev-java/cglib:2.2
	servletapi? ( java-virtuals/servlet-api:2.5 )"
RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"
DEPEND=">=virtual/jdk-1.5
	test? ( dev-java/junit )
	${COMMON_DEPEND}"

S="${WORKDIR}"

# TODO make these work
RESTRICT="test"

JAVA_PKG_BSFIX_NAME="build.xml common.xml servlet/build.xml"
JAVA_ANT_CLASSPATH_TAGS="${JAVA_ANT_CLASSPATH_TAGS} javadoc"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/build_xml.patch"
	rm -rv struts2 spring || die
	if ! use servletapi; then
		rm -rv servlet || die
		mkdir -p servlet/lib/build || die
	fi
	einfo "Removing bundled jars and classes"
	find "${S}" -name '*.class' -print -delete
	find "${S}" -name '*.jar' -print -delete
	java-ant_rewrite-classpath common.xml
	use servletapi && java-ant_rewrite-classpath servlet/build.xml
	java-ant_rewrite-classpath build.xml
}

src_compile() {
	eant -Dgentoo.classpath=$(java-pkg_getjars aopalliance-1,cglib-2.2,asm-3) jar $(use_doc)
	use servletapi && eant -Dgentoo.classpath=$(java-pkg_getjars servlet-api-2.5) -f servlet/build.xml jar
}

src_install() {
	java-pkg_newjar build/dist/${P}.jar ${PN}.jar
	use servletapi && java-pkg_newjar servlet/build/${PN}-servlet-${PV}.jar ${PN}-servlet.jar

	use doc && java-pkg_dojavadoc javadoc/
	use source && java-pkg_dosrc src/com
}

src_test() {
	java-pkg_jar-from --into lib/build junit
	ANT_TASKS="" eant test
}
