# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 eutils versionator java-ant-2

MY_PV=$(replace_all_version_separators _ )
MY_P="${PN}_${MY_PV}"

DESCRIPTION="The leading SQL relational database engine written in Java."
HOMEPAGE="http://hsqldb.org"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc source sqltools"

# doesn't like Java 1.6 due to JDBC changes
RDEPEND="=virtual/jre-1.5*
	=dev-java/servletapi-2.3*"
DEPEND="=virtual/jdk-1.5*
	app-arch/unzip
	dev-java/ant-core
	source? ( app-arch/zip )
	${RDEPEND}"


S="${WORKDIR}/${PN}"

HSQLDB_JAR=/usr/share/hsqldb/lib/hsqldb.jar
HSQLDB_HOME=/var/lib/hsqldb

pkg_setup() {
	enewgroup hsqldb
	enewuser hsqldb -1 /bin/sh /dev/null hsqldb

	java-pkg-2_pkg_setup
}

ant_src_unpack() {
	unpack ${A}
	cd ${S}/lib
		rm *.jar
		java-pkg_jar-from servletapi-2.3
	cd ${S}
	sed -i -r \
		-e "s/etc\/sysconfig/etc\/conf.d/g" \
			bin/hsqldb

	eant -q -f build/build.xml cleanall > /dev/null

	epatch ${FILESDIR}/resolve-config-softlinks.patch
	if use sqltools; then
		epatch ${FILESDIR}/bundle-all-tools.patch
	fi

	mkdir conf
	sed -e "s/^HSQLDB_JAR_PATH=.*$/HSQLDB_JAR_PATH=${HSQLDB_JAR//\//\\/}/g" \
		-e "s/^SERVER_HOME=.*$/SERVER_HOME=\/var\/lib\/hsqldb/g" \
		-e "s/^HSQLDB_OWNER=.*$/HSQLDB_OWNER=hsqldb/g" \
		-e 's/^#AUTH_FILE=.*$/AUTH_FILE=${SERVER_HOME}\/sqltool.rc/g' \
		src/org/hsqldb/sample/sample-hsqldb.cfg > conf/hsqldb
	cp ${FILESDIR}/server.properties-1.8 conf/server.properties
	cp ${FILESDIR}/sqltool.rc-1.8 conf/sqltool.rc
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

	# Install env file for CONFIG_PROTECT support
	insinto /etc/env.d
	insopts -m0644
	doins ${FILESDIR}/35hsqldb

	# Put init, configuration and authorization files in /etc
	doinitd ${FILESDIR}/hsqldb
	doconfd conf/hsqldb
	dodir /etc/hsqldb
	insinto /etc/hsqldb
	# Change the ownership of server.properties and sqltool.rc
	# files to hsqldb:hsqldb. (resolves Bug #111963)
	insopts -m0600 -o hsqldb -g hsqldb
	doins conf/server.properties
	insopts -m0600 -o hsqldb -g hsqldb
	doins conf/sqltool.rc

	# Install init script
	dodir ${HSQLDB_HOME}/bin
	keepdir ${HSQLDB_HOME}
	exeinto ${HSQLDB_HOME}/bin
	doexe bin/hsqldb

	# Create symlinks to authorization files in the server home dir
	# (required by the hqldb init script)
	insinto ${HSQLDB_HOME}
	dosym /etc/hsqldb/server.properties ${HSQLDB_HOME}/server.properties
	dosym /etc/hsqldb/sqltool.rc ${HSQLDB_HOME}/sqltool.rc

	# Make sure that files have correct permissions
	chown -R hsqldb:hsqldb ${D}${HSQLDB_HOME}
	chmod o-rwx ${D}${HSQLDB_HOME}
}

pkg_postinst() {
	ewarn "If you intend to run Hsqldb in Server mode and you want to create"
	ewarn "additional databases, remember to put correct information in both"
	ewarn "'server.properties' and 'sqltool.rc' files."
	ewarn "(read the 'Init script Setup Procedure' section of the 'Chapter 3."
	ewarn "UNIX Quick Start' in the Hsqldb docs for more information)"
	echo
	einfo "Example:"
	echo
	einfo "/etc/hsqldb/server.properties"
	einfo "============================="
	einfo "server.database.1=file:xdb/xdb"
	einfo "server.dbname.1=xdb"
	einfo "server.urlid.1=xdb"
	einfo
	einfo "/etc/hsqldb/sqltool.rc"
	einfo "======================"
	einfo "urlid xdb"
	einfo "url jdbc:hsqldb:hsql://localhost/xdb"
	einfo "username sa"
	einfo "password "
	echo
	einfo "Also note that each hsqldb server can serve only up to 10"
	einfo "different databases simultaneously (with consecutive {0-9}"
	einfo "suffixes in the 'server.properties' file)."
	echo
	ewarn "For data manipulation use:"
	ewarn
	ewarn "# java -classpath ${HSQLDB_JAR} org.hsqldb.util.DatabaseManager"
	ewarn "# java -classpath ${HSQLDB_JAR} org.hsqldb.util.DatabaseManagerSwing"
	ewarn "# java -classpath ${HSQLDB_JAR} org.hsqldb.util.SqlTool \\"
	ewarn "  --rcFile /var/lib/hsqldb/sqltool.rc <dbname>"
	echo
	einfo "The Hsqldb can be run in multiple modes - read 'Chapter 1. Running'"
	einfo "and Using Hsqldb' in the Hsqldb docs at:"
	einfo "  http://hsqldb.org/web/hsqlDocsFrame.html"
	einfo "If you intend to run it in the Server mode, it is suggested to add the"
	einfo "init script to your start-up scripts, this should be done like this:"
	einfo "  \`rc-update add hsqldb default\`"
	echo

	# Enable CONFIG_PROTECT for hsqldb
	env-update
	einfo "Hsqldb stores its database files in ${HSQLDB_HOME} and this directory"
	einfo "is added to the CONFIG_PROTECT list. In order to immediately activate"
	einfo "these settings please do:"
	einfo "  \`env-update && source /etc/profile\`"
	einfo "Otherwise the settings will become active next time you login"
	echo
}

pkg_postrm() {
		# Disable CONFIG_PROTECT for hsqldb
		env-update
}
