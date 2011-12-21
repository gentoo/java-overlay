
if [[ -z "$1" ]] || [[ "${1:0:1}" == "-" ]]; then
	NAME="main"
	echo "Multiverse name not specified. Defaulting to \"${NAME}\"." >&2
else
	NAME="$1"
	echo "Using multiverse name \"${NAME}\"." >&2
    shift
fi

if [[ "$(whoami)" == "@GAMES_USER_DED@" ]]; then
	gjl_pwd="/var/lib/minecraft/${NAME}"
else
	gjl_pwd="${HOME}/.minecraft/servers/${NAME}"
fi

echo "Multiverse directory is ${gjl_pwd}." >&2
mkdir -p "${gjl_pwd}"/{lib,plugins/update}

if [[ "$(whoami)" == "@GAMES_USER_DED@" ]]; then
	chmod g+ws "${gjl_pwd}"/{lib,plugins,plugins/update}
fi

for LIB in "h2" "mysql jdbc-mysql" "sqlite sqlite-jdbc" "postgresql jdbc-postgresql"; do
    SRC="/usr/share/${LIB#* }/lib/${LIB#* }.jar"
    DEST="${gjl_pwd}/lib/${LIB% *}.jar"

    if [[ -f "${SRC}" ]]; then
        ln -snf "${SRC}" "${DEST}"
    elif [[ ! -f "${DEST}" ]]; then
        rm -f "${DEST}"
    fi
done

