# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $ 

inherit java-pkg-2

DESCRIPTION="Small footprint Dependency Injection container"
HOMEPAGE="http://www.picocontainer.org"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"
LICENSE="PicoContainer"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="source"
RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.5
	source? ( app-arch/zip )
	"
S=${WORKDIR}/${P}/container

src_compile() {
	local build_dir=${S}/build dist_dir=${S}/dist
	mkdir -p ${dist_dir} ${build_dir}/java || die "mkdir failed"
	ejavac -classpath ${classpath} -nowarn \
		-d ${build_dir}/java $(find ${S}/src/java -name "*.java")
	jar -cf ${dist_dir}/${PN}.jar -C ${build_dir}/java . || die "failed to create jar"
}

src_install() {
	java-pkg_dojar "${S}/dist/${PN}.jar"
	use source && java-pkg_dosrc src/java/org
}
