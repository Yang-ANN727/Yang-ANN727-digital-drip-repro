di as result "=== REPRODUCE DO VERSION: 2026-09-04-A ==="
/********************************************************************
  鏈▼搴忕敤浜庡鐜拌鏂囥€婂叡浜暟瀛楃孩鍒╋細鍚岃涓氫紒涓氶棿鐨勬暟瀛楁妧鏈稉婊存晥搴斻€嬬殑缁撴灉銆?

  浣跨敤杞欢鍙婄増鏈細
  - Stata 17.0
********************************************************************/
clear all
set more off

* 淇濊瘉鍦?GitHub Actions checkout 鍚庣殑浠撳簱鏍圭洰褰曡繍琛?
cd "`c(pwd)'"

capture log close
log using "run.log", replace text



*璋冪敤鏁版嵁*
capture confirm file "data.csv"
if _rc exit 601
import delimited using "data.csv", clear varn(1) encoding(UTF-8)
destring id year, replace force

xtset id year
global control "size listage roa ato cashflow growth board indep mfee"
global controlH "Hsize Hlistage Hroa Hato Hcashflow Hgrowth Hindep Hmfee"
global controlM "Msize Mlistage Mroa Mato Mcashflow Mgrowth Mindep Mmfee"
**********************鎻忚堪鎬х粺璁?*****************************
*锛堟弿杩版€х粺璁★級闄勫綍琛?*
preserve
bysort year ind: keep if _n == 1
sum2docx HDig MDig using Table1_Des1.docx, replace stats(N mean(%10.4f)  sd(%10.4f) min(%10.4f)  max(%10.4f))
restore
sum2docx IDig HLea HGra HPen HExp HSim HCGap HEGap $control using Table1_Des2.docx if ishigh ==., replace stats(N mean(%10.4f)  sd(%10.4f) min(%10.4f)  max(%10.4f))  
sum2docx MLea MGra MPen MExp MSim MCGap MEGap using Table1_Des3.docx if islow == 1, replace stats(N mean(%10.4f)  sd(%10.4f) min(%10.4f)  max(%10.4f))  
********************娑撴淮鏁堝簲妫€楠?*****************************
*鍩哄噯鍥炲綊缁撴灉锛堟鏂囪〃1锛?
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
esttab m1 m2 m3 m4 m5, mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣? "楂樷啋涓綆" "楂樹腑鈫掍綆") keep(HDig MDig HDigMid) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
**********************绋冲仴鎬ф楠?*****************************
*宸ュ叿鍙橀噺娉曪紙闄勫綍琛?锛?
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
esttab m1 m2 m3 m4 m5 m6, mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣? "楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(IVHDig IVMDig HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*鍊惧悜寰楀垎鍖归厤锛堥檮褰曡〃4锛?
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
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*鏇挎崲琚В閲婂彉閲忥紙闄勫綍琛?锛?
reghdfe IDigP HDig $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDigP HDig $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDigP MDig $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*澧炲姞浼樺娍浼佷笟鎺у埗鍙橀噺骞冲潎鍊硷紙闄勫綍琛?锛?
reghdfe IDig HDig $control $controlH if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control $controlH if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig $control $controlM if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*澧炲姞鎺у埗琛屼笟鍥哄畾鏁堝簲锛堥檮褰曡〃6锛? 
reghdfe IDig HDig $control if ishigh ==. ,absorb(id ind year) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control if ismid == 1 ,absorb(id ind year) vce(cluster indy) 
est store m2
reghdfe IDig MDig $control if islow == 1 ,absorb(id ind year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*澧炲姞鎺у埗鍩庡競鍥哄畾鏁堝簲锛堥檮褰曡〃6锛?
reghdfe IDig HDig $control if ishigh ==. ,absorb(id ind year city) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control if ismid == 1 ,absorb(id ind year city) vce(cluster indy) 
est store m2
reghdfe IDig MDig $control if islow == 1 ,absorb(id ind year city) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*鍓旈櫎閲戣瀺甯傚満娉㈠姩涓庡叕鍏卞崼鐢熶簨浠跺勾浠芥牱鏈紙闄勫綍琛?锛?
reghdfe IDig HDig $control if ishigh ==. & (year != 2015 & year < 2020) ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig $control if ismid == 1 & (year != 2015 & year < 2020) ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig $control if islow == 1 & (year != 2015 & year < 2020) ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*璋冩暣浼佷笟鍒掑垎鏍囧噯锛堥檮褰曡〃7锛?
reghdfe IDig HDig1 $control if ishigh1 ==. ,absorb(id year) vce(cluster indy)  
est store m1
reghdfe IDig HDig1 $control if ismid1 == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig1 $control if islow1 == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDig1 MDig1) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
**********************鏈哄埗妫€楠?*****************************
*鏈哄埗锛?锛夛細绀鸿寖寮曢鏈哄埗锛堟鏂囪〃2锛?
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
esttab m1 m2 m3 m4 m5 m6,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣? "楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*鏈哄埗锛?锛夛細璧勬簮娓楅€忔満鍒讹紙姝ｆ枃琛?锛?
reghdfe HPen HDig $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe HPen HDig $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe MPen MDig $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*鏈哄埗锛?锛夛細绌洪棿鎷撳睍鏈哄埗锛堟鏂囪〃3锛?
reghdfe HExp HDig $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe HExp HDig $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe MExp MDig $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
**********************杩涗竴姝ュ垎鏋?*****************************
*鎶€鏈熀纭€鐩镐技锛堟鏂囪〃4锛? 
reghdfe IDig HDig HSim HDigHSim $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig HSim HDigHSim $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig MSim MDigMsim $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDigHSim MDigMsim) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*鏁村悎鑳藉姏宸紓锛堟鏂囪〃4锛?
reghdfe IDig HDig HCGap HDigHCGap $control if ishigh ==. ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig HDig HCGap HDigHCGap $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig MCGap MDigMCGap $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDigHCGap MDigMCGap) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*鎴愰暱鐜宸紓锛堟鏂囪〃4锛?
reghdfe IDig HDig HEGap HDigHEGap $control if ishigh ==. ,absorb(id year) vce(cluster indy)  
est store m1
reghdfe IDig HDig HEGap HDigHEGap $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m2
reghdfe IDig MDig MEGap MDigMEGap $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m3
esttab m1 m2 m3,mtitle("楂樷啋涓綆" "楂樷啋涓? "涓啋浣?) keep(HDigHEGap MDigMEGap) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*浼樺娍浼佷笟鏁板瓧鎶€鏈稉婊存晥搴旂壒寰佸垎鏋愶紙姝ｆ枃琛?锛?
reghdfe IDig Hmanufac Hservice Happlica Helement $control if ismid == 1 ,absorb(id year) vce(cluster indy) 
est store m1
reghdfe IDig Mmanufac Mservice Mapplica Melement $control if islow == 1 ,absorb(id year) vce(cluster indy) 
est store m2
esttab m1 m2,mtitle("楂樷啋涓? "涓啋浣?) keep(Hmanufac Hservice Happlica Helement Mmanufac Mservice Mapplica Melement) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f)
*浼樺娍浼佷笟灞炲湴缁忔祹澧為暱鏉′欢寮傝川鎬у垎鏋愶紙闄勫綍琛?锛?
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
esttab m1 m2 m3 m4 m5 m6 ,mtitle("楂樷啋涓綆" "楂樷啋涓綆" "楂樷啋涓? "楂樷啋涓? "涓啋浣? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f) 
*浼樺娍浼佷笟灞炲湴鏁版嵁瑕佺礌鍖栨按骞冲紓璐ㄦ€у垎鏋愶紙闄勫綍琛?锛?
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
esttab m1 m2 m3 m4 m5 m6 ,mtitle("楂樷啋涓綆" "楂樷啋涓綆" "楂樷啋涓? "楂樷啋涓? "涓啋浣? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f) 
*浼樺娍浼佷笟灞炲湴鏁板瓧浜т笟闆嗚仛寮傝川鎬у垎鏋愶紙闄勫綍琛?0锛?
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
esttab m1 m2 m3 m4 m5 m6 ,mtitle("楂樷啋涓綆" "楂樷啋涓綆" "楂樷啋涓? "楂樷啋涓? "涓啋浣? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f) 
*浼樺娍浼佷笟灞炲湴鎶€鏈競鍦烘椿璺冪姸鍐靛紓璐ㄦ€у垎鏋愶紙闄勫綍琛?1锛?
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
esttab m1 m2 m3 m4 m5 m6 ,mtitle("楂樷啋涓綆" "楂樷啋涓綆" "楂樷啋涓? "楂樷啋涓? "涓啋浣? "涓啋浣?) keep(HDig MDig) se(4) star(* 0.10 ** 0.05 *** 0.01) r2(4) b(%6.4f) 

log close
exit, clear
