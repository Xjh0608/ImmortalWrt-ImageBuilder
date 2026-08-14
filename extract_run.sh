#!/bin/bash
set -e

TMP_RUN="./tmp_download"
PKG_OUT="./ib/packages"

mkdir -p "${TMP_RUN}"
mkdir -p "${PKG_OUT}"

# 下载 24.10 x86_64 OpenClash run包
RUN_URL="https://github.com/AUK9527/Are-u-ok/releases/download/OpenClash/OpenClash_0.47.110+x86_64_core.run"
RUN_FILE="${TMP_RUN}/openclash.run"

echo "Download OpenClash run ..."
wget -qO "${RUN_FILE}" "${RUN_URL}"

echo "Extract run package ..."
"${RUN_FILE}" --target ./tmp_run_out --noexec
cp ./tmp_run_out/*.ipk "${PKG_OUT}/"

#清理全部临时文件
rm -rf "${TMP_RUN}" ./tmp_run_out
echo "Extract done."
