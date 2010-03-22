# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/eclipse-ecj/eclipse-ecj-3.5.2.ebuild,v 1.1 2010/03/20 18:00:22 caster Exp $

EAPI=2

inherit java-pkg-2 toolchain-funcs

MY_PN="ecj"
GCC_VER="4.4"
DMF="R-${PV}-201002111343"
S="${WORKDIR}"

DESCRIPTION="A subset of Eclipse Compiler for Java compiled by gcj, serving as javac in gcj-jdk"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${MY_PN}src-${PV}.zip"

IUSE="+native userland_GNU"

LICENSE="EPL-1.0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
SLOT="0"

# for compatibility with java eclass functions
JAVA_PKG_WANT_SOURCE=1.4
JAVA_PKG_WANT_TARGET=1.4

CDEPEND="sys-devel/gcc:${GCC_VER}[gcj]"
DEPEND="${CDEPEND}
	app-arch/unzip
	userland_GNU? ( sys-apps/findutils )"
RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

pkg_setup() {
	if [[ $(gcc-version) != ${GCC_VER} ]]; then
		eerror "Your current GCC version is not set to ${GCC_VER}.* via gcc-config"
		eerror "Please read http://www.gentoo.org/doc/en/gcc-upgrading.xml before you set it"
		die "gcc ${GCC_VER}.* must be selected via gcc-config"
	fi

	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# We don't need the ant adapter here
	rm -f org/eclipse/jdt/core/JDTCompilerAdapter.java || die
	rm -fr org/eclipse/jdt/internal/antadapter || die

	# upstream build.xml excludes this
	rm -f META-INF/eclipse.inf || die

	# these java6 specific classes cannot compile with ecj
	rm -fr org/eclipse/jdt/internal/compiler/{apt,tool}/ || die
}

src_compile() {
	local javac_opts javac java jar

	local gccbin=$(gcc-config -B)
	local gccver=$(gcc-fullversion)

	local gcj="${gccbin}/gcj"
	javac="${gcj} -C"
	jar="${gccbin}/gjar"
	java="${gccbin}/gij"

	mkdir -p bootstrap || die
	cp -pPR org bootstrap || die
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

	if use native; then
		einfo "Building native ${MY_PN} binary, patience needed ..."
		${gcj} ${CFLAGS} -findirect-dispatch -shared -fPIC -Wl,-Bsymbolic \
			-o ${PN}.so ${MY_PN}.jar || die
		${gcj} ${CFLAGS} -findirect-dispatch -Wl ${PN}.so \
			-o ${PN} \
			--main=org.eclipse.jdt.internal.compiler.batch.Main || die

		find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' \
			| xargs ${jar} cf ${MY_PN}.jar
	fi
}

src_install() {
	java-pkg_dojar ${MY_PN}.jar

	if use native; then
		dolib.so ${PN}.so
		dobin ${PN}
	else
		dobin "${FILESDIR}/${PN}"
	fi
}

pkg_postinst() {
	:;
}

pkg_postrm() {
	:;
}
