/********************************************************************
  本程序用于复现论文《共享数字红利：同行业企业间的数字技术涓滴效应》的结果。

  使用软件及版本：
  - Stata 17.0
********************************************************************/
clear all
set more off

* 保证在 GitHub Actions checkout 后的仓库根目录运行
cd "`c(pwd)'"

capture log close
log using "run.log", replace text

use "data.dta", clear

*调用数据*
use 数据.dta, clear

xtset id year
global control "size listage roa ato cashflow growth board indep mfee"
global controlH "Hsize Hlistage Hroa Hato Hcashflow Hgrowth Hindep Hmfee"
global controlM "Msize Mlistage Mroa Mato Mcashflow Mgrowth Mindep Mmfee"
**********************描述性统计******************************
*（描述性统计）附录表2*
preserve
bysort year ind: keep if _n == 1
sum2docx HDig MDig using Table1_Des1.docx, replace stats(N mean(%10.4f)  sd(%10.4f) min(%10.4f)  max(%10.4f))
restore
sum2docx IDig HLea HGra HPen HExp HSim HCGap HEGap $control using Table1_Des2.docx if ishigh ==., replace stats(N mean(%10.4f)  sd(%10.4f) min(%10.4f)  max(%10.4f))  
sum2docx MLea MGra MPen MExp MSim MCGap MEGap using Table1_Des3.docx if islow == 1, replace stats(N mean(%10.4f)  sd(%10.4f) min(%10.4f)  max(%10.4f))  
********************涓滴效应检验******************************
*基准回归结果（正文表1）*
reghdfe IDig HDig $control if ishigh ==. ,absorb(id year) vce(cluster indy)
est store m1
reghdfe IDig HDig $control if ismid == 1 ,absorb(id year) vce(cluster indy)
est store m2
reghdfe IDig MDig $control if islow == 1 ,absorb(id year) vce(cluster indy)
est store m3
reghdfe IDig HDig HDigMid $control if ishigh ==. ,absorb(id year) vce(cluster indy)
est store m4
reghdfe IDig HDig MDig $control if islow == 1 ,absorb(id year) vce(cluster indy)
est store m5
esttab m1 m2 m3 m4 m5, mtitle("高→中低" "高→中" "中→低" "高→中低" "高中→低") keep(HDig MDig HDigMid) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
**********************稳健性检验******************************
*工具变量法（附录表3）*
reghdfe HDig IVHDig $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe HDig IVHDig $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe MDig IVMDig $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
ivreghdfe IDig $control (HDig = IVHDig) if ishigh ==. ,absorb(id year) vce(cluster indy) first 
est store m4
ivreghdfe IDig $control (HDig = IVHDig) if ismid == 1 ,absorb(id year) vce(cluster indy) first 
est store m5
ivreghdfe IDig $control (MDig = IVMDig) if islow == 1 ,absorb(id year) vce(cluster indy) first 
est store m6
esttab m1 m2 m3 m4 m5 m6, mtitle("高→中低" "高→中" "中→低" "高→中低" "高→中" "中→低") keep(IVHDig IVMDig HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*倾向得分匹配（附录表4）*
set seed 10101
gen ranorder=runiform()
sort ranorder
psmatch2 D $control if ishigh ==. , outcome (IDig) logit radius caliper(0.003) ties ate  common
pstest  $control ,both
reghdfe IDig HDig $control if (_weight !=.) & (ishigh ==.) ,absorb(id year) vce(cluster indy) 
est store m1
psmatch2 D $control if ismid == 1 , outcome (IDig) logit radius caliper(0.003) ties ate  common
pstest  $control , both
reghdfe IDig HDig $control if (_weight !=.) & (ismid == 1) ,absorb(id year) vce(cluster indy) 
est store m2
psmatch2 D $control if islow == 1 , outcome (IDig) logit radius caliper(0.003) ties ate  common
pstest  $control ,  both
reghdfe IDig MDig $control if (_weight !=.) & (islow == 1) ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*替换被解释变量（附录表5）*
reghdfe IDigP HDig $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDigP HDig $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDigP MDig $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*增加优势企业控制变量平均值（附录表5）*
reghdfe IDig HDig $control $controlH if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control $controlH if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig $control $controlM if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*增加控制行业固定效应（附录表6）* 
reghdfe IDig HDig $control if ishigh ==. ,absorb(id ind year) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control if ismid == 1 ,absorb(id ind year) vce(cluster indy) 
est store m2
reghdfe IDig MDig $control if islow == 1 ,absorb(id ind year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*增加控制城市固定效应（附录表6）*
reghdfe IDig HDig $control if ishigh ==. ,absorb(id ind year city) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control if ismid == 1 ,absorb(id ind year city) vce(cluster indy) 
est store m2
reghdfe IDig MDig $control if islow == 1 ,absorb(id ind year city) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*剔除金融市场波动与公共卫生事件年份样本（附录表7）*
reghdfe IDig HDig $control if ishigh ==. & (year != 2015 & year < 2020) ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control if ismid == 1 & (year != 2015 & year < 2020) ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig $control if islow == 1 & (year != 2015 & year < 2020) ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*调整企业划分标准（附录表7）*
reghdfe IDig HDig1 $control if ishigh1 ==. ,absorb(id year) vce(cluster indy)  
est store m1
reghdfe IDig HDig1 $control if ismid1 == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig1 $control if islow1 == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDig1 MDig1) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
**********************机制检验******************************
*机制（1）：示范引领机制（正文表2）*
reghdfe HLea HDig $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe HLea HDig $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe MLea MDig $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
reghdfe HGra HDig $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m4
reghdfe HGra HDig $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m5
reghdfe MGra MDig $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m6
esttab m1 m2 m3 m4 m5 m6,mtitle("高→中低" "高→中" "中→低" "高→中低" "高→中" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*机制（2）：资源渗透机制（正文表3）*
reghdfe HPen HDig $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe HPen HDig $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe MPen MDig $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*机制（3）：空间拓展机制（正文表3）*
reghdfe HExp HDig $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe HExp HDig $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe MExp MDig $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
**********************进一步分析******************************
*技术基础相似（正文表4）* 
reghdfe IDig HDig HSim HDigHSim $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig HSim HDigHSim $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig MSim MDigMsim $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDigHSim MDigMsim) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*整合能力差异（正文表4）*
reghdfe IDig HDig HCGap HDigHCGap $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig HCGap HDigHCGap $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig MCGap MDigMCGap $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDigHCGap MDigMCGap) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*成长环境差异（正文表4）*
reghdfe IDig HDig HEGap HDigHEGap $control if ishigh ==. ,absorb(id year) vce(cluster indy)  
est store m1
reghdfe IDig HDig HEGap HDigHEGap $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig MEGap MDigMEGap $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("高→中低" "高→中" "中→低") keep(HDigHEGap MDigMEGap) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*优势企业数字技术涓滴效应特征分析（正文表5）*
reghdfe IDig Hmanufac Hservice Happlica Helement $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig Mmanufac Mservice Mapplica Melement $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m2
esttab m1 m2,mtitle("高→中" "中→低") keep(Hmanufac Hservice Happlica Helement Mmanufac Mservice Mapplica Melement) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*优势企业属地经济增长条件异质性分析（附录表8）*
reghdfe IDig HDig $control if ishigh ==. & HEco == 1, absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control if ishigh ==. & HEco == 0, absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig HDig $control if ismid ==1 & HEco == 1, absorb(id year) vce(cluster indy) 
est store m3
reghdfe IDig HDig $control if ismid ==1 & HEco == 0, absorb(id year) vce(cluster indy) 
est store m4
reghdfe IDig MDig $control if islow ==1 & MEco == 1, absorb(id year) vce(cluster indy) 
est store m5
reghdfe IDig MDig $control if islow ==1 & MEco == 0, absorb(id year) vce(cluster indy) 
est store m6
esttab m1 m2 m3 m4 m5 m6 ,mtitle("高→中低" "高→中低" "高→中" "高→中" "中→低" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f) 
*优势企业属地数据要素化水平异质性分析（附录表9）*
reghdfe IDig HDig $control if ishigh ==. & HEle == 1, absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control if ishigh ==. & HEle == 0, absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig HDig $control if ismid ==1 & HEle == 1, absorb(id year) vce(cluster indy) 
est store m3
reghdfe IDig HDig $control if ismid ==1 & HEle == 0, absorb(id year) vce(cluster indy) 
est store m4
reghdfe IDig MDig $control if islow ==1 & MEle == 1, absorb(id year) vce(cluster indy) 
est store m5
reghdfe IDig MDig $control if islow ==1 & MEle == 0, absorb(id year) vce(cluster indy) 
est store m6
esttab m1 m2 m3 m4 m5 m6 ,mtitle("高→中低" "高→中低" "高→中" "高→中" "中→低" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f) 
*优势企业属地数字产业集聚异质性分析（附录表10）*
reghdfe IDig HDig $control if ishigh ==. & HClu == 1, absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control if ishigh ==. & HClu == 0, absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig HDig $control if ismid ==1 & HClu == 1, absorb(id year) vce(cluster indy) 
est store m3
reghdfe IDig HDig $control if ismid ==1 & HClu == 0, absorb(id year) vce(cluster indy) 
est store m4
reghdfe IDig MDig $control if islow ==1 & MClu == 1, absorb(id year) vce(cluster indy) 
est store m5
reghdfe IDig MDig $control if islow ==1 & MClu == 0, absorb(id year) vce(cluster indy) 
est store m6
esttab m1 m2 m3 m4 m5 m6 ,mtitle("高→中低" "高→中低" "高→中" "高→中" "中→低" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f) 
*优势企业属地技术市场活跃状况异质性分析（附录表11）*
reghdfe IDig HDig $control if ishigh ==. & HMar == 1, absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control if ishigh ==. & HMar == 0, absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig HDig $control if ismid ==1 & HMar == 1, absorb(id year) vce(cluster indy) 
est store m3
reghdfe IDig HDig $control if ismid ==1 & HMar == 0, absorb(id year) vce(cluster indy) 
est store m4
reghdfe IDig MDig $control if islow ==1 & MMar == 1, absorb(id year) vce(cluster indy) 
est store m5
reghdfe IDig MDig $control if islow ==1 & MMar == 0, absorb(id year) vce(cluster indy) 
est store m6
esttab m1 m2 m3 m4 m5 m6 ,mtitle("高→中低" "高→中低" "高→中" "高→中" "中→低" "中→低") keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f) 

log close
exit, clear