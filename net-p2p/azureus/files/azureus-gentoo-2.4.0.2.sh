#! /bin/bash
#
# Copyright (c) 2005, Petteri Räty <betelgeuse@gentoo.org>
# Copyright (c) 2004, Jochen Maes <sejo@gentoo.org>
# Copyright (c) 2004, Karl Trygve Kalleberg <karltk@gentoo.org>
# Copyright (c) 2004, Gentoo Foundation
#
# Licensed under the GNU General Public License, v2

# The Azureus config dir has moved
olddotazudir="${HOME}/.Azureus"
oldgentoocfg="${olddotazudir}/gentoo.config"
dotazudir="${HOME}/.azureus"
gentoocfg="${dotazudir}/gentoo.config"

if [[ -f "${oldgentoocfg}" && -f "${gentoocfg}" ]]; then
	cat > /dev/stderr <<END
You have gentoo.config files in both 
${dotazudir} and
${olddotazudir}
${olddotazudir} is deprecated and you can delete this directory.

END
fi

if [[ -f "${gentoocfg}" ]] ; then
	. "${gentoocfg}"
	echo "using ${gentoocfg}"
elif [[ -f "${oldgentoocfg}" ]]; then
	. "${oldgentoocfg}"
	echo "using ${oldgentoocfg}"
else
	if [[ ! -e "${dotazudir}" ]] ; then
		mkdir "${dotazudir}"
		echo "Creating ${dotazudir}" 
	fi

	# Setup defaults
	UI="swt"

	echo "Creating ${gentoocfg}"

	# Create the config file
	cat > "${gentoocfg}" <<END
# User Interface options:
# console   - console based
# swt       - swt (GUI) based
UI="${UI}"

# Options you want to pass to the java binary
JAVA_OPTIONS=""
END

fi

#cd "${dotazudir}"

if [[ ! -z "${UI_OPTIONS}" ]]; then
	echo '${UI_OPTIONS} is deprecated, use ${UI} instead' > /dev/stderr
fi

CLASSPATH="$(java-config -p bcprov,junit,log4j,commons-cli-1,swt-3,azureus)"
exec $(java-config --java)  -cp "${CLASSPATH}" \
	-Djava.library.path=$(java-config -i swt-3) \
	-Dazureus.install.path="${dotazudir}" \
	${JAVA_OPTIONS} org.gudy.azureus2.ui.${UI}.Main "${@}"
