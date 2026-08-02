/*
Template Stata do-file: scripts/model.do
- 读取 data/train.dta（或在下面注释的 ODBC/数据库片段中替换为从数据库拉取数据）
- 拟合模型（示例为 logit），导出预测到 output/predictions.csv

注意：在自托管 runner 上确保 data/train.dta 已存在，或在此 do-file 中使用 odbc/load 导入。
*/

clear all
set more off

capture log close _stata_log
log using output/stata.log, text replace

// 检查 data/train.dta 是否存在（兼容所有 Stata 版本）
capture confirm file "data/train.dta"
if _rc == 0 {
    use "data/train.dta", clear
} else {
    di as err "data/train.dta not found. Place your Stata .dta file at data/train.dta or adapt this do-file to fetch data from DB."
    exit 1
}

// 示例模型：逻辑回归（按需替换）
logit y x1 x2 i.cat

// 生成预测概率并导出
predict phat, pr
// 如果没有 id，使用 _n 作为 id
capture confirm variable id
if _rc != 0 {
    gen id = _n
}
keep id phat
export delimited using "output/predictions.csv", replace

log close _stata_log
