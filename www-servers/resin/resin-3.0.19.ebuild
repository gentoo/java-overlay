# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 eutils flag-o-matic

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

RESIN_HOME="/usr/lib/resin"

src_unpack() {

	unpack "${A}"
	epatch "${FILESDIR}/${PV}/${P}-gentoo.patch"

}

pkg_setup() {

	einfo "Adding resin:resin"
	enewgroup resin
	enewuser resin -1 /bin/bash ${RESIN_HOME} resin

}

src_compile() {

	append-flags -fPIC -DPIC

	chmod 755 ${S}/configure
	econf --prefix=${RESIN_HOME} || die "econf failed"

	einfo "Building libraries..."
	# Broken with -jn where n > 1
	emake -j1 || die "emake failed"

	export CLASSPATH=`java-config -p iso-relax,aopalliance-1`

	einfo "Building jars..."
	ant || die "ant failed"

	if use doc; then
		einfo "Building docs..."
		ant doc || die "ant doc failed"
	fi

}

src_install() {

	make DESTDIR=${D} install || die

	dodir /etc/
	mv ${D}/${RESIN_HOME}/conf ${D}/etc/resin
	dosym /etc/resin ${RESIN_HOME}/conf

	keepdir /var/log/resin
	keepdir /var/log/resin
	keepdir /var/run/resin

	dosym /var/log/resin ${RESIN_HOME}/logs
	dosym /var/log/resin ${RESIN_HOME}/log

	dodoc README

	newinitd ${FILESDIR}/${PV}/resin.init resin
	newconfd ${FILESDIR}/${PV}/resin.conf resin

	java-pkg_dojar ${S}/lib/*.jar
	rm -fr ${D}/${RESIN_HOME}/lib
	dosym /usr/share/resin/lib ${RESIN_HOME}/lib

	dodir /var/lib/resin/webapps
	mv ${D}/${RESIN_HOME}/webapps/* ${D}/var/lib/resin/webapps
	rm -rf ${D}/${RESIN_HOME}/webapps
	dosym /var/lib/resin/webapps ${RESIN_HOME}/webapps

	dosym /etc/resin/resin.conf /etc/resin/resin.xml

	einfo "Removing unneeded files..."
	rm -f ${D}/${RESIN_HOME}/bin/*.in
	rm -f ${D}/etc/resin/*.orig

	einfo "Fixing permissions..."
	chown -R resin:resin ${D}${RESIN_HOME}
	chown -R resin:resin ${D}/etc/resin
	chown -R resin:resin ${D}/var/log/resin
	chown -R resin:resin ${D}/var/lib/resin
	chown -R resin:resin ${D}/var/run/resin

	chmod 755 ${D}${RESIN_HOME}/bin/*
	chmod 644 ${D}/etc/conf.d/resin
	chmod 755 ${D}/etc/init.d/resin
	chmod 750 ${D}/var/lib/resin
	chmod 750 ${D}/var/run/resin
	chmod 750 ${D}/etc/resin

}

pkg_postinst() {

	einfo
	einfo " User and group 'resin' have been added."
	einfo
	einfo " By default, Resin runs on port 8080.  You can change this"
	einfo " value by editing /etc/conf/resin.conf."
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
	einfo " webapps directory was moved to /var/lib/resin/webapps "
	einfo

}
