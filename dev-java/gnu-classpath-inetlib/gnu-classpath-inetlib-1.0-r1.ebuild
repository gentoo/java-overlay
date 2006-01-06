# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/gnu-classpath-inetlib/gnu-classpath-inetlib-1.0-r1.ebuild,v 1.2 2005/11/30 00:23:20 nichoj Exp $

inherit java-pkg

DESCRIPTION="Network extensions library for GNU classpath and classpathx"
HOMEPAGE="http://www.gnu.org/software/classpath/"
SRC_URI="ftp://ftp.gnu.org/gnu/classpath/inetlib-${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="1.0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE="doc"
#	>=dev-java/jessie-0.9.7
RDEPEND=">=virtual/jre-1.3
	>=dev-java/gnu-crypto-2.0.1
	"
DEPEND=">=virtual/jdk-1.3
	${RDEPEND}"
S=${WORKDIR}/inetlib-${PV}

# TODO we could give configure the lib dir on the live filesystem
# instead of populating ${S}/ext with the jars we need -nichoj
# TODO fix jikes support. Related to bug #89711

src_unpack() {
	unpack ${A}
	cd ${S}

	mkdir ext && cd ext

	if has_version dev-java/jessie; then
		java-pkg_jar-from jessie
	fi

	java-pkg_jar-from gnu-crypto javax-security.jar javax-security-auth-callback.jar
	java-pkg_jar-from gnu-crypto javax-security.jar javax-security-sasl.jar
}


src_compile() {
	local javac="javac"
	# use jikes && javac="jikes"

	local jssedir="${S}/ext"

	if ! has_version dev-java/jessie; then
		jssedir="${JAVA_HOME}/jre/lib/"
	fi

	JAVAC=${javac} econf \
		--enable-smtp \
		--enable-imap \
		--enable-pop3 \
		--enable-nntp \
		--enable-ftp \
		--enable-gopher \
		--with-jsse-jar="${jssedir}" \
		--with-javax-security-auth-callback-jar="${S}/ext" \
		--with-javax-security-sasl-jar="${S}/ext" \
		|| die
	emake || die

	if use doc ; then
		emake javadoc || die
	fi
}

src_install() {
	einstall || die
	rm -rf ${D}/usr/share/java
	java-pkg_dojar inetlib.jar
	use doc && java-pkg_dohtml -r docs/*
	dodoc AUTHORS NEWS README
}
