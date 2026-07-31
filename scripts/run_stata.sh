#!/usr/bin/env bash
set -euo pipefail

# Wrapper to run Stata in batch mode on the self-hosted runner.
# Environment variables (configured in GitHub Secrets or runner env):
#  STATA_CMD - path to Stata executable (e.g. /usr/local/stata/stata)
#  (Optional) DB_HOST, DB_USER, DB_PASS - if your model.do pulls data from DB

STATA_CMD_DEFAULT="/usr/local/stata/stata"
STATA_CMD=${STATA_CMD:-$STATA_CMD_DEFAULT}

echo "Using Stata command: $STATA_CMD"

# Make sure output dir exists
mkdir -p output

# Run Stata in batch (-b) so it logs to stata.log and exits when done
# Adjust the path if your Stata installation uses a different binary name (stata, stata-se, stata-mp)
"$STATA_CMD" -b do scripts/model.do

# Exit code of stata will propagate; artifacts (output/predictions.csv) will be uploaded by the workflow
