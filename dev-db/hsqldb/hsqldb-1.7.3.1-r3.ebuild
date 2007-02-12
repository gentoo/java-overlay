# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/hsqldb/hsqldb-1.7.3.1-r3.ebuild,v 1.6 2007/01/09 15:34:06 caster Exp $

inherit java-pkg-2 eutils versionator java-ant-2

MY_PV=$(replace_all_version_separators _ )
MY_P="${PN}_${MY_PV}"

DESCRIPTION="The leading SQL relational database engine written in Java."
HOMEPAGE="http://hsqldb.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="doc source"

CDEP="=dev-java/servletapi-2.3*"

# doesn't like Java 1.6 due to JDBC changes
RDEPEND="
	|| ( =virtual/jre-1.4* =virtual/jre-1.5* )
	${CDEP}"
DEPEND="
	|| ( =virtual/jdk-1.4* =virtual/jdk-1.5* )
	app-arch/unzip
	dev-java/ant-core
	source? ( app-arch/zip )
	${CDEP}"

S="${WORKDIR}/${PN}"

pkg_setup() {
	enewgroup hsqldb
	enewuser hsqldb -1 /bin/sh /dev/null hsqldb

	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd ${S}/lib
		rm *.jar
		java-pkg_jar-from servletapi-2.3
	cd ${S}
	sed -i \
		-e "s:/etc/sysconfig:/etc/conf.d:" \
		-e "s:/usr/local/etc/hsqldb.cfg:/etc/conf.d/hsqldb:" \
			bin/hsqldb

	ant -q -f build/build.xml cleanall || die "failed to clean"

	mkdir conf
	local HSQLDB_JAR=/usr/share/hsqldb/lib/hsqldb.jar
	sed -e 's:^JAVA_EXECUTABLE=.*$:JAVA_EXECUTABLE=$(java-config --java):g' \
		-e "s/^HSQLDB_JAR_PATH=.*$/HSQLDB_JAR_PATH=${HSQLDB_JAR//\//\\/}/g" \
		-e "s/^SERVER_HOME=.*$/SERVER_HOME=\/var\/lib\/hsqldb/g" \
		-e "s/^HSQLDB_OWNER=.*$/HSQLDB_OWNER=hsqldb/g" \
		-e 's/^#AUTH_FILE=.*$/AUTH_FILE=${SERVER_HOME}\/sqltool.rc/g' \
		src/org/hsqldb/sample/sample-hsqldb.cfg > conf/hsqldb
	cp ${FILESDIR}/server.properties-r1 conf/server.properties
	cp ${FILESDIR}/sqltool.rc-r1 conf/sqltool.rc
}

src_compile() {
	eant -f build/build.xml jar jarclient jarsqltool $(use_doc javadocdev)
}

src_install() {
	java-pkg_dojar lib/hsql*.jar

	if use doc; then
		dodoc doc/*.txt
		java-pkg_dohtml -r doc/guide
		java-pkg_dohtml -r doc/src
	fi
	use source && java-pkg_dosrc src/*

	doinitd ${FILESDIR}/hsqldb
	doconfd conf/hsqldb
	insinto /etc/hsqldb
	# Change the ownership of server.properties and sqltool.rc
	# files to hsqldb:hsqldb. (resolves Bug #111963)
	insopts -m 0600 -o hsqldb -g hsqldb
	doins conf/server.properties
	insopts -m 0600 -o hsqldb -g hsqldb
	doins conf/sqltool.rc

	dodir /var/lib/hsqldb/bin
	keepdir /var/lib/hsqldb
	exeinto /var/lib/hsqldb/bin
	doexe bin/hsqldb
	dosym /etc/hsqldb/server.properties /var/lib/hsqldb/server.properties
	dosym /etc/hsqldb/sqltool.rc /var/lib/hsqldb/sqltool.rc
	chown -R hsqldb:hsqldb ${D}/var/lib/hsqldb
	chmod o-rwx ${D}/var/lib/hsqldb
}

pkg_postinst() {
	ewarn "If you intend to run hsqldb in Server mode and you want to create"
	ewarn "additional databases, remember to put correct information in both"
	ewarn "'server.properties' and 'sqltool.rc' files."
	ewarn "(read the 'Init script Setup Procedure' section of the 'Chapter 3."
	ewarn "UNIX Quick Start' in the hsqldb docs for more information)"
	elog ""
	elog "Example:"
	elog ""
	elog "/etc/hsqldb/server.properties"
	elog "============================="
	elog "server.database.1=file:/var/lib/hsqldb/newdb/newdb"
	elog "server.dbname.1=newdb"
	elog "server.urlid.1=newdb"
	elog ""
	elog "/etc/hsqldb/sqltool.rc"
	elog "======================"
	elog "urlid newdb"
	elog "url jdbc:hsqldb:hsql://localhost/newdb"
	elog "username sa"
	elog "password "
	ewarn ""
	ewarn "Also note that each hsqldb server can serve only up to 10"
	ewarn "different databases simultaneously (with consecutive {0-9}"
	ewarn "suffixes in the 'server.properties' file)."
}
