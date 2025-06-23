#!/bin/sh

PLATFORM=$1

if [ -z "$PLATFORM" ]; then
  ARCH="64"
else
  case "$PLATFORM" in
    linux/386)
      ARCH="32"
      ;;
    linux/amd64)
      ARCH="64"
      ;;
    linux/arm/v6)
      ARCH="arm32-v6"
      ;;
    linux/arm/v7)
      ARCH="arm32-v7a"
      ;;
    linux/arm64|linux/arm64/v8)
      ARCH="arm64-v8a"
      ;;
    linux/ppc64le)
      ARCH="ppc64le"
      ;;
    linux/s390x)
      ARCH="s390x"
      ;;
    *)
      ARCH=""
      ;;
  esac
fi

[ -z "${ARCH}" ] && echo "Error: Not supported OS Architecture" && exit 1

XRAY_ZIP_FILE="Xray-linux-${ARCH}.zip"

echo "Downloading zip file: ${XRAY_ZIP_FILE}"
wget -O /temp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/${XRAY_ZIP_FILE} > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to download zip file: ${XRAY_ZIP_FILE}" && exit 1
fi
echo "Download zip file: ${XRAY_ZIP_FILE} completed"

echo "Unzipping file: /temp/xray.zip"
unzip -o /temp/xray.zip -d /temp/xray > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to unzip file: /temp/xray.zip" && exit 1
fi
echo "Unzipping file: /temp/xray.zip completed"

echo "Moving xray binary to /usr/bin/xray"
mv /temp/xray/xray /usr/bin/xray > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to move xray binary to /usr/bin/xray" && exit 1
fi
echo "Moving xray binary to /usr/bin/xray completed"

echo "Setting xray binary to executable"
chmod +x /usr/bin/xray > /dev/null 2>&1
