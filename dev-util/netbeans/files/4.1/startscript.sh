#!/bin/bash

check_symlinks() {
	for file in `find ${1} -type l` ; do

		if ! test -e ${file} ; then
			echo "Broken symlink:"
			echo "${file}"
		fi

	done
}

NBDIR="/usr/share/netbeans-4.1"

check_symlinks ${NBDIR}/ide5/modules/ext
check_symlinks ${NBDIR}/ide5/modules/autoload/ext
check_symlinks ${NBDIR}/enterprise1/config/TagLibraries/JSTL11
check_symlinks ${NBDIR}/platform5/modules/ext

${NBDIR}/bin/netbeans
