@echo off
if not exist "digital-drip-repro" git clone https://github.com/Yang-ANN727/digital-drip-repro.git
pushd digital-drip-repro
for %%D in (data do output docs) do if not exist "%%D" mkdir "%%D"
