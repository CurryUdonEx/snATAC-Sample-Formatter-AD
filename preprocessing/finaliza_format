#!/bin/bash
# 设置严格模式：遇到错误立即退出，未定义变量报错
set -e
set -u

echo "[INFO] 开始执行 Fragment 文件标准化与索引重建流程..."
echo "------------------------------------------------------"

# 1. 批量重命名 fragment 文件（替换由于拆分产生的多余点号 .fragments 为 _fragments）
echo "[INFO] 步骤 1: 正在格式化 .fragments.tsv.gz 文件名..."
for file in *.fragments.tsv.gz; do
    # 容错处理：如果目录下没有匹配的文件，跳过循环避免报错
    if [[ -f "$file" ]]; then
        # 利用 bash 字符串替换功能
        new_name="${file/.fragments/_fragments}"
        mv "$file" "$new_name"
        echo "  [成功] 重命名: $file  ->  $new_name"
    fi
done

# 2. 批量重命名原有的索引文件（避免残留旧格式的无效索引干扰下游分析）
echo "[INFO] 步骤 2: 正在处理残留的旧版 .tbi 索引文件..."
for file in *.fragments.tsv.gz.tbi; do
    if [[ -f "$file" ]]; then
        new_name="${file/.fragments/_fragments}"
        mv "$file" "$new_name"
    fi
done

# 3. 为重命名后的文件重新建立基于 BED 格式的 tabix 索引
echo "[INFO] 步骤 3: 开始为标准化的 fragment 文件生成空间检索索引..."
for file in *_fragments.tsv.gz; do
    if [[ -f "$file" ]]; then
        echo "  [运行] 正在为 $file 建立 tabix 索引..."
        # -p bed 参数指定按照 BED 格式（染色体、起始、终止位置）建立索引
        tabix -p bed "$file"
    fi
done

echo "------------------------------------------------------"
echo "[INFO] 全部文件格式化及空间索引建立完成！可以安全导入 ArchR。"

