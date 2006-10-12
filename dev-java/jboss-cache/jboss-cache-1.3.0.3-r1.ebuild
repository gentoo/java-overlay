# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

MY_PN="JBossCache"
MY_PV="1.3.0.SP3" # FIXME could probably use versionator
MY_P="${MY_PN}-${MY_PV}"
# TODO use less lame description
DESCRIPTION="A cache for frequently accessed Java objects which dramatically improves the performance of e-business applications"
HOMEPAGE="http://www.jboss.org/products/jbosscache"
SRC_URI="mirror://sourceforge/jboss/${PN}-srcOnly-${MY_PV}.zip"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4
	dev-java/jgroups
	dev-java/jta
	dev-java/jboss-aop
	dev-java/commons-logging
	=dev-java/jboss-module-system-4*
	dev-java/concurrent-util
	=dev-java/jboss-module-server-4*
	=dev-java/jboss-module-jmx-4*
	dev-db/db-je
	=dev-java/jboss-module-common-4*
	dev-java/junit"

S="${WORKDIR}/${MY_P}"

src_compile() {
	mkdir classes
	ejavac -d classes -sourcepath src/ \
		-classpath $(java-config -p jgroups,jta,jboss-aop,commons-logging,jboss-module-system-4,concurrent-util,jboss-module-server-4,jboss-module-jmx-4,db-je,jboss-module-common-4,junit) \
		$(find src/ -name *.java)
	cp src/resources/* classes
	cd classes
	jar -cf ../${PN}.jar *
}

src_install() {
	java-pkg_dojar ${PN}.jar
}
