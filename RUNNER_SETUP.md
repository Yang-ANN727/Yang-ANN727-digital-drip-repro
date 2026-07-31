Self-hosted runner 与 Stata 部署说明

下面说明如何准备并注册一台自托管 runner（在你拥有 Stata 许可的机器/VM 上），以便 GitHub Actions 能在该机器上运行原生 Stata .do 文件。

前提要求
- 你有一台 Linux（或 Windows/macOS）机器，能访问互联网，并且允许安装并运行 GitHub runner。
- 已在该机器上合法安装并激活 Stata（确保能通过命令行调用，例如 /usr/local/stata/stata 或 stata-se/stata-mp）。
- 你是仓库 Yang-ANN727/Yang-ANN727-digital-drip-repro 的管理员，能够在仓库 Settings 中创建 runner token 与配置 Secrets。

步骤 1 — 在 GitHub 上为仓库生成 runner token
1. 打开仓库页面：https://github.com/Yang-ANN727/Yang-ANN727-digital-drip-repro
2. Settings -> Actions -> Runners -> Add runner
3. 选择操作系统（Linux/Windows/macOS），复制提供的下载、解压、注册（config）命令和 token。
4. 在注册时为 runner 添加标签，例如："self-hosted", "linux", "stata"（Workflow 中使用这些标签）。

步骤 2 — 在 runner 机器上安装并配置 runner
示例（Linux）:

# 在 runner 机器上：
mkdir actions-runner && cd actions-runner
# 把下面的 URL 替换为 GitHub 在 "Add runner" 页面给你的下载链接
# 示例下载、解压（以 x64 Linux 为例）：
curl -O -L https://github.com/actions/runner/releases/download/v2.x.x/actions-runner-linux-x64-2.x.x.tar.gz
tar xzf ./actions-runner-linux-x64-2.x.x.tar.gz

# 然后执行 config.sh（使用你从 GitHub 获取的 URL 和 TOKEN）
./config.sh --url https://github.com/Yang-ANN727/Yang-ANN727-digital-drip-repro --token YOUR_TOKEN --labels linux,stata,self-hosted

# 以服务方式安装并启动 runner（可选，但建议用于长期运行）
sudo ./svc.sh install
sudo ./svc.sh start

注意：保持 runner 目录和服务运行，检查 runner 状态页面确认已连线并处于 Idle 状态。

步骤 3 — 在 runner 上安装 Stata 并测试
- 按 Stata 的安装说明在机器上安装并激活 Stata（请使用合法许可证）。
- 确认命令行可运行，例如：
/usr/local/stata/stata -h
或
stata -h

如果 Stata 在非标准路径，请把可执行路径作为仓库 Secret STATA_CMD 保存，或把可执行路径加入 runner 的 PATH（例如在 /etc/profile.d/ 中设置）。

步骤 4 — 在仓库设置 Secrets（用于在 workflow 中传递敏感信息）
- 打开仓库 -> Settings -> Secrets and variables -> Actions -> New repository secret
- 常见名字：DB_HOST, DB_USER, DB_PASS, STATA_CMD
- secrets 会在 workflow 中通过 ${{ secrets.NAME }} 读取。不要在 repo 中硬编码敏感信息。

步骤 5 — 数据放置与安全
- 最简单的方式：把用于训练/评分的小样本数据（非敏感）放到仓库的 data/ 目录（例如 data/train.dta）。
- 生产数据通常不要放到仓库：请在 runner 上通过安全方式（内部网络/私有对象存储/数据库）拉取数据。可以在 workflow 中通过脚本连接 DB（使用 secrets）在运行前把数据下载到 runner 的工作区。

步骤 6 — 测试 workflow
1. 在仓库中 push 一次到 main（或手动触发 workflow_dispatch）。
2. 在 Actions 页面查看 run-stata workflow 是否触发，并监控自托管 runner 上的日志。
3. 成功时，artifact 将包含 output/predictions.csv，且 Actions 会显示 job 成功或失败。

安全性与权限建议
- 仅在受信任的 runner 上运行包含敏感凭证或写回生产数据库的 workflow。
- 如果多个仓库共用 runner，请配置合适的访问控制并限制对该 runner 的可见性。
- 给 workflow 最小必要权限：如果只需要上传 artifact，则不必给 workflow 更高权限去修改仓库设置或 secrets。

