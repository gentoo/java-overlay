# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils flag-o-matic java-utils

DESCRIPTION="A fast Servlet 2.4 and JSP 2.0 engine with EJB and distributed session load balancing."
HOMEPAGE="http://www.caucho.com"
SRC_URI="http://www.caucho.com/download/${P}-src.tar.gz"
LICENSE="GPL-2"
SLOT="0"
IUSE="doc"

# 2006/01/21: keywords (ppc, ppc64, sparc) dropped due to deps:
#  - aopalliance has (amd64, x86)
#  - iso-relax has (amd64, ppc, x86)
KEYWORDS="~amd64 ~x86"

RDEPEND=">=virtual/jdk-1.5
	>=dev-java/iso-relax-20050331"
DEPEND="${RDEPEND}
	dev-java/aopalliance
	dev-java/ant-core
	dev-libs/openssl"

RESIN_HOME="/opt/resin"

src_unpack() {

	unpack "${A}"
	epatch "${FILESDIR}/${PV}/${P}-gentoo.patch"

}

pkg_preinst() {

	enewgroup resin
	enewuser resin -1 /bin/bash ${RESIN_HOME} resin

	einfo "Fixing ownership..."
	chown -R resin:resin ${D}${RESIN_HOME}
	chown -R resin:resin ${D}/var/log/resin

	einfo "Fixing permissions..."
	chmod 755 ${D}${RESIN_HOME}/bin/*
	chmod 644 ${D}/etc/conf.d/resin
	chmod 755 ${D}/etc/init.d/resin

}

src_compile() {

	append-flags -fPIC -DPIC

	chmod 755 ${S}/configure
	econf --prefix=${RESIN_HOME} || die "econf failed"

	einfo "Building libraries..."
	emake || die "emake failed"

	CP=`java-config -p iso-relax`:`java-config -p aopalliance-1`:${CLASSPATH}
	einfo "Building jars..."
	CLASSPATH=${CP} ant || die "ant failed"

	if use doc; then
		einfo "Building docs..."
		CLASSPATH=${CP} ant doc || die "ant doc failed"
	fi

}

src_install() {

	make DESTDIR=${D} install || die

	dodir /etc/
	mv ${D}/${RESIN_HOME}/conf ${D}/etc/resin
	dosym /etc/resin ${RESIN_HOME}/conf

	dodir /var/log/resin
	keepdir /var/log/resin
	dosym /var/log/resin ${RESIN_HOME}/logs
	dosym /var/log/resin ${RESIN_HOME}/log

	dodoc README LICENSE

	insinto /etc/init.d ; insopts -m0750 ; newins ${FILESDIR}/${PV}/resin.init resin
	insinto /etc/conf.d ; insopts -m0755 ; newins ${FILESDIR}/${PV}/resin.conf resin
	insinto /etc/env.d  ; insopts -m0755 ; doins ${FILESDIR}/${PV}/21resin

	java-pkg_dojar ${S}/lib/*.jar
	rm -fr ${D}/usr/share/${PN}/lib
	dosym ${RESIN_HOME}/lib /usr/share/${PN}/

	# Cleanup:
	rm -f ${D}/etc/resin/*.orig
	rm -f ${D}${RESIN_HOME}/bin/wrapper.pl.in

}

pkg_postinst() {

	einfo
	einfo " NOTICE!"
	einfo " User and group 'resin' have been added."
	einfo " "
	einfo " FILE LOCATIONS:"
	einfo " 1.  Resin home directory: ${RESIN_HOME}"
	einfo "     Contains application data, configuration files."
	einfo " 2.  Runtime settings: /etc/conf.d/resin"
	einfo "     Contains CLASSPATH and JAVA_HOME settings."
	einfo " 3.  Logs:  /var/log/resin/"
	einfo " 4.  Executables, libraries:  /usr/share/resin/"
	einfo
	einfo "If you are updating from resin-2* your old configuration files"
	einfo "have been moved to /etc/resin/conf.old"
	einfo " "
	einfo " STARTING AND STOPPING RESIN:"
	einfo "   /etc/init.d/resin start"
	einfo "   /etc/init.d/resin stop"
	einfo "   /etc/init.d/resin restart"
	einfo
	einfo
	einfo " NETWORK CONFIGURATION:"
	einfo " By default, Resin runs on port 8080.  You can change this"
	einfo " value by editing ${RESIN_HOME}/conf/resin.conf."
	einfo
	einfo " To test Resin while it's running, point your web browser to:"
	einfo " http://localhost:8080/"
	einfo
	einfo " Resin cannot run on port 80 as non-root (as of this time)."
	einfo " The best way to get Resin to respond on port 80 is via port"
	einfo " forwarding -- by installing a firewall on the machine running"
	einfo " Resin or the network gateway.  Simply redirect port 80 to"
	einfo " port 8080."
	einfo
	einfo " BUGS:"
	einfo " Please file any bugs at http://bugs.gentoo.org/ or else it"
	einfo " may not get seen.  Thank you."
	einfo

}

pkg_postrm() {

	einfo "You may want to remove the resin user and group"

}
