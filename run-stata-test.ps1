$script = @'
$ErrorActionPreference = "Stop"

# 配置（修改为你的 .lnk 或 exe）
$lnkPath = "C:\Users\yangxu\Desktop\StataNow 19 MP.lnk"
$exeHint = "C:\Program Files\StataNow19\StataMP-64.exe"

$doFiles = @(
  "C:\Users\yangxu\actions-runner\_work\Yang-ANN727-digital-drip-repro\Yang-ANN727-digital-drip-repro\scripts\model.do",
  "C:\Users\yangxu\Yang-ANN727-digital-drip-repro\scripts\model.do"
)

function Resolve-StataExe {
  param($lnkPath, $exeHint)
  if ($exeHint -and (Test-Path $exeHint)) { Write-Host "Using exeHint: $exeHint"; return $exeHint }

  if ($lnkPath -and (Test-Path $lnkPath)) {
    try {
      $w = New-Object -ComObject WScript.Shell
      $lnk = $w.CreateShortcut($lnkPath)
      $target = $lnk.TargetPath
      Write-Host "Resolved .lnk target: $target"
      if ($target -and (Test-Path $target)) { return $target }
    } catch {
      Write-Warning "解析 .lnk 失败: $_"
    }
  }

  $candidates = @(
    "C:\Program Files\Stata19\StataMP-64.exe",
    "C:\Program Files\Stata19\StataSE-64.exe",
    "C:\Program Files\Stata18\StataSE-64.exe",
    "C:\Program Files\Stata18\StataMP-64.exe"
  )
  foreach ($c in $candidates) { if (Test-Path $c) { Write-Host "Found candidate exe: $c"; return $c } }

  return $null
}

$stataExe = Resolve-StataExe -lnkPath $lnkPath -exeHint $exeHint
if (-not $stataExe) {
  Write-Error "找不到 Stata 可执行文件。请确认已安装并把路径填到 `$exeHint`，或确保 .lnk 路径正确。"
  exit 2
}

Write-Host "Using Stata executable: $stataExe"

foreach ($do in $doFiles) {
  if (-not (Test-Path $do)) { Write-Warning "do 文件未找到，跳过： $do"; continue }

  Write-Host "`n========== Running do file: $do =========="
  $workDir = Split-Path $do -Parent
  $stdoutFile = Join-Path $workDir 'stata_stdout.txt'
  $stderrFile = Join-Path $workDir 'stata_stderr.txt'

  $exit = $null
  try {
    Write-Host "Attempting Start-Process with redirection..."
    $proc = Start-Process -FilePath $stataExe -ArgumentList ("-b","do",$do) -WorkingDirectory $workDir -NoNewWindow -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile -PassThru -Wait
    $exit = $proc.ExitCode
    Write-Host "Start-Process completed. ExitCode = $exit"
  } catch {
    Write-Warning "Start-Process failed or redirection not supported: $_. Falling back to direct invocation (&)."
    try {
      & "$stataExe" -b do "$do"
      $exit = $LASTEXITCODE
      Write-Host "Direct invocation completed. LASTEXITCODE = $exit"
    } catch {
      Write-Error "直接调用 Stata 失败: $_"
      $exit = $null
    }
  }

  Write-Host "---- RESULT for $do: ExitCode = '$exit' ----"

  if (Test-Path $stdoutFile) {
    Write-Host "---- stdout ($stdoutFile) tail ----"
    Get-Content $stdoutFile -Tail 200 | ForEach-Object { Write-Host $_ }
  }
  if (Test-Path $stderrFile) {
    Write-Host "---- stderr ($stderrFile) tail ----"
    Get-Content $stderrFile -Tail 200 | ForEach-Object { Write-Host $_ }
  }

  $logFiles = Get-ChildItem -Path $workDir -Filter *.log -Recurse -ErrorAction SilentlyContinue
  if ($logFiles) {
    foreach ($lf in $logFiles) {
      Write-Host "---- Stata log: $($lf.FullName) tail ----"
      Get-Content $lf.FullName -Tail 200 | ForEach-Object { Write-Host $_ }
    }
  } else {
    Write-Host "No .log files found under $workDir"
  }

  if ($null -eq $exit) {
    Write-Error "无法确定退出码，可能是 Stata 被 GUI 启动或调用失败。请检查上方输出。"
  } elseif ($exit -ne 0) {
    Write-Error "Stata returned non-zero exit code $exit for do file: $do"
  } else {
    Write-Host "Stata returned 0 (success) for do file: $do"
  }
}
'@

Set-Content -Path .\run-stata-test.ps1 -Value $script -Encoding UTF8
Write-Host "Wrote run-stata-test.ps1 to $(Get-Location)\run-stata-test.ps1"
