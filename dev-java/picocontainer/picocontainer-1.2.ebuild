# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/picocontainer/picocontainer-1.1-r1.ebuild,v 1.1 2006/08/01 12:22:41 nichoj Exp $

inherit java-pkg-2

DESCRIPTION="Small footprint Dependency Injection container"
HOMEPAGE="http://www.picocontainer.org"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"
LICENSE="PicoContainer"
SLOT="1"
KEYWORDS="~x86"
IUSE="source"
RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.5
	source? ( app-arch/zip )
	"
S=${WORKDIR}/${P}/container

src_unpack() {
	unpack ${A}
	cd ${S}
}

src_compile() {
	local build_dir=${S}/build
	local dist_dir=${S}/dist

	mkdir -p ${dist_dir} ${build_dir}/java || die "mkdir failed"

	ejavac -classpath ${classpath} -nowarn \
		-d ${build_dir}/java $(find ${S}/src/java -name "*.java")\
		|| die "compile	${PN} failed"
	jar -cf ${dist_dir}/${PN}.jar -C ${build_dir}/java . || die "failed to create jar"
}

#src_test() {
#	local antflags="-Dfinal.name=${PN} -Dnoget=true test"
#	eant ${antflags}
#}

src_install() {
	local dist_dir=${S}/dist
	mkdir -p ${dist_dir} || die "mkdir failed"

	java-pkg_dojar ${dist_dir}/java/${PN}.jar

	use source && java-pkg_dosrc src/java/org
}
