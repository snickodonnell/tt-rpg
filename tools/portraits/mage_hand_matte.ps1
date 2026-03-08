param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Arguments
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\\..")
$scriptPath = Join-Path $PSScriptRoot "mage_hand_matte.py"
$venvPython = Join-Path $repoRoot ".venv-rembg\\Scripts\\python.exe"

if (Test-Path $venvPython) {
    & $venvPython $scriptPath @Arguments
} else {
    & python $scriptPath @Arguments
}

exit $LASTEXITCODE
