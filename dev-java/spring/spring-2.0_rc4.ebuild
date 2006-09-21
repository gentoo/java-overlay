# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 eutils

MY_PN=${PN}-framework
MY_PV=${PV/_rc/-rc}
MY_P=${MY_PN}-${MY_PV}
DESCRIPTION="Spring is a layered Java/J2EE application framework, based on code published in Expert One-on-One J2EE Design and Development by Rod Johnson (Wrox, 2002)."
HOMEPAGE="http://www.springframework.org/"
SRC_URI="mirror://sourceforge/${MY_PN/-/}/${MY_P}-with-dependencies.zip"

LICENSE="Apache-2.0"
SLOT="2.0"

KEYWORDS="~amd64 ~x86"
IUSE="source java5"

# ARGH! 1.6 breaks it already!
DEPEND="
	java5? ( =virtual/jdk-1.5* )
	!java5? ( =virtual/jdk-1.4* )
	dev-java/ant-core
	dev-java/antlr
	app-arch/zip"
# TODO replace sun-jdbc-rowset-bin with free implementation?
RDEPEND="
	java5? ( 
		=virtual/jre-1.5*
		=dev-java/hibernate-annotations-3.0*
	)
	!java5? ( || ( =virtual/jre-1.4* =virtual/jre-1.5* ) )"
S=${WORKDIR}/${MY_P}

# Jikes is broken:
# http://opensource.atlassian.com/projects/spring/browse/SPR-1097
src_compile() {
	echo "QA Notice: building with bundled jars!"
	local antflags="alljars"

	ant ${antflags} || die "Compilation failed"

	cp -r docs/reference/html_single reference
}

src_install() {
	java-pkg_dojar dist/*.jar dist/*/*.jar

	use source && java-pkg_dosrc src/* $(use java5 && echo tiger/src/*)
}

