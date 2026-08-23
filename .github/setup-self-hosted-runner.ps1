# Run this script in an elevated PowerShell window on the Windows build machine.
[CmdletBinding()]
param(
    [string]$Repository = 'https://github.com/ntr83/simcity4-starter',
    [string]$RunnerName = $env:COMPUTERNAME,
    [string]$RunnerDirectory = 'C:\actions-runner'
)

$ErrorActionPreference = 'Stop'

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this script from an elevated PowerShell window (Run as administrator).'
}

if (-not (Test-Path -LiteralPath $RunnerDirectory)) {
    New-Item -ItemType Directory -Path $RunnerDirectory | Out-Null
}

Set-Location -LiteralPath $RunnerDirectory

$latestRelease = Invoke-RestMethod -Uri 'https://api.github.com/repos/actions/runner/releases/latest'
$asset = $latestRelease.assets |
    Where-Object { $_.name -like 'actions-runner-win-x64-*.zip' } |
    Select-Object -First 1
if ($null -eq $asset) {
    throw 'Could not find the Windows x64 GitHub Actions runner package.'
}

$runnerPackage = Join-Path $RunnerDirectory $asset.name

if (-not (Test-Path -LiteralPath (Join-Path $RunnerDirectory 'config.cmd'))) {
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $runnerPackage
    Expand-Archive -LiteralPath $runnerPackage -DestinationPath $RunnerDirectory -Force
    Remove-Item -LiteralPath $runnerPackage -Force
}

$token = Read-Host 'Paste the temporary GitHub runner registration token'
if ([string]::IsNullOrWhiteSpace($token)) {
    throw 'A runner registration token is required.'
}

$configArguments = @(
    '--url', $Repository,
    '--token', $token,
    '--name', $RunnerName,
    '--labels', 'self-hosted,Windows,purebasic',
    '--work', '_work',
    '--unattended',
    '--runasservice'
)

if (Test-Path -LiteralPath (Join-Path $RunnerDirectory '.runner')) {
    $configArguments += '--replace'
}

& (Join-Path $RunnerDirectory 'config.cmd') @configArguments

if ($LASTEXITCODE -ne 0) {
    throw "Runner registration failed with exit code $LASTEXITCODE"
}

Write-Host "Runner '$RunnerName' is installed and running for $Repository."
