# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Build written by Andrew John Hughes (ahughes@redhat.com)

EAPI="2"

inherit eutils java-vm-2

LICENSE="GPL-2 GPL-2-with-linking-exception LGPL-2"
SLOT="6"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

DESCRIPTION="FOSS Java browser plugin and Web Start implementation"
SRC_URI="http://icedtea.classpath.org/download/source/${P}.tar.gz"
HOMEPAGE="http://icedtea.classpath.org"

IUSE="doc +nsplugin"

RDEPEND="dev-java/icedtea"
DEPEND="${RDEPEND}"

JAVA_PKG_WANT_SOURCE="1.6"
JAVA_PKG_WANT_TARGET="1.6"

unset_vars() {
	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS
}

src_configure() {
	local vmhome=$(java-config -O)
	local icedtea6dir="${ROOT}usr/$(get_libdir)/icedtea6"
	local icedtea7dir="${ROOT}usr/$(get_libdir)/icedtea7"

	unset_vars

	if [ ${vmhome} == ${icedtea6dir} ] ; then
		installdir=${vmhome}
		VMHANDLE="icedtea6"
	else if [ ${vmhome} == ${icedtea7dir} ] ; then
		installdir=${vmhome}
		VMHANDLE="icedtea7"
	else
		ewarn "No IcedTea JDK selected.  Assuming IcedTea6."
		installdir=${icedtea6dir}
		VMHANDLE="icedtea6"
	fi
	fi

	elog "Installing IcedTea-Web in ${installdir}"
	if [ ! -e ${installdir} ] ; then
		eerror "Could not find JDK install directory ${installdir}."
	fi

	econf \
		--prefix=${installdir} \
		--with-jdk-home=${vmhome} \
		$(use_enable doc docs) \
		$(use_enable nsplugin plugin) \
		|| die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc AUTHORS README NEWS || die

	if use nsplugin; then
		local arch=${ARCH};
		use x86 && arch=i386;
		install_mozilla_plugin "${installdir}/jre/lib/${arch}/IcedTeaPlugin.so";
	fi
}

pkg_postinst() {
	java-vm_check-nsplugin
	java_mozilla_clean_

	if use nsplugin; then
		elog "The icedtea browser plugin (NPPlugin) can be enabled using eselect java-nsplugin"
		elog "Note that the plugin works only in browsers based on xulrunner-1.9.1 or later"
		elog "such as Firefox 3.5+, Chromium and perhaps some others too."
	fi
}
