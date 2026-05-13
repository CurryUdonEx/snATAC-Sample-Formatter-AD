
#!/bin/bash

for snap_file in *.snap; do
    sample_name="${snap_file%.snap}"
    echo "正在处理样本: ${sample_name} ..."

    # 1. 提取 fragment
    snaptools dump-fragment --snap-file "${snap_file}" --output-file "${sample_name}_temp.bed"
    
    if [ ! -s "${sample_name}_temp.bed" ]; then
        echo "警告：${sample_name}_temp.bed 是空的，跳过！"
        rm -f "${sample_name}_temp.bed"
        continue
    fi

    # 2. 格式化：去除多余的 b前缀，并排序压缩
    echo "  正在清洗数据并压缩..."
    awk -v OFS="\t" '{
        # 去除 b 这种格式里的多余符号 (此处代码里用 \047 代表单引号，安全无报错)
        gsub(/^b\047|\047$/, "", $1);
        # 去除 cell barcode 里的多余符号
        gsub(/^b\047|\047$/, "", $4);
        
        # 补全 chr 前缀
        if($1 !~ /^chr/) {
            if($1 == "MT") $1="chrM"; else $1="chr"$1;
        }
        
        print $1, $2, $3, $4, 1
    }' "${sample_name}_temp.bed" | \
    sort -k1,1 -k2,2n | \
    bgzip -c > "${sample_name}.fragments.tsv.gz"
    
    # 3. 构建索引
    echo "  正在构建 tabix 索引..."
    tabix -p bed "${sample_name}.fragments.tsv.gz"
    
    # 4. 删除临时文件
    rm "${sample_name}_temp.bed"
    
    echo "样本 ${sample_name} 处理完成！"
done

echo "所有转换任务已完成！请重新尝试在 ArchR 中生成 Arrow 文件。"
