# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A cool and fully featured editor in Java"
HOMEPAGE="http://www.jext.org/"
MY_PV="${PV/_}"
SRC_URI="mirror://sourceforge/${PN}/${PN}-sources-${MY_PV}.tar.gz"
LICENSE="|| ( GPL-2 JPython )"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc"

COMMON_DEP="
	>=dev-java/jython-2.1-r5
	=dev-java/jgoodies-looks-1.2*"
DEPEND=">=virtual/jdk-1.3
	dev-java/ant-core
	${COMMON_DEP}"
RDEPEND=">=virtual/jre-1.3
	${COMMON_DEP}"

S="${WORKDIR}/${PN}-src-${MY_PV}"

src_unpack(){
	unpack ${A}
	rm "${S}"/extplugins/Admin/*.jar
}

src_compile() {
	cd "${S}/src"
	local antflags="jar -Dclasspath=$(java-pkg_getjars jython,jgoodies-looks-1.2)"
	use doc && antflags="${antflags} javadocs"
	eant ${antflags} || die "compile failed"
}

src_install () {
	java-pkg_dojar lib/*.jar
	exeinto /usr/bin
	newexe "${FILESDIR}/jext-gentoo.sh" jext
	use doc && java-pkg_dohtml -A .css .gif .jpg -r docs/api
}
