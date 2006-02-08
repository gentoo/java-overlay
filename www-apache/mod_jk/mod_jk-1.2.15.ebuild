# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apache/mod_jk/mod_jk-1.2.13.ebuild,v 1.3 2005/10/17 18:15:11 betelgeuse Exp $

inherit apache-module

MY_P="jakarta-tomcat-connectors-${PV}-src"

DESCRIPTION="JK module for connecting Tomcat and Apache using the ajp13 protocol"
HOMEPAGE="http://jakarta.apache.org/tomcat/connectors-doc"
SRC_URI="mirror://apache/jakarta/tomcat-connectors/jk/source/jk-${PV}/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="apache2"

RDEPEND=">=www-servers/tomcat-3"
DEPEND=">=libtool-1.3.3
	>=autoconf-2.13"
S="${WORKDIR}/${MY_P}/jk/native"

APACHE1_MOD_FILE="${S}/apache-1.3/mod_jk.so"
APACHE1_MOD_CONF="88_${PN}"
APACHE1_MOD_DEFINE="JK"

APACHE2_MOD_FILE="${S}/apache-2.0/mod_jk.so"
APACHE2_MOD_CONF="88_${PN}"
APACHE2_MOD_DEFINE="JK"

DOCFILES="CHANGES.txt README"

need_apache

src_compile() {
	local apxs
	local java_args
	use apache2 && apxs="${APXS2}"
	use apache2 || apxs="${APXS1}"
	use java && java_args="--with-java-home=${JAVA_HOME} --enable-jni"

	econf \
		--with-apxs=${apxs} \
		--with-apr-config=/usr/bin/apr-config \
		${java_args} \
		|| die "econf failed"
	emake LIBTOOL="/bin/sh $(pwd)/libtool --silent" || die "make failed"
}

src_install() {
	# install the workers.properties file
	local confdir=""
	use apache2 && confdir="/etc/apache2"
	use apache2 || confdir="/etc/apache"

	dodir ${confdir}
	insinto ${confdir}
	doins ${FILESDIR}/jk-workers.properties

	# call the nifty default src_install :-)
	apache-module_src_install
}

pkg_postinst() {
	einfo "Tomcat is not a dependency of mod_jk any longer, if you intend"
	einfo "to use it with Tomcat, you have to merge www-servers/tomcat on"
	einfo "your own."
}
