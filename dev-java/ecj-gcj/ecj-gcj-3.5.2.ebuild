# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit java-pkg-2

MY_PN="ecj"
DMF="R-${PV}-201002111343"
S="${WORKDIR}"

DESCRIPTION="Eclipse Compiler for Java"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${MY_PN}src-${PV}.zip"

IUSE="+ant gcj userland_GNU"

LICENSE="EPL-1.0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
SLOT="3.5"

CDEPEND=">=app-admin/eselect-ecj-0.5-r1
		 gcj? ( sys-devel/gcc[gcj] )"

JAVA_PKG_WANT_SOURCE=1.4
JAVA_PKG_WANT_TARGET=1.4

DEPEND="${CDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.4
	userland_GNU? ( sys-apps/findutils )"
RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"
PDEPEND="ant? ( ~dev-java/ant-eclipse-ecj-${PV} )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# These have their own package.
	rm -f org/eclipse/jdt/core/JDTCompilerAdapter.java || die
	rm -fr org/eclipse/jdt/internal/antadapter || die

	# upstream build.xml excludes this
	rm META-INF/eclipse.inf
}

src_compile() {
	local javac_opts javac java jar

	javac_opts="$(java-pkg_javac-args) -encoding ISO-8859-1"
	javac="$(java-config -c)"
	java="$(java-config -J)"
	jar="$(java-config -j)"

	find org/ -path org/eclipse/jdt/internal/compiler/apt -prune -o \
		-path org/eclipse/jdt/internal/compiler/tool -prune -o -name '*.java' \
		-print > sources-1.4

	mkdir -p bootstrap || die
	cp -pPR org bootstrap || die
	cd "${S}/bootstrap" || die

	einfo "bootstrapping ${MY_PN} with ${javac} ..."
	${javac} ${javac_opts} @../sources-1.4 || die

	find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' \
		| xargs ${jar} cf ${MY_PN}.jar

	cd "${S}" || die
	einfo "building ${MY_PN} with bootstrapped ${MY_PN} ..."
	${java} -classpath bootstrap/${MY_PN}.jar \
		org.eclipse.jdt.internal.compiler.batch.Main \
		${javac_opts} -nowarn @sources-1.4 || die

	find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' \
		| xargs ${jar} cf ${MY_PN}.jar

	einfo "Building native ${MY_PN} library ..."
	$(gcc-config -B)/gcj ${CFLAGS} -shared -findirect-dispatch -Wl,-Bsymbolic -fPIC \
		-o ${MY_PN}-${SLOT}.so ${MY_PN}.jar || die
}

src_install() {
	dobin ${FILESDIR}/ecj-gcj-${SLOT}
	dolib.so ${MY_PN}-${SLOT}.so
	java-pkg_dojar ${MY_PN}.jar
}

pkg_postinst() {
	$(gcc-config -B)/gcj-dbtool -a $(gcj-dbtool -p) \
		/usr/share/${PN}-${SLOT}/lib/ecj.jar \
		/usr/$(get_libdir)/${MY_PN}-${SLOT}.so
	einfo "To select between slots of ECJ..."
	einfo " # eselect ecj"

	eselect ecj update ecj-gcj-${SLOT}
}

pkg_postrm() {
	eselect ecj update
}
