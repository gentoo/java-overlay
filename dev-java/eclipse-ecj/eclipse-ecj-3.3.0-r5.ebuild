# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2

MY_PN="ecj"
DMF="R-${PV}-200706251500"
S="${WORKDIR}"

DESCRIPTION="Eclipse Compiler for Java"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/${DMF/.0}/${MY_PN}src.zip"

IUSE="gcj java6"

LICENSE="EPL-1.0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
SLOT="3.3"

CDEPEND=">=app-admin/eselect-ecj-0.2
	gcj? ( >=sys-devel/gcc-4.3.1 )"
DEPEND="${CDEPEND}
	!gcj? ( !java6? ( >=virtual/jdk-1.4 )
		java6? ( >=virtual/jdk-1.6 ) )"
RDEPEND="${CDEPEND}
	!gcj? ( !java6? ( >=virtual/jre-1.4 )
		java6? ( >=virtual/jre-1.6 ) )"

pkg_setup() {
	if use gcj ; then
		if ! built_with_use sys-devel/gcc gcj ; then
			eerror "Building with gcj requires that gcj was compiled as part of gcc.";
			eerror "Please rebuild sys-devel/gcc with USE=\"gcj\"";
			die "Rebuild sys-devel/gcc with gcj support"
		fi
	else
		java-pkg-2_pkg_setup
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}" || die

	# These have their own package.
	rm -f org/eclipse/jdt/core/JDTCompilerAdapter.java || die
	rm -fr org/eclipse/jdt/internal/antadapter || die

	if use gcj || ! use java6 ; then
		rm -fr org/eclipse/jdt/internal/compiler/{apt,tool}/ || die
	fi

	# add GCCMain support
	epatch "${FILESDIR}"/${PN}-gcj-${PV/_*}.patch
}

src_compile() {
	local javac_opts javac java jar

	if use gcj ; then
		local gccbin="$(gcc-config -B $(ls -r /etc/env.d/gcc/${CHOST}-* | head -1) || die)"
		local gcj="${gccbin}/gcj"
		javac="${gcj} -C"
		jar="${gccbin}/gjar"
		java="${gccbin}/gij"
	else
		javac_opts="$(java-pkg_javac-args) -encoding ISO-8859-1"
		javac="$(java-config -c)"
		java="$(java-config -J)"
		jar="$(java-config -j)"
	fi

	mkdir -p bootstrap || die
	cp -a org bootstrap || die
	cd "${S}/bootstrap" || die

	einfo "bootstrapping ${MY_PN} with ${javac} ..."
	${javac} ${javac_opts} $(find org/ -name '*.java') || die
	find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' |\
		xargs ${jar} cf ${MY_PN}.jar

	cd "${S}" || die
	einfo "building ${MY_PN} with bootstrapped ${MY_PN} ..."
	${java} -classpath bootstrap/${MY_PN}.jar \
		org.eclipse.jdt.internal.compiler.batch.Main \
		${javac_opts} -nowarn org || die
	find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' |\
		xargs ${jar} cf ${MY_PN}.jar

	if use gcj ; then
		einfo "Building native ${MY_PN} binary ..."
		${gcj} ${CFLAGS} -findirect-dispatch -Wl,-Bsymbolic -o ${MY_PN}-${SLOT} \
			--main=org.eclipse.jdt.internal.compiler.batch.Main ${MY_PN}.jar || die
	fi
}

src_install() {
	if use gcj ; then
		exeinto /usr/bin;
		newexe ${MY_PN} native_${MY_PN}-${SLOT};
		dosym /usr/bin/native_${MY_PN}-${SLOT} /usr/bin/native_${MY_PN};
		newexe ${FILESDIR}/ecj ${MY_PN}-${SLOT}
		dosym /usr/bin/${MY_PN}-${SLOT} /usr/bin/${MY_PN};

		# Don't complain when doing dojar below.
		JAVA_PKG_WANT_SOURCE=1.4
		JAVA_PKG_WANT_TARGET=1.4
	else
		java-pkg_dolauncher ${MY_PN}-${SLOT} --main \
			org.eclipse.jdt.internal.compiler.batch.Main
	fi

	java-pkg_dojar ${MY_PN}.jar
}

pkg_postinst() {
	einfo "To get the Compiler Adapter of ECJ for ANT..."
	einfo " # emerge ant-eclipse-ecj"
	echo
	einfo "To select between slots of ECJ..."
	einfo " # eselect ecj"

	eselect ecj update ecj-${SLOT}
}

pkg_postrm() {
	eselect ecj update
}
