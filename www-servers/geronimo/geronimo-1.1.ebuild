# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/tomcat/tomcat-5.5.17-r1.ebuild,v1.1 2006/07/07 20:08:51 nichoj Exp $

inherit eutils java-pkg-2

DESCRIPTION="Geronimo J2EE application server"

SRC_URI="http://apache.mirror.pacific.net.au/geronimo/1.1/geronimo-tomcat-j2ee-1.1.tar.gz"
HOMEPAGE="http://geronimo.apache.org/"
KEYWORDS="~amd64 ~x86"

pkg_setup() {
        # new user for tomcat
        enewgroup geronimo
        enewuser geronimo -1 -1 /dev/null geronimo
}

src_unpack() {
        unpack ${A}
}

src_install() {
	cd ${S}
	newinitd ${FILESDIR}/${PV}/geronimo.init geronimo
	newconfd ${FILESDIR}/${PV}/geronimo.conf geronimo
	mkdir -p ${D}/opt/geronimo/var/shared/classes
	mkdir -p ${D}/opt/geronimo/var/shared/lib
	cp -R * ${D}/opt/geronimo
	chown -R geronimo:geronimo ${D}/opt/geronimo
	chmod -R og-rwx ${D}/opt/geronimo
	cd ${D}/opt/geronimo/bin
	rm *.bat
	chmod +x *.sh
}
