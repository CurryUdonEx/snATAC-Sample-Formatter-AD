#!/bin/bash
cd split_samples
for f in *.fragments.tsv; do
    echo "正在处理样本: $f"
    sort -k1,1 -k2,2n $f > ${f}.sorted
    bgzip -c ${f}.sorted > ${f}.gz
    tabix -p bed ${f}.gz
    rm $f ${f}.sorted
done
echo "所有样本处理完毕！"
