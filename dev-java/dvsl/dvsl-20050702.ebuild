# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_PV=0.45
MY_P=${PN}-${MY_PV}
DESCRIPTION="DVSL (Declarative Velocity Style Language) is a tool modeled after XSLT and is intended for general XML transformations using the Velocity Template Language as the templating language for the transformations. The key differences are that it incorporates easy access to Java objects and allows you to use the Velocity template language and it's features for expressing the transformation templates."
HOMEPAGE="http://jakarta.apache.org/velocity/dvsl/index.html"
SRC_URI="http://sigmachi.yi.org/~nichoj/projects/java/${P}.tar.bz2"

# I'm guessing some sort of apache-ness
LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

COMMON_DEPEND="=dev-java/crimson-1*
	=dev-java/dom4j-1*
	dev-java/gnu-jaxp
	dev-java/velocity
	dev-java/xalan
	=dev-java/xerces-1.3*
	dev-java/jdbc2-stdext"

# Therotically, jdk/jre 1.3 can be used
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? (dev-java/jikes)
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"
	
src_unpack() {
	unpack ${A}
	cd ${S}
	rm -r lib/*.jar

	local classpath;
	for jars in crimson-1 dom4j-1 gnu-jaxp velocity xalan ant-core; do
		classpath="${classpath}:`java-pkg_getjars ${jars}`"
	done

	# TODO need to test if this actually works for 1.3
#	if ! java-utils_is_vm_version_ge 1.4; then
#		for jars in xerces-1.3 jdbc2-stdext; do
#			classpath="${classpath}:`java-pkg_getjars ${jars}`"
#		done
#	fi
	echo "portage.classpath=${classpath}" > build.properties
}

src_compile() {
	local antflags="-Dproject.name=${PN} jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadocs"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_newjar ${MY_P}.jar ${PN}.jar

	use doc && java-pkg_dohtml -r target/api
}
