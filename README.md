# digital-drip-repro

复现论文《共享数字红利：同行业企业间的数字技术涓滴效应》的 Anaconda + VSCode 项目模板。

准备的内容：
- environment.yml：conda 环境文件（不锁版本）
- notebooks/starter.ipynb：starter notebook（读取、筛选、描述、回归示例，基于 statsmodels）
- src/reproduce.py：可在命令行运行的脚本版本
- .vscode/settings.json：VSCode 设置占位
- data/.gitkeep：占位，实际数据请上传到 data/ 下

快速开始（Windows，Anaconda Prompt）：
1. 创建并激活环境：
   - conda env create -f environment.yml
   - conda activate digital-drip
2. 注册 Jupyter 内核（可选）：
   - python -m ipykernel install --user --name digital-drip --display-name "digital-drip"
3. 在 VSCode 中打开本项目，安装扩展：Python、Jupyter。选择 Interpreter 为 `digital-drip` 环境。
4. 将论文使用的数据放到 `data/`（例如 data/raw_data.csv），按 README 中的字段说明配置变量名后运行 notebook 或脚本：
   - 在 VSCode 打开 `notebooks/starter.ipynb`，或运行脚本：
     - python src/reproduce.py --input data/raw_data.csv --output results/filtered_data.csv

说明：
- 我已按你要求偏向使用 statsmodels 的公式接口实现回归和聚类标准误。
- 我不会在 environment.yml 中固定包版本（使用 conda-forge 的最新兼容版本）。
- 请在把数据上传到 data/ 之前确认列名映射；如果你把数据链接发给我，我可以先下载并生成映射建议。
