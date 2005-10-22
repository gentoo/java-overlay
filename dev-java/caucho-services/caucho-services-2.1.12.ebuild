# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="The com.caucho.services package used by dev-java/hessian and dev-java/burlap."
HOMEPAGE="http://www.caucho.com/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="Apache-1.1"
SLOT="2.1"
KEYWORDS="~x86"

IUSE="doc jikes source"

RDEPEND=">=virtual/jre-1.4
		=dev-java/servletapi-2.3*"
DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		dev-java/ant-core
		${RDEPEND}"

src_compile() {
	local antflags="jar -Dservletapi=$(java-pkg_getjars servletapi-2.3)"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
	use source && java-pkg_dosrc src/*
}
