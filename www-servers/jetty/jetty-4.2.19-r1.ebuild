# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/jetty/jetty-4.2.19.ebuild,v 1.2 2004/08/25 03:05:15 swegener Exp $

inherit eutils java-pkg

MY_PN=${PN/j/J}
MY_P=${MY_PN}-${PV}
DESCRIPTION="A Lightweight Servlet Engine"
SRC_URI="mirror://sourceforge/jetty/${MY_PN}-${PV}-all.tar.gz"
HOMEPAGE="http://www.mortbay.org/"
KEYWORDS="~x86 ~ppc ~sparc"
LICENSE="Apache-1.1"
SLOT="0"
DEPEND=">=virtual/jdk-1.2
		dev-java/ant-core
		dev-java/sun-jmx
		>=dev-java/xerces-2.7
"
RDEPEND=">=virtual/jre-1.2
"
IUSE="jikes doc"

S=${WORKDIR}/${MY_P}

pkg_preinst() {
	enewgroup jetty
	# TODO: should jetty user have bash?
	enewuser jetty -1 /bin/bash /opt/jetty jetty
	chown -R jetty:jetty ${D}/opt/jetty
}

src_unpack() {
	unpack ${A}
	cd ${S}

	# this patch should be applied regardless if jikes is used
	# because it fixes Lexical warnings to the effect of:
	# "The use of "enum" as an identifier is deprecated, as it will be a keyword
	# once -source 1.5 is implemented."
	epatch ${FILESDIR}/${P}-jikes.patch

	epatch ${FILESDIR}/${P}-gentoo.patch

	# Setup build.properties
	echo "ant.jar=`java-pkg_getjar ant-core ant.jar`" >> build.properties
	# TODO: use our own jasper-*.jar once its in portage
	# TODO: find package for jcert.jar
	echo "jmxri.jar=`java-pkg_getjar sun-jmx jmxri.jar`" >> build.properties
	echo "jmxtools.jar=`java-pkg_getjar sun-jmx jmxtools.jar`" >> build.properties
	# TODO: find package for jnet.jar
	# TODO: this might be the best way to get the path...
	echo "jsse.jar=${JAVA_HOME}/jre/lib/jsse.jar" >> build.properties
	echo "xercesImpl.jar=`java-pkg_getjar xerces-2 xercesImpl.jar`" >> build.properties	
}

src_compile() {
	local antflags="clean webapps"

	if use doc; then
		antflags="${antflags} javadoc"
	fi

	if use jikes; then
		antflags="${antflags} -Dbuild.compiler=jikes"
	fi

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	# TODO: maybe these should be symlinks?
	java-pkg_dojar ${S}/lib/*.jar

	JETTY_HOME="/opt/jetty"
	INSTALLING="yes"
	diropts -m0750

	# Create directories
	dodir ${JETTY_HOME}
	dodir ${JETTY_HOME}/tmp
	dodir ${JETTY_HOME}/bin
	keepdir ${JETTY_HOME}/tmp

	# Setup log
	dodir /var/log/${PN}
	touch ${D}/var/log/${PN}/${PN}.log
	keepdir /var/log/${PN}

	# INIT SCRIPTS AND ENV
	insinto /etc/init.d
	insopts -m0755
	newins ${FILESDIR}/${PV}/${PN}.init ${PN}

	insinto /etc/env.d
	insopts -m0644
	doins ${FILESDIR}/${PV}/21${PN}

	insinto /etc/
	insopts -m0644
	doins ${FILESDIR}/${PV}/${PN}.conf

	insinto /etc/conf.d
	insopts -m0644
	doins ${FILESDIR}/${PV}/${PN}

	dodoc *.TXT
	dohtml *.html

	dosym ${JETTY_HOME}/etc /etc/${PN}
	ln -sf /var/log/${PN} ${D}/${JETTY_HOME}/logs

	# Make script executable
	chmod u+x ${S}/bin/${PN}.sh

	# Copy everything over
	# TODO: maybe this could be handled better?
	cp -Rdp * ${D}/${JETTY_HOME}
}

pkg_postinst() {
	einfo
	einfo " NOTICE!"
	einfo " User and group 'jetty' have been added."
	einfo " "
	einfo " FILE LOCATIONS:"
	einfo " 1.  Jetty home directory: ${JETTY_HOME}"
	einfo "     Contains application data, configuration files."
	einfo " 2.  Runtime settings: /etc/conf.d/jetty"
	einfo "     Contains CLASSPATH,JAVA_HOME,JAVA_OPTIONS,JETTY_PORT"
	einfo "              JETTY_USER,JETTY_CONF setting"
	einfo " 3.  You can configure your 'webapp'-lications in /etc/jetty.conf"
	einfo "     (the default configured webapps are the JETTY's demo/admin)"
	einfo " 4.  For more information about JETTY refer to jetty.mortbay.org"
	einfo " 5.  Logs are located at:"
	einfo "                              /var/log/jetty/"
	einfo
	einfo " STARTING AND STOPPING JETTY:"
	einfo "   /etc/init.d/jetty start"
	einfo "   /etc/init.d/jetty stop"
	einfo "   /etc/init.d/jetty restart"
	einfo " "
	einfo " "
	einfo " NETWORK CONFIGURATION:"
	einfo " By default, Jetty runs on port 8080.  You can change this"
	einfo " value by setting JETTY_PORT in /etc/conf.d/jetty ."
	einfo " "
	einfo " To test Jetty while it's running, point your web browser to:"
	einfo " http://localhost:8080/"
	einfo
	einfo " BUGS:"
	einfo " Please file any bugs at http://bugs.gentoo.org/ or else it"
	einfo " may not get seen. Thank you!"
	einfo
}
