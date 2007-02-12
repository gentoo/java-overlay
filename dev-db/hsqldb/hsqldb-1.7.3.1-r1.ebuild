# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/hsqldb/hsqldb-1.7.3.1-r1.ebuild,v 1.6 2006/10/05 14:56:43 gustavoz Exp $

inherit java-pkg eutils

DESCRIPTION="HSQLDB is the leading SQL relational database engine written in Java."
HOMEPAGE="http://hsqldb.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV//./_}.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="x86 amd64 ppc64 ppc"
IUSE="doc jikes source"

RDEPEND=">=virtual/jre-1.4
	=dev-java/servletapi-2.3*"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	dev-java/ant-core
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )
	${RDEPEND}"

S=${WORKDIR}/${PN}

pkg_setup() {
	java-pkg_pkg_setup
	enewgroup hsqldb
	enewuser hsqldb -1 /bin/sh /dev/null hsqldb
}

src_unpack() {
	unpack ${A}
	cd ${S}/lib
		rm *.jar
		java-pkg_jar-from servletapi-2.3
	cd ${S}
	sed -i -r \
		-e "s/etc\/sysconfig/etc\/conf.d/g" \
			bin/hsqldb
	einfo "Cleaning build directory..."
	ant -q -f build/build.xml cleanall || die "failed too clean"

	einfo "Preparing configuration files..."
	mkdir conf
	HSQLDB_JAR=/usr/share/hsqldb/lib/hsqldb.jar
	sed -e 's:^JAVA_EXECUTABLE=.*$:JAVA_EXECUTABLE=$(which java 2>/dev/null):g' \
		-e "s/^HSQLDB_JAR_PATH=.*$/HSQLDB_JAR_PATH=${HSQLDB_JAR//\//\\/}/g" \
		-e "s/^SERVER_HOME=.*$/SERVER_HOME=\/var\/lib\/hsqldb/g" \
		-e "s/^HSQLDB_OWNER=.*$/HSQLDB_OWNER=hsqldb/g" \
		-e 's/^#AUTH_FILE=.*$/AUTH_FILE=${SERVER_HOME}\/sqltool.rc/g' \
		src/org/hsqldb/sample/sample-hsqldb.cfg > conf/hsqldb
	cp ${FILESDIR}/server.properties conf
	cp ${FILESDIR}/sqltool.rc conf
}

src_compile() {
	local antflags="jar jarclient jarsqltool"
	use doc && antflags="${antflags} javadocdev"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant -f build/build.xml ${antflags} || die "Compilation failed."
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
	insopts -m 0600
	doins conf/server.properties
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

