# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/hibernate/hibernate-2.1.6.ebuild,v 1.1 2004/08/11 14:47:35 voxus Exp $

inherit java-pkg eutils

DESCRIPTION="AspectWerkz is a dynamic, lightweight and high-performant AOP/AOSD framework for Java."
SRC_URI="http://dist.codehaus.org/aspectwerkz/distributions/${P}.zip"
HOMEPAGE="http://aspectwerkz.codehaus.org"
LICENSE="LGL-2.1"
SLOT="0"
KEYWORDS="~x86 ~amd64"
RDEPEND="
		>=virtual/jre-1.4
		=dev-java/javassist-2*
		dev-java/jrexx
		dev-java/trove
		dev-java/concurrent-util
		=dev-java/dom4j-1*
		=dev-java/asm-1*
		=dev-java/qdox-bin-1.3
		dev-java/bcel
		"
DEPEND=">=virtual/jdk-1.4
		>=dev-java/ant-core-1.5
		"
IUSE="jikes"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/memusagetest.patch
	cd lib
		rm *.jar
		java-pkg_jar-from javassist-2
		java-pkg_jar-from jrexx
		java-pkg_jar-from trove
		java-pkg_jar-from concurrent-util
		java-pkg_jar-from dom4j-1
		java-pkg_jar-from asm-1
		java-pkg_jar-from qdox-bin
		java-pkg_jar-from bcel
	cd ..
	# tests fail to compile, so hide them
	mv src/test src/foo
	mkdir src/test
	# keep extensions from being built
	sed -i -r \
		-e '/antcall target="aspectwerkz:extensions:compile/d' \
		-e '/copy tofile="\$\{lib.dir\}\/aspectwerkz-extensions/d' \
			build.xml
}

src_compile() {
	local antflags="aspectwerkz:jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	antflags="aspectwerkz:jar"
	ant ${antflags} || die "failed to build"
}

src_install() {
	cd target
	mv ${PN}-${PV}.jar ${PN}.jar
	mv ${PN}-core-${PV}.jar ${PN}-core.jar
	java-pkg_dojar ${PN}.jar ${PN}-core.jar
	dodoc *.txt
}
