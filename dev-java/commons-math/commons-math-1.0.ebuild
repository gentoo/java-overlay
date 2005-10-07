# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION=" Math is a library of lightweight, self-contained mathematics and statistics components addressing the most common practical problems not immediately available in the Java programming language."
HOMEPAGE="http://jakarta.apache.org/commons/math/"
SRC_URI="mirror://apache/jakarta/commons/math/source/${P}-src.tar.gz"
DEPEND=">=virtual/jdk-1.3
	>=dev-java/ant-core-1.5.4
	junit? ( dev-java/junit 
			dev-java/ant-tasks)
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.3
	>=dev-java/commons-discovery-0.2
	>=dev-java/commons-logging-1.0.3"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~sparc ~ppc ~amd64 ~ppc64"
IUSE="doc jikes junit source"

src_unpack() {
	unpack ${A}

	cd ${S}
	sed -i 's|depends="get-deps"||' build.xml || die "sed failed"

	if ! use junit ; then
			sed -i 's/depends="compile,test"/depends="compile"/' \
				build.xml || die "Failed to disable junit"
	fi

	mkdir -p target/lib
	cd target/lib
	java-pkg_jar-from commons-discovery || die "Could not link to discovery"
	java-pkg_jar-from commons-logging || die "Could not link to commons-logging"

}

src_compile() {
	local antflags="jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	ant ${antflags} || die "died on ant"
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar

	use doc && java-pkg_dohtml -r dist/docs/
	use source && java-pkg_dosrc src/java/org
}
