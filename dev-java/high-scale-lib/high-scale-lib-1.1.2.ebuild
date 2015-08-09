# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="3"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2

DESCRIPTION="A collection of Concurrent and Highly Scalable Utilities."
HOMEPAGE="http://high-scale-lib.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-v${PV}.zip"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}/${PN}"

IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5
	app-arch/unzip"

src_prepare() {
	find . -iname '*.class' -delete || die
	find . -iname '*.jar' -delete || die
	find . -iname 'CVS' | xargs rm -R || die
	java-pkg-2_src_prepare

	(
	echo "Please be aware that gentoo packages ${PN}"
	echo "slightly differently than upstream releases."
	echo "When adding a java_util_*.jar file to the"
	echo "bootclasspath of your virtual machine please also"
	echo "include ${PN}.jar.  e.g"
	echo ""
	echo "java -Xbootclasspath/p:lib/high-scale-lib.jar:lib/java_util_hashtable.jar my_java_app_goes_here"
	echo ""
	echo "Please read the README file for more detail on this package."
	) > README.GENTOO
}

src_compile() {
	mkdir -p build || die
	ejavac -d build $(find java/ org/ -iname '*.java')
	cd build || die
	jar cf "../ ${PN}.jar" $(find org -iname '*.class')
	jar cf "../java_util_hashtable.jar" java/util/Hashtable.class
	jar cf "../java_util_concurrent_chm.jar" java/util/concurrent/*.class
}

src_install() {
	java-pkg_dojar *.jar
	use source && java-pkg_dosrc java org

	dodoc README README.GENTOO
}
