# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: nichoj
# Additionnal changes: kiorky kiorky@cryptelium.net
# Purpose:
#

inherit java-pkg-2

TOOLS_DEPEND="dev-java/ant-core
			  dev-java/ant-pretty
			  dev-java/ant-tasks
			  =dev-java/bsf-2.3*
			  dev-java/buildmagic-tasks
			  =dev-java/eclipse-ecj-3.1*
			  =dev-java/junit-3.8*
			  dev-java/xalan
			  =dev-java/xerces-2.6.2*
			  =dev-java/xml-commons-external-1.3*
			  dev-java/xml-commons-resolver"

jboss-4_get-thirdparty-depend
DEPEND="${DEPEND} ${TOOLS_DEPEND} ${PN_THIRDPARTY_DEPEND}
		dev-java/xdoclet
		=dev-java/gnu-regexp-1*
		dev-java/gnu-jaxp
		=dev-java/jaxen-1.1*
		"

SLOT="4"

MODULE="${PN/jboss-module-/}"

JBOSS_ROOT="${WORKDIR}/${PN%%-*}-${PV}-src"
JBOSS_THIRDPARTY="${JBOSS_ROOT}/thirdparty"
S="${JBOSS_ROOT}/${MODULE}"

THIRDPARTY_P="jboss-thirdparty-${PV}"
TOOLS_P="jboss-tools-${PV}"
GENTOO_CONF="jboss-${PVR}.mappings.sh"
BASE_URL="http://dev.gentooexperimental.org/~kiorky/"
BASE_URL_ORIG="http://gentooexperimental.org/distfiles"
ECLASS_URI="${BASE_URL}/${TOOLS_P}.tar.bz2 ${BASE_URL}/${THIRDPARTY_P}.tar.bz2
			${BASE_URL}/${GENTOO_CONF}
			"
MY_A="${P}.tar.bz2 ${THIRDPARTY_P}.tar.bz2"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"

EXPORT_FUNCTIONS src_unpack src_compile src_install

quiet_pushd() {
	pushd $@ > /dev/null
}

quiet_popd() {
	popd $@ > /dev/null
}


