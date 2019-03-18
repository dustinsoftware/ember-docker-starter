param(
  # Speed improvement: Don't bring containers down first
  [switch] $skip_recreate,
  # Skip Windows containers warning
  [switch] $skip_windows_warning,
  # Skip container and image pruning
  [switch] $skip_prune,
  # Sanity check the current container
  [switch] $sanity_check
)
$ErrorActionPreference = "Stop"

function InvokeAndCheckExit {
  param([string] $command)

  $output = Invoke-Expression $command

  if (!($LastExitCode -eq 0)) {
    Write-Output $output
    throw "Command did not run successfully."
  }

  return $output
}

function VerifyDirectory {
  param([string] $path)

  if (!(Test-Path $path)) {
    throw "$path was not found. Please clone it and try this script again."
  }
}

if (Test-Path "$PSScriptRoot\dist") {
  Throw "The dist folder must not be present! Please delete it manually before continuing."
}

Write-Output "Checking Dotnet Tools (requires at least .NET Core 2.1.300)"
$toolslist = InvokeAndCheckExit "dotnet tool list -g"
if (!($toolslist -match "dockervolumewatcher")) {
  Write-Output "Installing https://www.nuget.org/packages/DockerVolumeWatcher/"
  InvokeAndCheckExit "dotnet tool install --global DockerVolumeWatcher --version 1.0.3"
}

if (!(Get-Process "dotnet-docker-volume-watcher" -ErrorAction SilentlyContinue)) {
  Write-Output "Starting dockervolumewatcher (minimized)"
  Start-Process -WindowStyle Minimized dotnet-docker-volume-watcher
}

Write-Output "Checking Docker version."

$dockerversion = InvokeAndCheckExit "docker version"
if (!($dockerversion -match "linux/amd64") -and $skip_windows_warning -eq $false) {
  Write-Output "Warning: Docker appears to be running in Windows containers mode, which may be slow."
  Write-Output "To bypass this warning, pass -skip_windows_warning as an argument."
  exit
}

$prune_warning_path = Join-Path $env:TEMP 'ember-docker-warning.tmp'
if ($skip_prune -eq $false) {
  if ((Test-Path $prune_warning_path) -eq $false) {
    Write-Output "To free up space, this script prunes stopped Docker containers and unused images. If you don't want this, pass -skip_prune as an argument."

    $reply = Read-Host -Prompt "Type 'confirm' to acknowledge this warning and proceed"
    if (-not ($reply -match "confirm" )) {
      exit
    }

    Add-Content -Path $prune_warning_path -Value "ember-docker-warning"
  }

  Write-Output "Pruning unused images to free up space."
  InvokeAndCheckExit "docker image prune -f --filter ""until=24h"""

  Write-Output "Pruning unused containers to free up space."
  InvokeAndCheckExit "docker container prune -f --filter ""until=24h"""
}

if ($sanity_check -eq $false) {
  Write-Output "Starting containers. This may take a while."
  InvokeAndCheckExit "docker-compose up --build -d"
}

Write-Output "Verifying Ember Serve is running"
InvokeAndCheckExit "Test-NetConnection -ComputerName localhost -Port 4200"

Write-Output "Containers are running. Please see the README for docs on how to view build output or run commands."
