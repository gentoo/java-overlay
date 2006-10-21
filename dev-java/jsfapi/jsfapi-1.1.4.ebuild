# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

JSF_P="jsf-1_1_01"
DOC_A="${JSF_P}.zip"
DOWNLOADSITE="http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=jsf-1_1_01-fcs-oth-JPR&SiteId=JSC&TransactionId=noreg"

MY_PN="myfaces-core"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="JavaServer Faces technology is a framework for building user interfaces for web applications"
HOMEPAGE="http://myfaces.apache.org/"
SRC_URI="mirror://apache/myfaces/source/${MY_P}-src.tar.gz
	doc? (${DOC_A})"

RESTRICT="fetch"
LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~x86"
IUSE="doc"

COMMON_DEP="
	=dev-java/commons-logging-1.0*
	=dev-java/servletapi-2.4*
	=dev-java/jakarta-jstl-1.1*"

DEPEND=">=virtual/jdk-1.4
	doc? ( app-arch/zip )
	${COMMON_DEP}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${MY_P}"

pkg_nofetch() {
	einfo " Due to license restrictions, we cannot fetch the"
	einfo " docs automagically."
	einfo
	einfo " 1. Visit ${DOWNLOADSITE} and follow instructions"
	einfo " 2. Download ${DOC_A}"
	einfo " 3. Move file to ${DISTDIR}"
	einfo " 4. Run emerge on this package again to complete"
}

src_compile() {
	local build_dir=${S}/build
	local classpath="-classpath $(java-pkg_getjars servletapi-2.4,commons-logging,jakarta-jstl):${build_dir}:."
	mkdir ${build_dir}

	cd source
	ejavac ${classpath} -nowarn -d ${build_dir} $(find javax/ -name "*.java") || die "Unable to build package"

	cd ..
	jar cf ${PN}.jar -C build . || die "Unable to create jar"
}

src_install() {
	java-pkg_dojar ${PN}.jar
	use doc && java-pkg_dojavadoc ${WORKDIR}/${JSF_P}/javadocs/
}
