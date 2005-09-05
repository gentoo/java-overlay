# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: nichoj
# Purpose: facilitate packaging commons-jellyt-tags-*
#

inherit java-pkg eutils

ECLASS="commons-jelly-tags"
INHERITED="$INHERITED $ECLASS"
LDEPEND="dev-java/commons-jelly
	=dev-java/commons-beanutils-1.6*
	dev-java/commons-collections
	=dev-java/commons-jexl-1.0*
	dev-java/commons-logging
	=dev-java/dom4j-1*
	=dev-java/jaxen-1.1*
	=dev-java/xerces-2*
	dev-java/junit"

RDEPEND="virtual/jre
	${LDEPEND}"
DEPEND="virtual/jdk
	dev-java/ant-core
	dev-java/ant-tasks
	jikes? (dev-java/jikes)
	${LDEPEND}"
SLOT="${PV}"
IUSE="doc jikes"
LICENSE=""

SRC_URI="http://gentoo/${P}.tar.bz2"

EXPORT_FUNCTIONS src_unpack src_compile src_install

commons-jelly-tags_fix-jars() {
	# empty! implement for each ebuild
	true;
}

commons-jelly-tags_fix-common-jars() {
	cd ${S}/target/lib
	java-pkg_jar-from commons-jelly-1
	java-pkg_jar-from commons-beanutils-1.6
	java-pkg_jar-from commons-cli-1
	java-pkg_jar-from commons-collections
	java-pkg_jar-from dom4j-1
	java-pkg_jar-from jaxen-1.1
	java-pkg_jar-from junit
	java-pkg_jar-from xerces-2
}

commons-jelly-tags_src_unpack() {
	unpack ${A}
	cd ${S}
	# Gentoo-specific patch, ie disable dependency fetching and automatic test
	# running
	if [ -f ${FILESDIR}/${P}-gentoo.patch ]; then
		epatch ${FILESDIR}/${P}-gentoo.patch
	fi
	mkdir -p target/lib
	cd target/lib
	commons-jelly-tags_fix-common-jars
	commons-jelly-tags_fix-jars
}

commons-jelly-tags_src_compile() {
	local antflags="jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	ant ${antflags} || die "compile failed"
}

commons-jelly-tags_src_install() {
#	java-pkg_newjar target/${PN}*.jar ${PN}.jar
	for jar in target/*.jar ; do
		# could there be a better way?
		# basically, don't want there to be SNAPSHOT in the jar name
		local jarname=$(basename ${jar})
		jarname=${jarname%%-${PV}*}
		java-pkg_newjar ${jar} ${jarname}.jar
	done
	use doc && java-pkg_dohtml -r dist/docs/api
}

commons-jelly_tags_src_test() {
	ant test || die "Tests failed"
}
