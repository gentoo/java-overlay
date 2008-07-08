# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-utils-2

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

DEPEND="gcj? ( >=sys-devel/gcc-4.3.1 )
	!gcj? ( !java6? ( >=virtual/jdk-1.4 ) 
		java6? ( >=virtual/jdk-1.6 ) )"
RDEPEND=${DEPEND}

pkg_setup() {
	if use gcj && ! built_with_use sys-devel/gcc gcj; then
		eerror "Building with gcj requires that gcj was compiled as part of gcc.";
		eerror "Please rebuild sys-devel/gcc with USE=\"gcj\"";
		die "Rebuild sys-devel/gcc with gcj support"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# own package
	rm -f org/eclipse/jdt/core/JDTCompilerAdapter.java
	rm -fr org/eclipse/jdt/internal/antadapter

	if use gcj || ! use java6; then
	  rm -fr org/eclipse/jdt/internal/compiler/tool/ \
		 org/eclipse/jdt/internal/compiler/apt/
	fi

	# add GCCMain support
	epatch "${FILESDIR}"/${PN}-gcj-${PV/_*}.patch
}

src_compile() {
	local javac="javac" java="java" jar="jar"

	if use gcj; then
	  local gccbin="$(gcc-config -B $(ls /etc/env.d/gcc/*4.3.?|head -1))";
	  local gcj="${gccbin}/gcj";
	  javac="${gcj} -C";
	  jar="${gccbin}/gjar";
	  java="${gccbin}/gij";
	fi

	mkdir -p bootstrap
	cp -a org bootstrap
	einfo "bootstrapping ${MY_PN} with ${javac}"

	cd "${S}"/bootstrap
	find org/ -name '*.java' | xargs ${javac}

	einfo "creating bootstrap jar file"
	find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' | \
		xargs ${jar} cf ${MY_PN}.jar

	if use gcj; then
		einfo "building ecj binary";
		${gcj} ${CFLAGS} -findirect-dispatch -Wl,-Bsymbolic -o ../${MY_PN} \
			--main=org.eclipse.jdt.internal.compiler.batch.Main ${MY_PN}.jar;
	fi

	einfo "build ${MY_PN} with bootstrapped ${MY_PN}"
	cd "${S}"
	${java} -classpath bootstrap/${MY_PN}.jar \
		org.eclipse.jdt.internal.compiler.batch.Main -encoding ISO-8859-1 org \
		|| die "${MY_PN} build failed!"

	einfo "creating jar file"
	find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' | \
		xargs ${jar} cf ${MY_PN}.jar
}

src_install() {
	java-pkg_dojar ${MY_PN}.jar
	if use gcj; then
		exeinto /usr/bin;
		newexe ${MY_PN} native_${MY_PN}-${SLOT};
		dosym /usr/bin/native_${MY_PN}-${SLOT} /usr/bin/native_${MY_PN};
		dosym /usr/bin/native_${MY_PN}-${SLOT} /usr/bin/${MY_PN};
	else
		java-pkg_dolauncher ${MY_PN}-${SLOT} --main \
			org.eclipse.jdt.internal.compiler.batch.Main;
	fi
}

pkg_postinst() {
	ewarn "to get the Compiler Adapter of ECJ for ANT do"
	ewarn "	# emerge ant-eclipse-ecj"
}
