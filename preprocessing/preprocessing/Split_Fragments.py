import gzip
import pandas as pd
import os

# --- 配置参数 ---
metadata_file = "snATAC_metadta.csv" 
fragments_in = "fragments.tsv.gz"
output_dir = "split_samples"

def main():
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"创建目录: {output_dir}")

    print("正在读取 Metadata 并建立索引...")
    df_meta = pd.read_csv(metadata_file, index_col=0)
    barcode_map = df_meta['Sample.ID'].to_dict()
    unique_samples = df_meta['Sample.ID'].unique()
    print(f"识别到 {len(unique_samples)} 个样本。")

    handles = {}
    try:
        for sample in unique_samples:
            out_path = os.path.join(output_dir, f"{sample}.fragments.tsv")
            handles[sample] = open(out_path, 'w')

        print("开始拆分 Fragment 文件，请耐心等待...")
        count = 0
        with gzip.open(fragments_in, 'rt') as f_in:
            for line in f_in:
                if line.startswith('#'): continue
                cols = line.strip().split('\t')
                if len(cols) < 4: continue
                barcode = cols[3]
                if barcode in barcode_map:
                    sample_name = barcode_map[barcode]
                    handles[sample_name].write(line)
                count += 1
                if count % 10000000 == 0:
                    print(f"已处理 {count // 1000000} 百万行...")
    finally:
        print("正在关闭所有文件句柄...")
        for h in handles.values():
            h.close()
    print("拆分完成！")

if __name__ == "__main__":
    main()
