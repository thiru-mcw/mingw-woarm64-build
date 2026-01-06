#!/usr/bin/env bash
set -euo pipefail

BINUTILS_BRANCH="${1:-woarm64}"
GCC_BRANCH="${2:-native-testing}"
MINGW_BRANCH="${3:-woarm64}"
CYGWIN_BRANCH="${4:-native-testing}"

ARCH="aarch64"
PLATFORM="pc-cygwin"
CRT="msvcrt"

BUILD_PATH="$HOME/build"
CCACHE_DIR_PATH="$HOME/ccache"
TOOLCHAIN_PATH="$HOME/cross-$ARCH-$PLATFORM-$CRT"
ARTIFACT_PATH="$HOME/artifacts"

TOOLCHAIN_PACKAGE_NAME="${ARCH}-${PLATFORM}-toolchain.tar.gz"
TOOLCHAIN_ARTIFACT_NAME="${ARCH}-${PLATFORM}-toolchain"

CCACHE=1
echo "Branches: binutils=$BINUTILS_BRANCH gcc=$GCC_BRANCH mingw=$MINGW_BRANCH cygwin=$CYGWIN_BRANCH"

mkdir -p "$BUILD_PATH" "$CCACHE_DIR_PATH" "$TOOLCHAIN_PATH" "$ARTIFACT_PATH"

# echo "Cleaning old build..."
# rm -rf "$BUILD_PATH"/* "$TOOLCHAIN_PATH"/* || true

chmod +x build.sh
TOOLCHAIN_PATH="$TOOLCHAIN_PATH" ./build.sh

if [ -f ".github/scripts/strip-host-binaries.sh" ]; then
  bash .github/scripts/strip-host-binaries.sh
fi

if [ -f ".github/scripts/strip-target-binaries.sh" ]; then
  bash .github/scripts/strip-target-binaries.sh
fi

echo "Creating toolchain archive..."
tar -czvf "${ARTIFACT_PATH}/${TOOLCHAIN_PACKAGE_NAME}" -C "${TOOLCHAIN_PATH}" .

echo "Native Toolchain Build complete!"
echo "Toolchain archive: ${ARTIFACT_PATH}/${TOOLCHAIN_PACKAGE_NAME}"
