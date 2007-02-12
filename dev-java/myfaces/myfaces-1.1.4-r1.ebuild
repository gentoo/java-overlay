# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

BUILD_TOOLS_PN="build-tools"
BUILD_TOOLS_PV="1.0.4"
BUILD_TOOLS_PF="${BUILD_TOOLS_PN}-${BUILD_TOOLS_PV}"

MYFACES_SHARED_IMPL_PN="myfaces-shared-impl"
MYFACES_SHARED_IMPL_PV="2.0.3"
MYFACES_SHARED_IMPL_PF="${MYFACES_SHARED_IMPL_PN}-${MYFACES_SHARED_IMPL_PV}"

DESCRIPTION="The first free open source Java Server Faces implementation"
HOMEPAGE="http://myfaces.apache.org/"
SRC_URI="
	http://dev.gentooexperimental.org/~kiorky/${MYFACES_SHARED_IMPL_PF}.tar.gz
	http://dev.gentooexperimental.org/~kiorky/${PF//-${PR}/}.tar.gz
	http://dev.gentooexperimental.org/~kiorky/${BUILD_TOOLS_PF}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~x86"

COMMON_DEP="
	>=dev-java/commons-logging-1.0.4
	=dev-java/commons-el-1.0*
	=dev-java/servletapi-2.4*
	=dev-java/commons-beanutils-1.7*
	=dev-java/commons-codec-1.3*
	=dev-java/portletapi-1*
	=dev-java/commons-lang-2.1*
	>=dev-java/commons-digester-1.6
	>=dev-java/commons-collections-3.1
	>=dev-java/jakarta-jstl-1.1.0
	>=dev-java/ant-core-1.6
	>=dev-java/velocity-1.4-r3
	=dev-java/jsfapi-1*"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	dev-libs/libxslt
	${COMMON_DEP}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${PF//-${PR}/}"

src_unpack() {
	unpack ${A} ${BUILD_TOOLS_PF}.tar.gz ${MYFACES_SHARED_IMPL_PF}.tar.gz
	cd ${S}/api || die "src_unpack: cant cd to ${S}"
	# for ant (api part)
	java-pkg_jar-from log4j
	java-pkg_jar-from commons-collections
	java-pkg_jar-from velocity
	cp -f "${FILESDIR}/${PV}/build.xml" . || die "src_unpack: cp build.xml failed"
}

#--------------------------------------------------------------
# compile and put the jar in ${workdir}/dist/finaljarname.jar#
#
# @param $1 classpath
# @param $2 final jar name withtout the ".jar"
# @param $* files to compile
#
# options: (must be in first place !)
# --include-resources  enable copy of resources files to a distdir
#
#--------------------------------------------------------------
emaven_emulate() {
	local rs_dir=""
	# parse arguments
	while [[ "${1}" == --* ]]; do
		if [[ "${1}" = "--include-resources" ]]; then
			rs_dir="src/main/resources"
		else
			die "emaven_emulate called with unknown parameter:	${1}"
		fi
		shift
	done

	# ensure there is no .jar
	local final_name="$(basename $2 .jar)"
	local build_dir="${WORKDIR}/build/${final_name}"
	local dist_dir="${WORKDIR}/dist/${final_name}"
	local classpath="$1"
	local src_files=""

	# create destinations dir
	for i in ${build_dir} ${dist_dir};do
		[[ ! -d "$i" ]] && mkdir -p "$i" || die "emaven_emulate: cant create $i"
		# removing old stuff if any
		[[ -d "$i" ]] && rm -rf "$i/*" || die "emaven_emulate: cant clean $i"
	done

	# up to the first dir/file to compile
	# then find all java files to feed the compiler with
	shift 2
	for i in ${@};do
		src_files="$(find "$i" -name "*.java"|perl -i -pe 's/\n/ /g') ${src_files}"
	done
	# let s go with compilation
	ejavac ${classpath} -nowarn -d "${build_dir}" ${src_files}

	# include resources if any
	[[ -n "$rs_dir" ]] 	&& cp -fr ${rs_dir}/* "${build_dir}" \
						|| die "emaven_emulate: cp ${rs_dir} ${build_dir} failed"
	# finally, jarify the whole
	jar cf "${dist_dir}/${final_name}.jar" -C "${build_dir}" . \
		|| die "emaven_emulate:Unable to create jar ${final_name}"
}

src_compile() {
	local classpath="-classpath $(java-pkg_getjars ant-core,velocity,jsfapi-1,servletapi-2.4,commons-el,commons-logging,commons-beanutils-1.7,commons-codec,portletapi-1,commons-lang-2.1,commons-digester,commons-collections,jakarta-jstl):${build_dir}"
	local src_dir="src/main/java"
	local rs_dir="src/main/resources"
	local dist_dir="${WORKDIR}/dist" build_dir="${WORKDIR}/build"

	# compiling and jaring their compenent generation tool
	cd "${WORKDIR}/${BUILD_TOOLS_PF}" \
		|| die "src_compile: cd to ${BUILD_TOOLS_PF} failed"
	emaven_emulate --include-resources "${classpath}" "${BUILD_TOOLS_PN}" \
		"${src_dir}" || die "src_compile: compilation of $BUILD_TOOLS_PN failed"

	# extracting and refactoring the myfaces-shared package
	cd "${WORKDIR}/${MYFACES_SHARED_IMPL_PF}/shared-impl" \
		|| die "src_compile  cd ${MYFACES_SHARED_IMPL_PF} failed"
	eant	-Drefactor.src.dir=../core/src/main/java \
			-Drefactor.output.dir=${build_dir}/${MYFACES_SHARED_IMPL_PN} \
			-Drefactor.package.new=shared_impl \
			"refactor-resources" "refactor-java-sources"
	# finally, jarify the whole
	mkdir -p "${dist_dir}/${MYFACES_SHARED_IMPL_PN}" \
		|| die "src_compile: mkdir ${dist_dir}/${MYFACES_SHARED_IMPL_PN} failed"
	jar cf "${dist_dir}/${MYFACES_SHARED_IMPL_PN}/${MYFACES_SHARED_IMPL_PN}.jar" \
		-C "${build_dir}/${MYFACES_SHARED_IMPL_PN}" . \
		|| die "emaven_emulate: Unable to create jar ${MYFACES_SHARED_IMPL_PN}"

	# API
		cd "${S}/api" || die "src_compile: cd ${S}/api failed"
		# generate special stuff for api
		eant -f ./build.xml "generate-components"
		# compile
		emaven_emulate --include-resources "${classpath}" "${PN}-api" "${src_dir}" \
				|| die "src_compile: compilation of ${PN}-api failed"

	# IMPL
		cd "${S}/impl" || die "src_compile: cd ${S}/impl failed"
		# include some stuff for impl
		mkdir -p "${rs_dir}/META-INF" || die "src_compile: ${rs_dir}/META-INF failed"
		cd src/main/tld || die "src_compile: cd src/main/tld failed"
		for tld in *tld;do
			xsltproc --path . misc/resolve_entities.xsl  $tld>../../../${rs_dir}/META-INF/$tld \
				|| die "src_compile: XSLT generation failed"
		done
		cd ../../.. || die "cd back failed"
		# compile
		emaven_emulate --include-resources \
			"${classpath}:${dist_dir}/${MYFACES_SHARED_IMPL_PN}/${MYFACES_SHARED_IMPL_PN}.jar" \
			"${PN}-impl" "${src_dir}" || die "src_compile: compilation of ${PN}-impl failed"
}

src_install() {
	java-pkg_dojar 	${WORKDIR}/dist/${PN}-impl/${PN}-impl.jar \
					${WORKDIR}/dist/${PN}-api/${PN}-api.jar
}
