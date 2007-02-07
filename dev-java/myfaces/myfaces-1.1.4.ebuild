# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

MY_PN="${PN}-core"
MY_P="${MY_PN}-${PV}"
BIN_UNPACK_DIR="bin_unpack"
JAVA_PKG_FILTER_COMPILER="jikes"

DESCRIPTION="The first free open source Java Server Faces implementation"
HOMEPAGE="http://myfaces.apache.org/"
SRC_URI="mirror://apache/myfaces/source/${MY_P}-src.tar.gz
	mirror://apache/myfaces/binaries/${MY_P}-bin.tar.gz"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~amd64 ~x86"

COMMON_DEP="
	>=dev-java/commons-logging-1.0.4
	=dev-java/commons-el-1.0*
	=dev-java/servletapi-2.4*
	=dev-java/commons-beanutils-1.7*
	=dev-java/commons-codec-1.3*
	=dev-java/portletapi-1*
	=dev-java/commons-lang-2.1*
	>=dev-java/commons-digester-1.6
	>=dev-java/commons-collections-3.1
	>=dev-java/jakarta-jstl-1.1.0
	=dev-java/jsfapi-1*"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEP}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}

	cd ${S}

	unzip lib/myfaces-impl-1.1.4.jar -d ${BIN_UNPACK_DIR} > /dev/null
}

src_compile() {
	local build_dir=${S}/build
	local classpath="-classpath $(java-pkg_getjars jsfapi-1,servletapi-2.4,commons-el,commons-logging,commons-beanutils-1.7,commons-codec,portletapi-1,commons-lang-2.1,commons-digester,commons-collections,jakarta-jstl):${build_dir}"
	mkdir ${build_dir}

	cd ${S}/source
	ejavac ${classpath} -nowarn -d ${build_dir} $(find org/ -name "*.java")

	cd ..
	mkdir ${build_dir}/META-INF
	cp ${BIN_UNPACK_DIR}/META-INF/*.tld ${build_dir}/META-INF
	cp -R ${BIN_UNPACK_DIR}/javax ${build_dir}
	cp -R ${BIN_UNPACK_DIR}/licenses ${build_dir}
	cp -R ${BIN_UNPACK_DIR}/org/apache/myfaces/resource ${build_dir}/org/apache/myfaces

	jar cf ${PN}.jar -C build . || die "Unable to create jar"
}

src_install() {
	java-pkg_dojar ${PN}.jar
}
