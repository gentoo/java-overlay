# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="An implementation of the Chain of Responsibility pattern"
HOMEPAGE="http://jakarta.apache.org/commons/chain/"
SRC_URI="mirror://apache/jakarta/commons/chain/source/${P}-src.tar.gz"

LICENSE="Apache-1.1"
SLOT="1.1"
KEYWORDS="~x86 ~ppc ~amd64 ~ppc64"
IUSE="doc source test"

SKIP_JAR_GET="-Dnoget=true"

COMMON_DEP="
	=dev-java/commons-beanutils-1.7*
	>=dev-java/commons-digester-1.6
	>=dev-java/commons-logging-1.0.3
	=dev-java/portletapi-1*
	=dev-java/servletapi-2.3*
	=dev-java/jsfapi-1*"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant
	source? ( app-arch/zip )
	test? ( >=dev-java/junit-3.7 )
	${COMMON_DEP}"

S="${WORKDIR}/${P}-src"

src_unpack() {
	unpack ${A}

	cd ${S}
	sed -i 's/depends="compile,test"/depends="compile"/' \
		build.xml || die "Failed to disable tests"

	mkdir -p target/lib/
	cd target/lib/

	java-pkg_jarfrom commons-digester
	java-pkg_jarfrom commons-beanutils-1.7
	java-pkg_jarfrom commons-logging
	java-pkg_jarfrom portletapi-1
	java-pkg_jarfrom servletapi-2.3
	java-pkg_jarfrom jsfapi-1
	use test && java-pkg_jarfrom junit
}

src_compile() {
	eant ${SKIP_JAR_GET} jar $(use_doc)
}

src_test() {
	eant ${SKIP_JAR_GET} test
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar

	use doc && java-pkg_dohtml -r dist/docs/
	use source && java-pkg_dosrc src/java/
}
