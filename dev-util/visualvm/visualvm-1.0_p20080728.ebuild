# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit autotools

DESCRIPTION="A harness to build VisualVM using Free Software build tools"
NETBEANS_BASIC_CLUSTER_ZIP="netbeans-6.1-200805300101-basic_cluster-src.zip"
NETBEANS_PROFILER_TARBALL="netbeans-profiler-visualvm_preview2.tar.gz"
VISUALVM_TARBALL="visualvm-20080728-src.tar.gz"
SRC_URI="http://icedtea.classpath.org/download/source/icedtea6-1.3.tar.gz
		 http://nbi.netbeans.org/files/documents/210/2056/${NETBEANS_BASIC_CLUSTER_ZIP}
		 http://icedtea.classpath.org/visualvm/${NETBEANS_PROFILER_TARBALL}
		 http://icedtea.classpath.org/visualvm/${VISUALVM_TARBALL}"
HOMEPAGE="http://icedtea.classpath.org"

IUSE=""

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"

RDEPEND=">=dev-java/icedtea6-1.3
		 ~dev-util/netbeans-6.1"

DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}" || die

	# Fix missing --with-netbeans-basic-cluster-src-zip (http://icedtea.classpath.org/hg/icedtea6/rev/1c580400c8d9)
	epatch "${FILESDIR}/missing_zip-${PV}.patch"

	eautoreconf || die "failed to regenerate autoconf infrastructure"
}

src_compile() {
	local vmhome="/usr/lib/jvm/icedtea6"

	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS

	econf \
		--with-netbeans-basic-cluster-src-zip="${DISTDIR}/${NETBEANS_BASIC_CLUSTER_ZIP}" \
		--with-netbeans-src-zip="${DISTDIR}/${NETBEANS_PROFILER_TARBALL}" \
		--with-visualvm-src-zip="${DISTDIR}/${VISUALVM_TARBALL}" \
		--with-icedtea \
		--with-icedtea-home="${vmhome}" \
		--with-java="${vmhome}/bin/java" \
		--with-javac="${vmhome}/bin/javac" \
		--with-javah="${vmhome}/bin/javah" \
		--with-visualvm \
		--with-netbeans-home=/usr/share/netbeans-6.1 \
		|| die "configure failed"

	emake visualvm  || die "make failed"
}

src_install() {
	local icedtea_home=/usr/lib/icedtea6;

	dodir "${icedtea_home}/lib/visualvm/etc"
	dodir "${icedtea_home}/lib/visualvm/visualvm"

	sed "s/APPNAME=\`basename.*\`/APPNAME=visualvm/" \
	  visualvm/visualvm/launcher/visualvm >> \
	  "${D}"${icedtea_home}/bin/jvisualvm ; \
	fperms 755 ${icedtea_home}/bin/jvisualvm

	insinto "${icedtea_home}/lib/visualvm/etc"
	doins visualvm/visualvm/launcher/visualvm.conf
	doins "${FILESDIR}"/visualvm.clusters

	insinto "${icedtea_home}/lib/visualvm/visualvm"
	doins visualvm/visualvm/build/cluster/*

	insinto "${icedtea_home}/lib/visualvm"
	doins netbeans/nbbuild/netbeans/platform8
	doins netbeans/nbbuild/netbeans/profiler3
}

