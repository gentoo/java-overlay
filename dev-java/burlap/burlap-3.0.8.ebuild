# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="The Burlap web service protocol makes web services usable without requiring a large framework, and without learning yet another alphabet soup of protocols."
HOMEPAGE="http://www.caucho.com/burlap/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="Apache-1.1"
SLOT="3.0"
KEYWORDS="~x86"

IUSE="doc jikes source"

RDEPEND=">=virtual/jre-1.4
		=dev-java/servletapi-2.3*
		~dev-java/hessian-${PV}
		~dev-java/caucho-services-${PV}"

DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		dev-java/ant-core
		jikes? ( dev-java/jikes )
		source? ( app-arch/zip )
		${RDEPEND}"

src_compile() {
	# Populate classpath
	local classpath="$(java-pkg_getjar servletapi-2.3 servlet.jar)"
	classpath="${classpath}:$(java-pkg_getjars hessian-3.0.8)"
	classpath="${classpath}:$(java-pkg_getjars caucho-services-3.0)"

	local antflags="jar -Dclasspath=${classpath}"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
	use source && java-pkg_dosrc src/*
}