# TODO: add error checking
jboss-4_fix-dir() {
	debug-print-function ${FUNCNAME} $*

	local relative_dir=${1}
	debug-print "relative_dir=${relative_dir}"

	# We want to get the contents of a variable, with the same name as
	# relative_dir, with _ substituted for -, and suffixed with _pkgs
	# The contents of said variable should be a comma separated list of
	# packages, in the format java-config -p would like
	# to rename a jar the separator will be space
	# eg : to get
	#		* all jars from jarfoo
	#		* jarbar.jar from jarbar renamed in jarjar.jar
	#		* in thirdparty/foo/lib
	#     thirdparty_foo_lib_pkgs="jarfoo,jarbar jarbar.jar jarjar.jar"
	local temp=${relative_dir//\//_} # convert / to _
	temp="${temp//-/_}_pkgs" # convert - to _
	debug-print "variable name=${temp}"
	eval java_pkg_args=\$$temp # get the contents of temp
	# take care about whitespaces in list
	echo ${java_pkg_args}
	# remove spaces before beginning or after comma
	# so we can do multilines in the mapping file
	# then replace all " " by __ and the "," by " "
	# for the for statement
	java_pkg_args=$(echo ${java_pkg_args}|\
					sed -re "s/(^|,)\s*/\1/g"|\
					sed -re "s/\s+/__/g" |\
					sed -re "s/,/ /g"     \
					|| die "substitute failed")
	debug-print "value of ${temp}=${java_pkg_args}"

	local full_dir=${JBOSS_ROOT}/${relative_dir}
	einfo "Fixing jars in ${full_dir}"

	mkdir -p "${full_dir}" || die "mkdir failed"

	quiet_pushd "${full_dir}"
	for i in $(echo "${java_pkg_args}"); do
		java-pkg_jar-from ${i//__/ }
	done
	quiet_popd
}

# fix all the thirdparty libraries for this module
jboss-4_fix-thirdparty() {
	debug-print-function ${FUNCNAME} $*

	for dir in $(jboss-4_get-dirs-to-fix); do
		jboss-4_fix-dir thirdparty/${dir}
	done
	jboss-4_fix-dir thirdparty/xdoclet-xdoclet/lib
}

# lookup which directories need to be fixed for this module, and its
# dependencies
jboss-4_get-dirs-to-fix() {
	debug-print-function ${FUNCNAME} $*

	local dirs_to_fix=$(jboss-4_get-dirs-to-fix-for-module ${MODULE})
	for dependency in $(jboss-4_get-modules-to-fix); do
		dirs_to_fix="$(jboss-4_get-dirs-to-fix-for-module ${dependency}) ${dirs_to_fix}"
	done

	# get unique dirs... behold bash voodoo magic !
	dirs_to_fix=$(echo ${dirs_to_fix} | \
		sed -e 's/ /\n/g'| sort | uniq | sed -e 's/\n/ /g')

	echo ${dirs_to_fix}
}

jboss-4_get-dirs-to-fix-for-module() {
	debug-print-function ${FUNCNAME} $*

	local varname=${1//-/_}_library_dirs
	echo "jboss-4_get-dirs-to-fix:varname=${varname}" 1>&2
	local dirs_to_fix=$(eval echo \$$varname|sed -re "s/\s\s+//g")
	echo "jboss-4_get-dirs-to-fix:dirs_to_fix=${dirs_to_fix}" 1>&2

	echo ${dirs_to_fix}
}

# lookup which depends we must have to ensure third deps own dependencies
jboss-4_get-thirdparty-depend() {
	debug-print-function ${FUNCNAME} $*
	local depend=""
	# getting dependencies
	local dirs_to_fix=$(jboss-4_get-dirs-to-fix-for-module ${MODULE})
	# getting the third dep. according direcotries
	for dependency in $(jboss-4_get-modules-to-fix); do
		dirs_to_fix="$(jboss-4_get-dirs-to-fix-for-module ${dependency}) ${dirs_to_fix}"
	done

	# get unique dirs... behold bash voodoo magic !
	dirs_to_fix=$(echo ${dirs_to_fix} | \
		sed -e 's/ /\n/g'| sort | uniq | sed -e 's/\n/ /g')

	# for each thirddep, getting the dependencies from the portage tree
	# and apend them to DEPEND
	for dir in $(jboss-4_get-dirs-to-fix); do
		local temp=${relative_dir//\//_} # convert / to _
		temp="${temp//-/_}_depend" # convert - to _
		eval java_pkg_depend=\$$temp # get the contents of temp
		java_pkg_depend=$(echo ${java_pkg_depend} | \
			sed -e 's/ /\n/g'| sort | uniq | sed -e 's/\n/ /g')
		depend="${depend} ${java_pkg_depend}"
	done

	echo ${depend}
}


# lookup which modules should be fixed for the current module
jboss-4_get-modules-to-fix() {
	debug-print-function ${FUNCNAME} $*

	local varname="${MODULE//-/_}_module_depends"
	local modules_to_fix=$(eval echo \$$varname)
	echo ${modules_to_fix}
}

jboss-4_fix-modules() {
	debug-print-function ${FUNCNAME} $*

	for module in $(jboss-4_get-modules-to-fix); do
		jboss-4_fix-module ${module}
	done
}

# get the jar files for a particular jboss module
jboss-4_fix-module() {
	debug-print-function ${FUNCNAME} $*

	local module=${1}
	local pkg=jboss-module-${module}-${SLOT}
	local dir=${JBOSS_ROOT}/${module}/output/lib
	local marker="${dir}/../build-marker"
	einfo "Populating ${dir}"
	mkdir -p ${dir}

	quiet_pushd ${dir}
	java-pkg_jar-from ${pkg} || die "Couldn't find a package.."
	local libdir="/usr/share/${pkg}/lib"
	for jar in ${libdir}/*.jar; do
		if [ -d "${jar}" ]; then
			ln -sf ${jar}
		fi
	done
	# TODO: only perform this if there are actual files
	local servicedir="/usr/share/${pkg}/services"
	for sar in ${servicedir}/*.sar; do
		if [ -d "${sar}" ]; then
			ln -sf ${sar}
		fi
	done
	quiet_popd
}

# unpack source, then fix the shared build jars
jboss-4_src_unpack() {
	debug-print-function ${FUNCNAME} $*

	source "${DISTDIR}/${GENTOO_CONF}" || die "source failed"

	# NOTE: don't use java-ant's src_unpack!
	# it cases some funky issues with buildmagic
	unpack ${MY_A}

	cd "${S}" || die "cd failed"

	unpack "${TOOLS_P}.tar.bz2"

	# workaround because something depends on this being around
	mkdir -p "${JBOSS_THIRDPARTY}/sun-servlet/lib" || die "mkdir failed"

#	jboss-4_fix-dir tools/lib
	jboss-4_fix-thirdparty
	[[ -d ${JBOSS_THIRDPARTY}/apache-tomcat/lib ]] &&
		ln -s /usr/share/tomcat-5.5/server/webapps/manager/WEB-INF/lib/catalina-manager.jar \
		${JBOSS_THIRDPARTY}/apache-tomcat/lib || die "ln catalina-manager.jar failed"

	#jboss-4_fix-modules
}

jboss-4_src_compile() {
	debug-print-function ${FUNCNAME} $*

	cd ${S}

	#local antflags="${ANT_TARGET:-jars}"
	# 23/10/06 ali_bush:increase stack size used
	local antflags="${ANT_TARGET:-jars}"

	export ANT_OPTS="${ANT_OPTS} -Xmx512m"
	eant -lib $(java-pkg_getjars buildmagic-tasks) ${antflags}
}

jboss-4_src_install() {
	debug-print-function ${FUNCNAME} $*

#	for jar in output/lib/*.jar; do
#		if [ -d ${jar} ]; then
#			einfo "Creating ${jar}"
#			debug-print-function "directory \"jar\" found. jar'ing it for real"
#
#			quiet_pushd ${jar}
#			local newjar=$(basename ${jar})
#			jar cvf ${newjar} *
#			java-pkg_dojar ${newjar}
#			quiet_popd
#		elif [ -f ${jar} ]; then
#			einfo "Instaling ${jar}"
#			java-pkg_dojar ${jar}
#		fi
#	done
	for jar in output/lib/*.jar; do
		jboss-4_dojar ${jar}
	done

	for sar in output/lib/*.sar; do
		jboss-4_dosar ${sar}
	done
}

jboss-4_dojar() {
	# Check for arguments
	if [ -z "$*" ] ; then
		die "at least one argument needed"
	fi

	# Set install paths
	local sharepath="${DESTTREE}/share"
	local pkg_name
	if [ "$SLOT" == "0" ] ; then
		pkg_name="${PN}"
	else
		pkg_name="${PN}-${SLOT}"
	fi

	local shareroot="${sharepath}/${pkg_name}"
	local jarpath="${shareroot}/lib"

	# Make sure directory is created
	if [ ! -d "${D}${jarpath}" ] ; then
		install -d "${D}${jarpath}"
	fi
	for i in $*; do
		if [ -f "${i}" ]; then
			java-pkg_dojar ${i}
		elif [ -d "${i}" ]; then
			cp -pPR ${i} ${D}/${jarpath}/
		fi
	done

}

# This could be migrated to java-pkg perhaps
jboss-4_dosar() {
	# Check for arguments
	if [ -z "$*" ] ; then
		die "at least one argument needed"
	fi
	# Set install paths
	local sharepath="${DESTTREE}/share"
	local pkg_name
	if [ "$SLOT" == "0" ] ; then
		pkg_name="${PN}"
	else
		pkg_name="${PN}-${SLOT}"
	fi

	local shareroot="${sharepath}/${pkg_name}"
	local service_path="${shareroot}/services"

	# Make sure directory is created
	if [ ! -d "${D}${service_path}" ] ; then
		install -d "${D}${service_path}"
	fi

	for i in $*; do
		# TODO add checking that the sar is a directory?
		cp -pPR ${i} ${D}/${service_path}/
	done
}

#################################################
#################################################
#################################################
#################################################
# Below this point is old stuff, please disregard
# it is mostly a reference for what jars go where
#################################################
#################################################
#################################################
#################################################
#jboss-4_fix-tools() {
#	debug-print-function "Fixing jars in ${JBOSS_ROOT}/tools/lib"
#	quiet_pushd ${JBOSS_ROOT}/tools/lib
#	java-pkg_jar-from ${ANT_JAVAMAIL}
#	java-pkg_jar-from ${ANT_JUNIT}
#	java-pkg_jar-from ${ANT_LAUNCHER}
#	java-pkg_jar-from ${ANT_NODEPS}
#	java-pkg_jar-from ${ANT_TRAX}
#	java-pkg_jar-from ${ANT_XSLP}
#	java-pkg_jar-from ${ANT}
#	java-pkg_jar-from ${BSF}
#	java-pkg_jar-from ${BUILDMAGIC_TASKS}
#	java-pkg_jar-from ${JUNIT}
#	java-pkg_jar-from ${RESOLVER}
#	java-pkg_jar-from ${XALAN}
#	java-pkg_jar-from ${XERCES_IMPL}
#	java-pkg_jar-from ${XML_APIS}
#	quiet_popd
#}
#
#jboss-4_clean_jars() {
#	einfo "Removing jars from ${JBOSS_ROOT}"
#	find ${JBOSS_ROOT} -name *.jar -exec rm {} \;
#}
#
#jboss-4_fix-apache-addressing() {
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-addressing/lib
#	quiet_popd
#}
#
#jboss-4_fix-apache-avalon() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/apache-avalon/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-avalon/lib
#	java-pkg_jar-from ${AVALON_FRAMEWORK}
#	java-pkg_jar-from ${LOGKIT}
#	quiet_popd
#}
#
#jboss-4_fix-apache-bcel() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/apache-bcel/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-bcel/lib
#	java-pkg_jar-from ${BCEL}
#	quiet_popd
#}

#jboss-4_fix-apache-commons() {
#	# RDEPENDS:
#	# 	=dev-java/commons-beanutils-1.6*
#	#	dev-java/commons-codec
#	#	dev-java/commons-collections
#	#	dev-java/commons-digester
#	#	dev-java/commons-discovery
#	#	dev-java/commons-fileupload
#	#	dev-java/commons-httpclient
#	#	dev-java/commons-lang
#	#	dev-java/commons-logging
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/apache-commons/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-commons/lib
#	java-pkg_jar-from ${COMMONS_BEANUTILS}
#	java-pkg_jar-from ${COMMONS_CODEC} commons-codec-1.2.jar
#	java-pkg_jar-from ${COMMONS_COLLECTIONS}
#	java-pkg_jar-from ${COMMONS_DIGESTER} commons-digest-1.6.jar
#	java-pkg_jar-from ${COMMONS_DISCOVERY}
#	java-pkg_jar-from ${COMMONS_FILEUPLOAD}
#	java-pkg_jar-from ${COMMONS_HTTPCLIENT}
#	java-pkg_jar-from ${COMMONS_LANG} commons-lang-1.0.jar
#	java-pkg_jar-from ${COMMONS_LOGGING}
#	java-pkg_jar-from ${COMMONS_LOGGING_API}
#	quiet_popd
#}
#
#jboss-4_fix-apache-jaxme() {
#	# bug #94432
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-jaxme
#	quiet_popd
#}
#
#jboss-4_fix-apache-log4j() {
#	# RDEPENDS:
#	#	dev-java/log4j
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/apache-log4j/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-log4j/lib
#	java-pkg_jar-from ${LOG4J}
#	# TODO: replace snmpTrapAppender.jar
#	quiet_popd
#}
#
#jboss-4_fix-apache-myfaces() {
#	# bug #94434
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-myfaces/lib
#	quiet_popd
#}
#
#jboss-4_fix-apache-scout() {
#	# bug #94460
#	quiet_pushd ${thirdparty}/apache-scout/lib
#	quiet_popd
#}
#
#jboss-4_fix-apache-slide() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/apache-slide/client/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-slide/client/lib
#	java-pkg_jar-from ${WEBDAVLIB}
#	quiet_popd
#}
#
#jboss-4_fix-apache-tomcat-50() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/apache-tomcat-50"
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-tomcat50
#	java-pkg_jar-from ${TOMCAT5}
#	java-pkg_jar-from ${SERVLET24}
#	java-pkg_jar-from ${COMMONS_BEANUTILS}
#	java-pkg_jar-from ${COMMONS_COLLECTIONS}
#	java-pkg_jar-from ${COMMONS_EL}
#	java-pkg_jar-from ${COMMONS_DIGESTER}
#	java-pkg_jar-from ${COMMONS_LOGGING}
#	java-pkg_jar-from ${COMMONS_MODELER}
#	java-pkg_jar-from ${JAKARTA_REGEXP}
#	quiet_popd
#}
#
#jboss-4_fix-apache-tomcat-55() {
#	# bug #75224
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-tomcat-55
#	quiet_popd
#}
#
#jboss-4_fix-apache-velocity() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/apache-velocity"
#	quiet_pushd ${JBOSS_THIRDPARTY}
#	java-pkg_jar-from ${VELOCITY}
#	quiet_popd
#}
#
#jboss-4_fix-apache-xalan() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/apache-xalan/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-xalan/lib
#	java-pkg_jar-from ${XALAN}
#	quiet_popd
#}
#
#jboss-4_fix-apache-xerces() {
##	fix_dir ${JBOSS_THIRDPARTY}/apache-xerces/lib \
##		"${RESOLVER}" \
##		"${XERCES_IMPL}" \
##		"${XML_APIS}"
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/apache-xerces/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-xerces/lib
#	java-pkg_jar-from ${RESOLVER}
#	java-pkg_jar-from ${XERCES_IMPL}
#	java-pkg_jar-from ${XML_APIS}
#	quiet_popd
#}
#
#jboss-4_fix-apache-xmlsec() {
#	# bug #94438
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/apache-xmlsec/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/apache-xmlsec/lib
#	java-pkg_jar-from ${XMLSEC}
#	quiet_popd
#}
#
#jboss-4_fix-beanshell() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/beahshell-beanshell/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/beanshell-beanshell/lib
#	java-pkg_jar-from ${BSH} bsh-1.3.0.jar
#	quiet_popd
#}
#
#jboss-4_fix-bouncycastle() {
#	# bug #944346
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/bouncycastle/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/bouncycastle/lib
#	java-pkg_jar-from ${BCPROV} bcprov-jdk14-124.jar
#	quiet_popd
#}
#jboss-4_fix-cglib() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/cglib/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/cglib/lib
#	java-pkg_jar-from ${CGLIB} cglib-2.1.jar
#	quiet_popd
#}
#
#jboss-4_fix-dom4j() {
#	# bug #63268
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/dom4j-dom4j/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/dom4j-dom4j/lib
#	java-pkg_jar-from ${DOM4J}
#	java-pkg_jar-from ${JAXEN} jaxen-1.1-beta-4.jar
#	quiet_popd
#}
#
#jboss-4_fix-eclipse-jdt() {
#	# bug #80526
#	quiet_pushd ${JBOSS_THIRDPARTY}/eclipse-jdt/lib
#	quiet_popd
#}
#
#jboss-4_fix-gjt-jpl-util() {
#	# bug #94439
#	quiet_pushd ${JBOSS_THIRDPARTY}/gjt-jpl-util/lib
#	quiet_popd
#}
#
#jboss-4_fix-gnu-getopt() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/gnu-getopt/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/gnu-getopt/lib
#	java-pkg_jar-from ${GNU_GETOPT} getopt.jar
#	quiet_popd
#}
#
#jboss-4_fix-gnu-regexp() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/gnu-regexp/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/gnu-regexp/lib
#	java-pkg_jar-from ${GNU_REGEXP}
#	quiet_popd
#}
#
#jboss-4_fix-hibernate() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/hibernate/lib"
#	# TODO: need a new hibernate ebuild, bug #91986
#	quiet_pushd ${JBOSS_THIRDPARTY}/hibernate/lib
#	java-pkg_jar-from ${ANTLR}
#	java-pkg_jar-from ${ASM_ATTRS}
#	java-pkg_jar-from ${ASM}
#	#java-pkg_jar-from ${HIBERNATE3}
#	#java-pkg_jar-from ${HIBERNATE_METADATA}
#	quiet_popd
#}
#
#jboss-4_fix-hsqldb() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/hsqldb-hsqldb/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/hsqldb-hsqldb/lib
#	java-pkg_jar-from ${HSQLDB}
#	quiet_popd
#}
#
#jboss-4_fix-ibm-wsdl4j() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/ibm-wsdl4j/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/ibm-wsdl4j/lib
#	java-pkg_jar-from ${WSDL4J}
#	quiet_popd
#}
#
#jboss-4_fix-jacorb() {
#	# Not in portage yet, bug #93396
#	# TODO: where are jacorb_g.jar and idl_g.jar from??
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/jacorb-jacorb/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/jacorb-jacorb/lib
#	java-pkg_jar-from ${JACORB}
#	java-pkg_jar-from ${IDL}
#	quiet_popd
#
#}
#
#jboss-4_fix-javagroups() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/javagroups-javagroups/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/javagroups-javagroups/lib
#	java-pkg_jar-from ${JGROUPS}
#	quiet_popd
#}
#
#jboss-4_fix-javassist() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/javassist-javassist"
#	quiet_pushd ${JBOSS_THIRDPARTY}/javassist/lib
#	java-pkg_jar-from ${JAVASSIST}
#	quiet_popd
#}
#
#jboss-4_fix-jfreechart() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/jfreechart-jfreechart/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/jfreechart/lib
#	# jfreechart.jar may be patched!
#	#java-pkg_jar-from ${JFREECHART}
#	java-pkg_jar-from ${JCOMMON}
#	quiet_popd
#}
#
#jboss-4_fix-juddi() {
#	# bug #94441
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/juddi-juddi/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/juddi-juddi/lib
#	java-pkg_jar-from ${JUDDI}
#	# TODO replace war file
#	quiet_popd
#}
#
#jboss-4_fix-junit() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/junit-junit/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/junit-junit/lib
#	java-pkg_jar-from ${JUNIT}
#	quiet_popd
#}
#
#jboss-4_fix-junitejb() {
#	# bug #94442
#	quiet_pushd ${JBOSS_THIRDPARTY}/junitejb/junitejb/lib
#	quiet_popd
#}
#
#jboss-4_fix-odmg() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/odmg/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/odmg/lib
#	java-pkg_jar-from ${ODMG}
#	quiet_popd
#}
#
#jboss-4_fix-opensaml() {
#	# bug #94428
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/opensaml/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/opensaml/lib
#	java-pkg_jar-from ${OPENSAML}
#	quiet_popd
#}
#
#jboss-4_fix-opennms() {
#	# bug #94426
#	quiet_pushd ${JBOSS_THIRDPARTY}/opennms/lib
#	quiet_popd
#}
#
#jboss-4_fix-oswego-concurrent() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/oswego-concurrent/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/oswego-concurrent/lib
#	java-pkg_jar-from ${CONCURRENT}
#	quiet_popd
#}
#
#jboss-4_fix-qdox() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/qdox/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/qdox/lib
#	java-pkg_jar-from ${QDOX}
#	quiet_popd
#}
#
#jboss-4_fix-sleepycat() {
#	# bug #94430
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/sleepycat/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/sleepycat/lib
#	java-pkg_jar-from ${JE}
#	quiet_popd
#}
#
#jboss-4_fix-sun-jaf() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/sun-jaf/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/sun-jaf/lib
#	java-pkg_jar-from ${ACTIVATION}
#	quiet_popd
#}
#
#jboss-4_fix-sun-javacc() {
#	# I don't think our packaged javacc.jar is a drop in replacement for
#	# JavaCC.zip
#	#einfo "Fixing jars in thirdparty/sun/javacc/lib"
#	quiet_pushd ${thirdparty}/sun/javacc/lib
#	#java-pkg_jar-from javacc javacc.jar JavaCC.zip
#	quiet_popd
#}
#
#jboss-4_fix-sun-javamail() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/sun-javamail/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/sun-javamail/lib
#	java-pkg_jar-from ${IMAP}
#	java-pkg_jar-from ${MAIL}
#	java-pkg_jar-from ${MAILAPI}
#	java-pkg_jar-from ${POP3}
#	java-pkg_jar-from ${SMTP}
#	quiet_popd
#}
#
#jboss-4_fix-sun-jaxp() {
#	quiet_pushd ${JBOSS_THIRDPARTY}/sun-jaxp/lib
#	quiet_popd
#}
#
#jboss-4_fix-sun-jmf() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/sun-jmf/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/sun-jmf/lib
#	java-pkg_jar-from ${JMF}
#	quiet_popd
#}
#
#jboss-4_fix-sun-jmx() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/sun-jmx/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/sun-jmx/lib
#	java-pkg_jar-from ${JMXRI}
#	java-pkg_jar-from ${JMXTOOLS}
#	# TODO: need to replace jmxgrinder.jar
#	quiet_popd
#}
#
#jboss-4_fix-sun-servlet() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/sun-servlet/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/sun-servlet/lib
#	java-pkg_jar-from ${SERVLET24}
#	quiet_popd
#}
#
#jboss-4_fix-trove() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/trove/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/trove/lib
#	java-pkg_jar-from ${TROVE}
#	quiet_popd
#}
#
#jboss-4_fix-wukta-dtdparser() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/wutka-dtdparser/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/wutka-dtdparser/lib
#	java-pkg_jar-from ${DTDPARSER}
#	quiet_popd
#}
#
#jboss-4_fix-xdoclet() {
#	# I suspect that these are patched by jboss...
#	#einfo "Fixing jars in xdoclet-xdoclet/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/xdoclet/xdoclet/lib
#	#java-pkg_jar-from ${COMMONS_LOGGING}
#	#java-pkg_jar-from ${XDOCLET}
#	#java-pkg_jar-from ${XDOCLET_BEA}
#	#java-pkg_jar-from ${XDOCLET_EJB}
#	#java-pkg_jar-from ${XDOCLET_JAVA}
#	#java-pkg_jar-from ${XDOCLET_JBOSS}
#	#java-pkg_jar-from ${XDOCLET_JDO}
#	#java-pkg_jar-from ${XDOCLET_JMX}
#	#java-pkg_jar-from ${XDOCLET_WEB}
#	#java-pkg_jar-from ${XDOCLET_XDOCLET}
#	#java-pkg_jar-from ${XJAVADOC}
#	quiet_popd
#}
#
#jboss-4_fix-xml-sax() {
#	einfo "Fixing jars in ${JBOSS_THIRDPARTY}/xml-sax/lib"
#	quiet_pushd ${JBOSS_THIRDPARTY}/xml-sax/lib
#	java-pkg_jar-from ${SAX}
#	quiet_popd
#}
#
#jboss-4_fix-jboss-common() {
#	einfo "Populating ${JBOSS_ROOT}/common/output/lib"
#	mkdir -p ${JBOSS_ROOT}/common/output/lib
#	quiet_pushd ${JBOSS_ROOT}/common/output/lib
#	java-pkg_jar-from ${JBOSS_COMMON}
#	quiet_popd
#}
#
#jboss-4_fix-jboss-jmx() {
#	einfo "Populating ${JBOSS_ROOT}/jmx/output/lib"
#	mkdir -p ${JBOSS_ROOT}/jmx/output/lib
#	quiet_pushd ${JBOSS_ROOT}/jmx/output/lib
#	java-pkg_jar-from ${JBOSS_JMX}
#	quiet_popd
#}
#
##fix_dir() {
#	local target_dir=${1};
#	local jar_from_commands=${@##${1}} # all arguments, except the first
#
#	einfo "Fixing jars in ${target_dir}"
#	quiet_pushd ${target_dir} # save the current directory
#
#	for jar_from in ${jar_from_commands}; do
#		java-pkg_jar-from ${jar_from}
#	done
#
#	quiet_popd # restore previous directory
#}
