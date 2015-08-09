# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: clojure.eclass
# @MAINTAINER:
# Daniel Solano Gómez <gentoo@sattvik.com>
# @BLURB: Eclass for Clojure projects
# @DESCRIPTION:
# This eclass extends the functionality of Java eclasses to support Clojure
# projects.
#
# @EXAMPLE:
# The following example uses Clojure 1.0.0 and includes a compatible version of
# clojure-contrib.
# 
# @CODE
#     CLOJURE_VERSION="1.0.0"
#     WANT_CONTRIB="yes"
#     import java-pkg-2 java-ant-2 clojure 
# @CODE

inherit java-pkg-2

local ECLOJURE_CDEPEND=""
local ECLOJURE_DEPEND=""
local ECLOJURE_RDEPEND=""

# @ECLASS-VARIABLE: CLOJURE_VERSION
# @DESCRIPTION:
# Sets the version of Clojure to use.  This variable should be set before the
# eclass is imported.
CLOJURE_VERSION=${CLOJURE_VERSION:-1.0}

# @ECLASS-VARIABLE: WANT_CLOJURE_CONTRIB
# @DESCRIPTION:
# If set, this variable will cause the eclass to depend on a suitable version of
# clojure-contrib.  By default, this value is unset. This variable should be set
# before the eclass is imported.
WANT_CLOJURE_CONTRIB=${WANT_CLOJURE_CONTRIB:-}

# @ECLASS-VARIABLE: CLOJURE_CONTRIB_VERSION
# @DESCRIPTION:
# Sets the version of Clojure-conrib to use.  This variable should be set before
# the eclass is imported.  This variable has no effect if WANT_CLOJURE_CONTRIB
# is not set.  By default, it will use the latest version compatible with
# CLOJURE_VERSION.
CLOJURE_CONTRIB_VERSION=${CLOJURE_CONTRIB_VERSION:-${CLOJURE_VERSION}}

# @ECLASS-VARIABLE: CLOJURE_BOOTSTRAP_MODE
# @DESCRIPTION:
# If set, the eclass will not pull in any Clojure dependencies or export the
# compile function.  This should be used only for the ebuilds that build
# Clojure itself.
[[ -n "${CLOJURE_BOOTSTRAP_MODE}" ]] && CLOJURE_VERSION="bootstrap"

# Check and normalise Clojure version
case "${CLOJURE_VERSION}" in
	1.0*)
		CLOJURE_SLOT="0"
		[[ -n "${JAVA_PKG_DEBUG}" && "${EBUILD_PHASE}" == "setup" ]] \
			&& einfo "Building with Clojure 1.0"
		;;
	1.1*)
		CLOJURE_SLOT="1.1"
		[[ -n "${JAVA_PKG_DEBUG}" && "${EBUILD_PHASE}" == "setup" ]] \
			&& einfo "Building with Clojure 1.1"
		;;
	bootstrap)
		[[ -n "${JAVA_PKG_DEBUG}" && "${EBUILD_PHASE}" == "setup" ]] \
			&& einfo "Bootstrapping Clojure"
		;;
	*)
		die "Clojure version ${CLOJURE_VERSION} is not currently supported by this eclass"
		;;
esac

CLOJURE_ATOM="clojure"
CLOJURE_CONTRIB_ATOM="clojure-contrib"
if [[ "${CLOJURE_SLOT}" != "0" ]]; then
	CLOJURE_ATOM="${CLOJURE_ATOM}-${CLOJURE_SLOT}"
	CLOJURE_CONTRIB_ATOM="${CLOJURE_CONTRIB_ATOM}-${CLOJURE_SLOT}"
fi


# set up Java depends
ECLOJURE_DEPEND="${ECLOJURE_DEPEND} >=virtual/jdk-1.5"
ECLOJURE_RDEPEND="${ECLOJURE_RDEPEND} >=virtual/jre-1.5"

# set up Clojure depends
if [[ "${CLOJURE_VERSION}" != "bootstrap" ]]; then
	ECLOJURE_CDEPEND="${ECLOJURE_CDEPEND} dev-lang/clojure:${CLOJURE_SLOT}"
	if [[ -n ${WANT_CLOJURE_CONTRIB} ]]; then
		ECLOJURE_CDEPEND="${ECLOJURE_CDEPEND} \
			dev-lang/clojure-contrib:${CLOJURE_SLOT}"
	fi
