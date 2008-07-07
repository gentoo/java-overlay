# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-vm-2 multilib

ECJ_VER="3.3"

DESCRIPTION="Java wrappers around GCJ"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
SLOT="0"

RDEPEND="~sys-devel/gcc-${PV}
	=dev-java/eclipse-ecj-${ECJ_VER}*
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
	local gcjhome="/usr/lib/gcj-${PV}"
	local gccchost=$(echo $gccbin|sed -r 's#/usr/([a-z0-9_-]*).*$#\1#')

	# links
	dodir ${gcjhome}
	dosym ${gccbin}/gij ${gcjhome}/bin/gij
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
	dosym /usr/$(get_libdir)/gcj-${PV}*/libjvm.so ${gcjhome}/jre/lib/${libarch}/client/libjvm.so
	dosym /usr/$(get_libdir)/gcj-${PV}*/libjawt.so ${gcjhome}/jre/lib/${libarch}/libjawt.so
	dosym /usr/share/gcc-data/${gccchost}/${PV}/java/libgcj-${PV/_/-}.jar ${gcjhome}/jre/lib/rt.jar
	dosym /usr/share/gcc-data/${gccchost}/${PV}/java/libgcj-tools-${PV/_/-}.jar ${gcjhome}/lib/tools.jar

	# use ecj for javac
	if [ -e /usr/bin/ecj ]; then
		dosym /usr/bin/ecj ${bindir}/javac;
	else
		dosym $(ls -r /usr/bin/ecj-3*|head -n 1) ${bindir}/javac;
	fi
	# use gjdoc for javadoc
	dosym /usr/bin/gjdoc ${gcjhome}/bin/javadoc

	# java wrapper
	sed -e "s:@HOME@:${gcjhome}:g" \
		< "${FILESDIR}"/java.in \
		> "${D}"${gcjhome}/bin/java \
		|| die "java wrapper failed"

	# permissions
	fperms 755 ${gcjhome}/bin/java{,c}

	set_java_env

	# copy scripts
	exeinto /usr/bin
	doexe "${FILESDIR}"/gcj-config
	doexe "${FILESDIR}"/rebuild-classmap-db
}

pkg_postinst() {
	gcj-config gcj-${PV}

	# Set as default VM if none exists
	java-vm-2_pkg_postinst

	ewarn "Check if gcj-jdk is set as Java SDK"
	ewarn "	# java-config -L"
	ewarn
	ewarn "Set gcj-jdk as Java SDK"
	ewarn "	# java-config -S ${PN}-${SLOT}"
	ewarn
	ewarn "Edit /etc/java-config-2/build/jdk.conf"
	ewarn "	*=${PN}-${SLOT}"
	ewarn
	ewarn "Install GCJ's javadoc"
	ewarn "	# emerge gjdoc"
}
