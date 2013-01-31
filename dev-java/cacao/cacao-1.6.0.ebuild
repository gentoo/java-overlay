# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/cacao/cacao-0.99.4.ebuild,v 1.7 2012/06/14 21:25:44 radhermit Exp $

EAPI=5
AUTOTOOLS_AUTO_DEPEND="no"

inherit autotools eutils flag-o-matic java-pkg-2 java-vm-2

DESCRIPTION="Cacao Java Virtual Machine"
HOMEPAGE="http://www.cacaojvm.org/"
SRC_URI="http://www.complang.tuwien.ac.at/cacaojvm/download/${P}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
CLASSPATH_SLOT=0.99
COMMON_DEPEND="
	dev-java/gnu-classpath:${CLASSPATH_SLOT}
	|| ( dev-java/eclipse-ecj dev-java/ecj-gcj )
	>=dev-libs/boehm-gc-7.2d
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	test? (
		dev-java/junit:4
		${AUTOTOOLS_DEPEND}
	)
"

CLASSPATH_DIR=/usr/gnu-classpath-${CLASSPATH_SLOT}

src_prepare() {
	if use test; then
		sed -ie "s:/usr/share/java/junit4.jar:$(java-config -p junit-4):" \
			./tests/regression/bugzilla/Makefile.am \
			./tests/regression/base/Makefile.am || die "sed failed"
	fi
	epatch "${FILESDIR}/system-boehm-gc.patch"
	epatch "${FILESDIR}/support-7.patch"
	eautoreconf
}

src_configure() {
	# A compiler can be forced with the JAVAC variable if needed
	unset JAVAC
	append-flags -fno-strict-aliasing
	econf --bindir=/usr/${PN}/bin \
		--libdir=/usr/${PN}/lib \
		--datarootdir=/usr/${PN}/share \
		--disable-dependency-tracking \
		--with-java-runtime-library-prefix=${CLASSPATH_DIR}
}

src_compile() {
	default
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodir /usr/bin
	dosym /usr/${PN}/bin/cacao /usr/bin/cacao || die
	dodoc AUTHORS ChangeLog* NEWS README || die "failed to install docs"

	for files in ${CLASSPATH_DIR}/bin/g*; do
		if [ $files = "${CLASSPATH_DIR}/bin/gjdoc" ] ; then
			dosym $files /usr/${PN}/bin/javadoc || die
		else
			dosym $files \
				/usr/${PN}/bin/$(echo $files|sed "s#$(dirname $files)/g##") || die
		fi
	done

	dodir /usr/${PN}/jre/lib
	dosym ${CLASSPATH_DIR}/share/classpath/glibj.zip /usr/${PN}/jre/lib/rt.jar
	dodir /usr/${PN}/lib
	dosym ${CLASSPATH_DIR}/share/classpath/tools.zip /usr/${PN}/lib/tools.jar

	local ecj_jar="$(readlink "${EPREFIX}"/usr/share/eclipse-ecj/ecj.jar)"
	exeinto /usr/${PN}/bin
	cat "${FILESDIR}"/javac.in | sed -e "s#@JAVA@#/usr/${PN}/bin/cacao#" \
		-e "s#@ECJ_JAR@#${ecj_jar}#" \
		-e "s#@RT_JAR@#${CLASSPATH_DIR}/share/classpath/glibj.zip#" \
		-e "s#@TOOLS_JAR@#${CLASSPATH_DIR}/share/classpath/tools.zip#" \
	| newexe - javac

	local libarch="${ARCH}"
	[ ${ARCH} == x86 ] && libarch="i386"
	[ ${ARCH} == x86_64 ] && libarch="amd64"
	dodir /usr/${PN}/jre/lib/${libarch}/client
	dodir /usr/${PN}/jre/lib/${libarch}/server
	dosym /usr/${PN}/lib/libjvm.so /usr/${PN}/jre/lib/${libarch}/client/libjvm.so
	dosym /usr/${PN}/lib/libjvm.so /usr/${PN}/jre/lib/${libarch}/server/libjvm.so
	dosym ${CLASSPATH_DIR}/lib/classpath/libjawt.so /usr/${PN}/jre/lib/${libarch}/libjawt.so
	set_java_env
}
