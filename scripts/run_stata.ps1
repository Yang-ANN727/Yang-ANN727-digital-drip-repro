# scripts/run_stata.ps1  (robust)
param()
$ErrorActionPreference = 'Stop'

# 1. 获取 STATA_CMD（来自 secret）
$stataCmd = $env:STATA_CMD

# 2. 尝试自动寻找常见安装路径（仅在 secret 未设置时）
if (-not $stataCmd -or $stataCmd -eq '') {
  Write-Host "STATA_CMD not set; trying common default paths..."
  $candidates = @(
    "C:\Program Files\Stata17\StataSE.exe",
    "C:\Program Files\Stata17\StataMP-64.exe",
    "C:\Program Files\Stata17\Stata.exe"
  )
  foreach ($p in $candidates) {
    if (Test-Path $p) { $stataCmd = $p; break }
  }
}

if (-not $stataCmd -or $stataCmd -eq '') {
  Write-Error "STATA_CMD not set and no default found. Set repository secret STATA_CMD to full path of Stata executable."
  exit 1
}

Write-Host "Using Stata command (local check): $stataCmd"

# 3. Ensure the path exists and is executable
if (-not (Test-Path $stataCmd)) {
  Write-Error "STATA_CMD path not found: $stataCmd"
  exit 1
}

# 4. Build do-file path relative to repo root (current dir in Actions is repo root)
$doFile = Join-Path (Get-Location) 'scripts\model.do'
if (-not (Test-Path $doFile)) {
  Write-Error "do-file not found: $doFile"
  exit 1
}

# 5. Run Stata and capture exit code, printing stdout/stderr
Write-Host "Running: & `"$stataCmd`" -b do `"$doFile`""
& "$stataCmd" -b do "$doFile"
$code = $LASTEXITCODE
if ($code -ne 0) {
  Write-Error "Stata exited with code $code"
  exit $code
}
Write-Host "Stata finished successfully (exit code 0)."
