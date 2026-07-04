"""
示例脚本: 读取 data/raw_data.csv 或 data/raw_data.xlsx，
按占位筛选规则筛样本，运行带 firm-year FE 的 OLS（statsmodels 公式）并按 firm 聚类标准误。

用法示例：
python src/reproduce.py --input data/raw_data.csv --output results/filtered_data.csv
"""
import argparse
from pathlib import Path
import pandas as pd
import statsmodels.formula.api as smf
import os

def main(input_path, output_path):
    input_path = Path(input_path)
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # 读取数据（支持 CSV 或 Excel）
    if input_path.suffix.lower() in ['.xls', '.xlsx']:
        df = pd.read_excel(input_path)
    else:
        df = pd.read_csv(input_path)

    # --- TODO: 根据你的数据列名修改下面的字段名与筛选条件 ---
    # 假设数据中包含列：firm, year, outcome, treatment, cov1, cov2, industry
    # 示例筛选：只保留 2010-2018 年且行业为 Manufacturing 或 Wholesale
    df = df.copy()
    # 示例占位筛选（请修改为你的规则或在 notebook 中交互使用）
    keep_year_min = 2010
    keep_year_max = 2018
    keep_industries = None  # e.g. ['Manufacturing', 'Wholesale'] or None

    if 'year' in df.columns:
        df = df[(df['year'] >= keep_year_min) & (df['year'] <= keep_year_max)]

    if keep_industries is not None and 'industry' in df.columns:
        df = df[df['industry'].isin(keep_industries)]

    # 丢弃关键变量缺失
    required_vars = ['outcome', 'treatment']
    for v in required_vars:
        if v in df.columns:
            df = df.dropna(subset=[v])

    # 保存筛选后的样本
    df.to_csv(output_path, index=False)
    print(f"Filtered data saved to {output_path}; {len(df)} rows remain.")

    # 运行带 firm & year 固定效应的 OLS（statsmodels 公式）
    # 请确认列名：firm, year, outcome, treatment, cov1, cov2
    # 若列名不同，请在 notebook 中手动调整 formula
    if not {'firm', 'year', 'outcome', 'treatment'}.issubset(set(df.columns)):
        print("注意：数据中缺少示例所需的列（firm/year/outcome/treatment）。请调整列名或在 notebook 中手动映射。")
        return

    formula = 'outcome ~ treatment + cov1 + cov2 + C(firm) + C(year)'
    # 若没有 cov1/cov2, 可修改 formula 到 'outcome ~ treatment + C(firm) + C(year)'

    try:
        model = smf.ols(formula=formula, data=df).fit(
            cov_type='cluster', cov_kwds={'groups': df['firm']}
        )
        print(model.summary())
        # 将回归结果保存到文本文件
        with open(output_path.parent / 'regression_summary.txt', 'w', encoding='utf-8') as f:
            f.write(model.summary().as_text())
        print(f"Regression summary saved to {output_path.parent / 'regression_summary.txt'}")
    except Exception as e:
        print("回归执行出错：", e)
        print("请在 notebook 中检查公式和变量名是否正确。")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', required=True, help='输入数据路径（CSV 或 Excel）')
    parser.add_argument('--output', required=True, help='筛选后数据输出路径（CSV）')
    args = parser.parse_args()
    main(args.input, args.output)
