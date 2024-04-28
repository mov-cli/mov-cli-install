$IS_EXECUTED_FROM_IEX = ($null -eq $MyInvocation.MyCommand.Path)

function Test-CommandAvailable {
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [String] $Command
    )
    return [Boolean](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Write-InstallInfo {
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String] $String,
        [Parameter(Mandatory = $False, Position = 1)]
        [System.ConsoleColor] $ForegroundColor = $host.UI.RawUI.ForegroundColor
    )

    $backup = $host.UI.RawUI.ForegroundColor

    if ($ForegroundColor -ne $host.UI.RawUI.ForegroundColor) {
        $host.UI.RawUI.ForegroundColor = $ForegroundColor
    }

    Write-Output "$String `n"

    $host.UI.RawUI.ForegroundColor = $backup
}

function Deny-Install {
    param(
        [String] $message,
        [Int] $errorCode = 1
    )

    Write-InstallInfo -String $message -ForegroundColor Red
    Write-InstallInfo 'Abort.'

    # Don't abort if invoked with iex that would close the PS session
    if ($IS_EXECUTED_FROM_IEX) {
        break
    } else {
        exit $errorCode
    }
}


if (Test-CommandAvailable("mov-cli")) {
    Deny-Install "mov-cli is already installed"
}

if (-Not (Test-CommandAvailable("scoop"))) {
    Write-InstallInfo "Installing scoop..."
    Invoke-RestMethod -Uri "get.scoop.sh" | Invoke-Expression
}

if (-Not (Test-CommandAvailable("python"))) {
    Write-InstallInfo "Installing python with scoop..."
    scoop install python
}


if (-Not (Test-CommandAvailable("mpv"))) {
    Write-InstallInfo "Installing mpv with scoop..."

    if (-Not (Test-CommandAvailable("git"))) {
        Write-InstallInfo "Installing git with scoop..."
        scoop install git
    }

    scoop bucket add extras
    scoop install mpv
}

if (-Not (Test-CommandAvailable("fzf"))) {
    Write-InstallInfo "Installing fzf with scoop..."

    scoop install fzf
}

pip install mov-cli

Write-InstallInfo "`nmov-cli installed. >.<"

$Test = Read-Host -Prompt "Test it? (y/n): "

if ($Test.ToLower() -eq "y") {
    mov-cli -s test abc
}