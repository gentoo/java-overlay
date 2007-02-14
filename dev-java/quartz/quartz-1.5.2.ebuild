# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/quartz/quartz-1.4.5.ebuild,v 1.4 2005/10/15 11:41:22 axxo Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Quartz Scheduler from OpenSymphony"
HOMEPAGE="http://www.opensymphony.com/quartz/"
SRC_URI="https://quartz.dev.java.net/files/documents/1267/30161/${P}.zip"

LICENSE="Apache-2.0"
SLOT="1.5"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE="dbcp jboss jikes jmx jta oracle servlet-2.3 servlet-2.4 struts"
RDEPEND=">=virtual/jre-1.4
		oracle? ( >=dev-java/jdbc3-oracle-9.2.0.3 )
		servlet-2.3? ( >=dev-java/servletapi-2.3 )
		servlet-2.4? ( >=dev-java/servletapi-2.4 )
		dbcp? ( >=dev-java/commons-dbcp-1.1 )
		jboss? ( >=www-servers/jboss-3.2.3 )
		jta? ( >=dev-java/jta-1.0.1 )
		jmx? ( >=dev-java/sun-jmx-1.2.1 )
		struts? ( =dev-java/struts-1.1* )
		jikes? ( dev-java/jikes )"

DEPEND=">=virtual/jdk-1.4
		${RDEPEND}
		dev-java/ant
		app-arch/unzip"

S="${WORKDIR}/${P}"


src_unpack() {
	unpack ${A}
}

src_compile() {
	local antflags=""
	use servlet-2.3 && CLASSPATH="$CLASSPATH:$(java-pkg_getjars servletapi-2.3)"
	use servlet-2.4 && CLASSPATH="$CLASSPATH:$(java-pkg_getjars servletapi-2.4)"
	use dbcp && CLASSPATH="$CLASSPATH:$(java-pkg_getjars commons-dbcp)"
	use jta && CLASSPATH="$CLASSPATH:$(java-pkg_getjars jta)"
	use oracle && CLASSPATH="$CLASSPATH:$(java-pkg_getjars jdbc2-oracle-5)"
	if use jboss; then
		cp /usr/share/jboss/lib/jboss-common.jar ${S}/lib
		cp /usr/share/jboss/lib/jboss-jmx.jar ${S}/lib
		cp /usr/share/jboss/lib/jboss-system.jar ${S}/lib
		cp /var/lib/jboss/default/lib/jboss.jar ${S}/lib
		antflags="${antflags} -Dlib.jboss-common.jar=/usr/share/jboss/lib/jboss-common.jar"
		antflags="${antflags} -Dlib.jboss-jmx.jar=/usr/share/jboss/lib/jboss-jmx.jar"
		antflags="${antflags} -Dlib.jboss-system.jar=/usr/share/jboss/lib/jboss-system.jar"
		antflags="${antflags} -Dlib.jboss.jar=/var/lib/jboss/default/lib/jboss.jar"
	fi
	use struts && CLASSPATH="$CLASSPATH:$(java-pkg_getjars struts-1.1)"
	eant ${antflags} compile jar
}


src_install() {
	java-pkg_newjar build/${P}.jar ${PN}.jar
}