fi

# finalise depends
DEPEND="${ECLOJURE_CDEPEND} ${ECLOJURE_DEPEND}"
RDEPEND="${ECLOJURE_CDEPEND} ${ECLOJURE_RDEPEND}"

if [[ "${CLOJURE_VERSION}" != "bootstrap" ]]; then
	EXPORT_FUNCTIONS src_compile
fi

# @FUNCTION: clojure_src_compile
# @USAGE:
# @DESCRIPTION:
# A thin wrapper around java-pkg-2_src_compile that adds ‘clojure.jar’ and
# ‘clojure-contrib.jar’ properties to EANT_EXTRA_ARGS.
clojure_src_compile() {
	local ant_args="-Dclojure.jar=$(java-pkg_getjars ${CLOJURE_ATOM})"
	if [[ "${DEPEND}" == *dev-lang/clojure-contrib* ]] ; then 
		ant_args="${ant_args} -Dclojure-contrib.jar=$(java-pkg_getjars ${CLOJURE_CONTRIB_ATOM})"
	fi
	EANT_EXTRA_ARGS="${EANT_EXTRA_ARGS} ${ant_args}"
	java-pkg-2_src_compile
}

# @FUNCTION: clojure_dosrc
# @USAGE: [--nojava] [--zip-name NAME] <DIR> ...
# @DESCRIPTION:
# Installs a zip file containing the source for a package so that it can be used
# in IDEs like Eclipse and NetBeans.  It will recursively search for source
# files below each of the given directories and add them to the zip file.  Each
# directory DIR is the base directory for a source tree.
# 
# By default, the zip file’s name is ‘${PN}-src.zip’.  This can be changed by
# using the ‘--zip-name NAME’ argument.  The default is also to zip up both Java
# and Clojure source files, i.e. ‘*.clj’ and ‘*.java’ files.  The packaging of
# Java source files can be disabled through the use of the ‘--nojava’ argument.
clojure_dosrc() {
	debug-print-function ${FUNCNAME} $*

	java-pkg_check-phase install

	[[ ${#} -lt 1 ]] && die "${FUNCNAME}: At least one argument needed"

	local zip_name="${PN}-src.zip"
	local javaincl="-i *.java"
	while [[ ${1} == --* ]]; do
		if [[ ${1} == "--zip-name" ]]; then
			[[ ${#} -lt 2 ]] && die "${FUNCNAME}: --zip-name requires an argument"
			zip_name="${2}"
			[[ ${zip_name} != *.zip ]] \
				&& die "${FUNCNAME}: '${zip_name}' is not a valid zip file name (must end with .zip)"
			[[ ${zip_name} == */* ]] \
				&& die "${FUNCNAME}: '${zip_name}' is not a valid zip file name (must not contain '/')"
			shift
		elif [[ ${1} == "--nojava" ]]; then
			javaincl=""
		else
			die "${FUNCNAME}: Argument '${1}' not recognised"
		fi
		shift
	done

	if ! [[ ${DEPEND} = *app-arch/zip* ]]; then
		local msg="${FUNCNAME}: Called without app-arch/zip in DEPEND"
		java-pkg_announce-qa-violation ${msg}
	fi

	java-pkg_init_paths_

	local zip_path="${T}/${zip_name}"

	local dir
	for dir in "${@}"; do
		[[ ! -d ${dir} ]] && die "${FUNCNAME}: '${dir}' is not a directory"
		pushd ${dir} > /dev/null || die "${FUNCNAME}: Unable to change directories to '${dir}'"
		zip -q -r ${zip_path} . ${javaincl} -i '*.clj'
		local result=$?
		if [[ ${result} != 0 ]]; then
			die "${FUNCNAME}: Failed to zip ${dir}"
		fi
		popd >/dev/null
	done

	# Install the zip
	INSDESTTREE=${JAVA_PKG_SOURCESPATH} \
		doins ${zip_path} || die "Failed to install source"

	JAVA_SOURCES="${JAVA_PKG_SOURCESPATH}/${zip_name}"
	java-pkg_do_write_
}
