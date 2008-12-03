# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-vm-2 multilib

DESCRIPTION="Java wrappers around GCJ"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
SLOT="0"
IUSE=""

RDEPEND=">=sys-devel/gcc-4.3
	~dev-java/eclipse-ecj-3.3.0-r7
	>=dev-java/java-config-2"
DEPEND="${RDEPEND}"
PDEPEND="dev-java/gjdoc"

JAVA_PROVIDE="jdbc-stdext jdbc2-stdext gnu-jaxp"

pkg_setup() {
	if ! built_with_use sys-devel/gcc gcj; then
		eerror "Using gcj as a jdk requires that gcj was compiled as part of gcc.";
		eerror "Please rebuild sys-devel/gcc with USE=\"gcj\"";
		die "Rebuild sys-devel/gcc with gcj support"
	fi
	java-vm-2_pkg_setup
}

src_install() {
	# jre lib paths ...
	local libarch="${ARCH}"
	[ ${ARCH} == x86 ] && libarch="i386"
	[ ${ARCH} == x86_64 ] && libarch="amd64"
	local gccbin=$(gcc-config -B)
	local gcclib=$(gcc-config -L|cut -d':' -f1)
	local gcjhome="/usr/lib/${P}"
	local gcc_version=$(${gccbin}/gcc --version|head -n1|sed -r 's/gcc \(.*\) ([0-9.]*).*/\1/')
	local gccchost=$(echo ${gccbin}|sed -r 's#/usr/([a-z0-9_-]*).*$#\1#')

	# correctly install gcj
	dosym ${gccbin}/gij /usr/bin/gij
	dosym ${gccbin}/gcj-dbtool /usr/bin/gcj-dbtool

	# links
	dodir ${gcjhome}/bin
	dodir ${gcjhome}/jre/bin
	dosym ${gcjhome}/bin/java ${gcjhome}/jre/bin/java
	dosym ${gccbin}/gjar ${gcjhome}/bin/jar
	dosym ${gccbin}/grmic ${gcjhome}/bin/rmic
	dosym ${gccbin}/gjavah ${gcjhome}/bin/javah
	dosym ${gccbin}/jcf-dump ${gcjhome}/bin/javap
	dosym ${gccbin}/gappletviewer ${gcjhome}/bin/appletviewer
	dosym ${gccbin}/gjarsigner ${gcjhome}/bin/jarsigner
	dosym ${gccbin}/grmiregistry ${gcjhome}/bin/rmiregistry
	dosym ${gccbin}/grmiregistry ${gcjhome}/jre/bin/rmiregistry
	dosym ${gccbin}/gkeytool ${gcjhome}/bin/keytool
	dosym ${gccbin}/gkeytool ${gcjhome}/jre/bin/keytool
	dodir ${gcjhome}/jre/lib/${libarch}/client
	dosym /usr/$(get_libdir)/gcj-${gcc_version}*/libjvm.so ${gcjhome}/jre/lib/${libarch}/client/libjvm.so
	dosym /usr/$(get_libdir)/gcj-${gcc_version}*/libjvm.so ${gcjhome}/jre/lib/${libarch}/server/libjvm.so
	dosym /usr/$(get_libdir)/gcj-${gcc_version}*/libjawt.so ${gcjhome}/jre/lib/${libarch}/libjawt.so
	dosym /usr/share/gcc-data/${gccchost}/${gcc_version}/java/libgcj-${gcc_version/_/-}.jar \
		${gcjhome}/jre/lib/rt.jar
	dodir ${gcjhome}/lib
	dosym /usr/share/gcc-data/${gccchost}/${gcc_version}/java/libgcj-tools-${gcc_version/_/-}.jar \
		${gcjhome}/lib/tools.jar
	dosym ${gcclib}/include ${gcjhome}

	# the /usr/bin/ecj symlink is managed by eselect-ecj
	dosym /usr/bin/ecj ${gcjhome}/bin/javac;
	dosym /usr/bin/gij ${gcjhome}/bin/java;

	# use gjdoc for javadoc
	dosym /usr/bin/gjdoc ${gcjhome}/bin/javadoc

	set_java_env
}

pkg_postinst() {

	# Set as default VM if none exists
	java-vm-2_pkg_postinst

	ewarn "gcj does not currently provide all the 1.5 APIs."
	ewarn "See http://builder.classpath.org/japi/libgcj-jdk15.html"
	ewarn "Check for existing bugs relating to missing APIs and file"
	ewarn "new ones at http://gcc.gnu.org/bugzilla/"

	einfo "See http://www.gentoo.org/doc/en/java.xml#doc_chap4"
	einfo "if you want to set gcj as system vm and help testing"
	einfo "it."
}