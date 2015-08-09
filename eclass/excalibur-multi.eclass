# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$
#
# Author: Petteri Räty <betelgeuse@gentoo.org>
# Maintained by the java project
#
# The excalibur-multi eclass is a helper for stuff from http://excalibur.apache.org/

inherit excalibur

for module in ${EXCALIBUR_MODULES}; do
	if [[ "${EXCALIBUR_MODULE_USES_PV}" == "false" ]]; then
		SRC_URI="${SRC_URI}
		mirror://apache/excalibur/${PN}/source/${module}-${PV}-src.tar.gz"
	else
		SRC_URI="${SRC_URI}
		mirror://apache/excalibur/${PN}/source/${module}-src.tar.gz"
	fi
done

EXPORT_FUNCTIONS src_unpack src_compile src_test src_install

excalibur-multi_src_unpack() {
	unpack ${A}
	if [[ -n "${@}" ]];then
		for i in ${@};do
			epatch ${i}
		done
	fi

	for module in ${EXCALIBUR_MODULES}; do
		cd ${module}* || die
		excalibur_src_prepare
		cd "${WORKDIR}"
	done
}

excalibur-multi_src_compile() {

	for module in ${EXCALIBUR_MODULES}; do
		cd ${module}* || die
		local jar
		for module in ${EXCALIBUR_MODULES}; do
			for jar in "${WORKDIR}"/${module}/target/*.jar; do
				[[ -e "${jar}" ]] && ln -s "${jar}" target/lib
			done
		done
		java-pkg-2_src_compile
		cd "${WORKDIR}"
	done
}

excalibur-multi_src_test() {
	for module in ${EXCALIBUR_MODULES}; do
		cd ${module}* || die
		excalibur_src_test || die
		cd "${WORKDIR}"
	done
}

excalibur-multi_src_install() {
	for module in ${EXCALIBUR_MODULES}; do
		cd ${module}*
		java-pkg_newjar target/${module}*.jar ${module/-${PV}}.jar
		if use doc; then
			# Doing this manually or we would have api/x/api/
			docinto html/api/${PN}-${sub}
			dohtml -r dist/docs/api/* || die
		fi
		use source && java-pkg_dosrc src/java/*
		cd "${WORKDIR}"
	done
	use doc && java-pkg_recordjavadoc
}
