#!/bin/sh

BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"

# 清理旧的目录
rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"

# 解压 .run 文件
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
    echo "🧩 解压 $run_file -> $TEMP_DIR"
    sh "$run_file" --target "$TEMP_DIR" --noexec
done

# 1. 收集 run 解压出的 .ipk 文件
find "$TEMP_DIR" -type f -name "*.ipk" -exec cp -v {} "$TARGET_DIR"/ \;

# 2. 收集 extra-packages/*/ 下的 .ipk 文件（只查一级子目录）

find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.ipk" ! -path "$TEMP_DIR/*" \
  -exec echo "👉 Found:" {} \; \
  -exec cp -v {} "$TARGET_DIR"/ \;

echo "✅ 所有 .ipk 文件已整理至 $TARGET_DIR/"

# 下载OpenClash run包，ghproxy镜像优先，失败则跳过不中断编译
BASE_DIR="extra-packages"
OC_RUN="${BASE_DIR}/openclash.run"
mkdir -p "${BASE_DIR}"

# ghproxy镜像源
wget --timeout=30 -q -O "${OC_RUN}" "https://mirror.ghproxy.com/https://github.com/wkccd/CloudRunFilesBuilder/releases/latest/download/openclash-x86_64.run"

# 镜像下载失败，回退原始github
if [ ! -s "${OC_RUN}" ]; then
    echo "ghproxy源下载失败，尝试GitHub原始源"
    wget --timeout=30 -q -O "${OC_RUN}" "https://github.com/wkccd/CloudRunFilesBuilder/releases/latest/download/openclash-x86_64.run"
fi

# 文件有效才解压；不存在/0字节直接跳过，继续编译
if [ -s "${OC_RUN}" ]; then
    echo "✅ OpenClash.run下载成功，开始解压"
    sh "${OC_RUN}" --target "${TEMP_DIR}" --noexec
else
    echo "⚠️ OpenClash.run下载全部失败，跳过OpenClash插件，固件继续构建"
    rm -f "${OC_RUN}"
fi
