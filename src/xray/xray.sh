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
wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/${XRAY_ZIP_FILE} > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to download zip file: ${XRAY_ZIP_FILE}" && exit 1
fi
echo "Download zip file: ${XRAY_ZIP_FILE} completed"

echo "Unzipping file: /tmp/xray.zip"
unzip -o /tmp/xray.zip -d /tmp/xray > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to unzip file: /tmp/xray.zip" && exit 1
fi
echo "Unzipping file: /tmp/xray.zip completed"

echo "Moving xray binary to /usr/bin/xray"
mv /tmp/xray/xray /usr/bin/xray > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to move xray binary to /usr/bin/xray" && exit 1
fi
echo "Moving xray binary to /usr/bin/xray completed"

echo "Cleaning up temporary files"
rm -rf /tmp/xray /tmp/xray.zip > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to clean up temporary files" && exit 1
fi
echo "Cleaning up temporary files completed"

echo "Setting xray binary to executable"
chmod +x /usr/bin/xray > /dev/null 2>&1
