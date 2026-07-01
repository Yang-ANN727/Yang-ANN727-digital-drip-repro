# 复现：共享数字红利 — 同行业企业间的数字“涓滴效应"

本仓库用于复现论文/报告《共享数字红利：同行业企业间的数字涓滴效应》的实证分析。设计目标：

- 提供可运行的分析脚本（Python + R）
- 用合成数据在 CI 中做 smoke test，保证代码能自动化运行
- 明确数据获取、变量构造和识别策略说明，便于审计

快速开始：

1. 克隆仓库： git clone https://github.com/Yang-ANN727/Yang-ANN727-digital-drip-repro.git
2. 创建并激活环境（conda 或 pip）：参见 environment.yml / requirements.txt
3. 生成合成数据并运行全部分析：
   bash scripts/run_all.sh
4. 如有真实数据：把处理后面板数据放到 `data/raw/firm_panel.csv`（见 Data Spec），然后运行 `scripts/run_all.sh`

数据与隐私：

- 不把受限源数据（例如 CSMAR/WIND）提交到仓库；使用 `data/raw/` 本地挂载或私有 Git LFS。
- CI 使用合成数据；真正的分析在本地或私有 runner 上运行。

文件说明：
- data/: 合成数据生成器与示例数据
- src/: 分析脚本（数据处理、变量构造、估计与稳健性）
- scripts/: 一键运行脚本
- .github/workflows/: CI 工作流（使用合成数据运行 pipeline）

如需我把分析跑在该仓库内并提交结果，请在回复中授权。