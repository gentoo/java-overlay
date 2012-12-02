
# We have patched Minecraft to not download or install its JAR
# libraries but doing the same for the native libraries doesn't seem
# so easy. Instead we create symlinks and make the natives directory
# read-only, which seems to fool it sufficiently.

NATIVES="${HOME}/.minecraft/bin/natives"
mkdir -p "${NATIVES}"
chmod +w "${NATIVES}"

ln -snf /usr/lib/libopenal.so "${NATIVES}"/libopenal.so
ln -snf $(ls -U /usr/lib/jinput/libjinput-linux{64,}.so 2> /dev/null | head -n1) "${NATIVES}"/libjinput-linux.so
ln -snf $(ls -U /usr/lib/lwjgl-2.8/liblwjgl{64,}.so 2> /dev/null | head -n1) "${NATIVES}"/liblwjgl.so

ln -snf libopenal.so "${NATIVES}"/libopenal64.so
ln -snf libjinput-linux.so "${NATIVES}"/libjinput-linux64.so
ln -snf liblwjgl.so "${NATIVES}"/liblwjgl64.so

chmod a-w "${NATIVES}"

# Create a dummy lwjgl.jar to fool MCPatcher.
touch "${HOME}/.minecraft/bin/lwjgl.jar"

