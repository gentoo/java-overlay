# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/groovy/groovy-1.0_beta4-r1.ebuild,v 1.10 2005/12/11 20:31:53 nichoj Exp $

inherit java-pkg-2 java-ant-2

MY_PV="1.0-JSR-06"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Groovy is a high-level dynamic language for the JVM"
HOMEPAGE="http://groovy.codehaus.org/"
SRC_URI="http://dist.codehaus.org/groovy/distributions/${MY_P/JSR/jsr}-src.tar.gz"
LICENSE="codehaus-groovy"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="source"

# FIXME needs asm-2.2 I think -nichoj
COMMON_DEPS="
	=dev-java/asm-2.2*
	>=dev-java/antlr-2.7.5
	>=dev-java/xerces-2.4
	>=dev-java/ant-core-1.6.5
	>=dev-java/xstream-1.1.1
	>=dev-java/junit-3.8.1
	dev-java/qdox
	>=dev-java/commons-cli-1.0 
	>=dev-java/bsf-2.3.0_rc1
	>=dev-java/mockobjects-0.09
	~dev-java/servletapi-2.4"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPS}"
# FIXME doesn't compile with 1.6 due to JDBC api change
DEPEND="|| ( =virtual/jdk-1.4* =virtual/jdk-1.5* )
	${COMMON_DEPS}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${P}-compiler-exit-code.patch

	mkdir -p ${S}/target/lib

	cd ${S}/target/lib
	java-pkg_jar-from commons-cli-1
	java-pkg_jar-from xerces-2
	java-pkg_jar-from ant-core ant.jar
	java-pkg_jar-from antlr	
	java-pkg_jar-from asm-2.2
	java-pkg_jar-from qdox-1.6
	java-pkg_jar-from xstream
	java-pkg_jar-from mockobjects 
	java-pkg_jar-from junit
	java-pkg_jar-from servletapi-2.4
	java-pkg_jar-from bsf-2.3
	
	cd ${S}

	# We use ant NOT maven
	cp ${FILESDIR}/build.xml-${PV} ${S}/build.xml || die "Failed to update build.xml"

	cd src/main 
	# This won't compile without an incestuous relationship with radeox.
	rm -rf org/codehaus/groovy/wiki
}

src_compile() {
	eant -Dnoget=true jar

	cd src/main
	java -classpath ../../target/${MY_P}.jar:$(java-pkg_getjars commons-cli-1,asm-2.2,antlr,junit,qdox-1.6) \
		org.codehaus.groovy.tools.FileSystemCompiler \
		$(find -name *.groovy) || die "Failed to invoke groovyc" 

	
	jar uf ../../target/${MY_P}.jar  $(find -name *.class) || die "Failed to backpatch Console*.class"
}

src_install() {
	java-pkg_newjar target/${MY_P}.jar
	java-pkg_dolauncher "grok" --main org.codehaus.groovy.tools.Grok
	java-pkg_dolauncher "groovyc" --main org.codehaus.groovy.tools.FileSystemCompiler
	java-pkg_dolauncher "groovy" --main groovy.ui.GroovyMain
	java-pkg_dolauncher "groovysh" --main groovy.ui.InteractiveShell
	java-pkg_dolauncher "groovyConsole" --main groovy.ui.Console
}
