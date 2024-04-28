# Code used from https://raw.githubusercontent.com/scoopinstaller/install/master/install.ps1

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

    Write-Output "`n$String`n"

    $host.UI.RawUI.ForegroundColor = $backup
}

function Deny-Install {
    param(
        [String] $message,
        [Int] $errorCode = 1
    )

    Write-InstallInfo -String $message -ForegroundColor Red

    if ($IS_EXECUTED_FROM_IEX) {
        break
    } else {
        exit $errorCode
    }
}

function InstallDep {
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String] $dep,
        [Parameter(Mandatory = $False, Position = 1)]
        [String] $bucket = $null
    )

    if (-Not (Test-CommandAvailable("scoop"))) {
        Write-InstallInfo "Installing scoop..."

        Invoke-RestMethod -Uri "get.scoop.sh" | Invoke-Expression
    }

    if ($bucket) {
        if (-Not (Test-CommandAvailable("git"))) {
            Write-InstallInfo "Installing git..."

            scoop install git
        }

        scoop bucket add $bucket
    }

    Write-InstallInfo "Installing $dep..."

    scoop install $dep
}


function Prechecks {
    if (Test-CommandAvailable("mov-cli")) {
        Deny-Install "mov-cli is already installed"
    }
    
    if (-Not (Test-CommandAvailable("python"))) {
        InstallDep "python"
    } else {
        $PackageFullName = (Get-AppxPackage -Name "PythonSoftwareFoundation.Python.*").PackageFullName

        if ($PackageFullName) {
            Write-InstallInfo "You got Python from the Microsoft Store. We highly recommend installing a normal installation of Python"

            $ms_python = Read-Host -Prompt "Remove ms-store python (y/n)?"

            if ($ms_python.ToLower() -eq "y") {
                Remove-AppxPackage -Package $PackageFullName

                InstallDep "python"
            }
        }
    }
    
    if (-Not (Test-CommandAvailable("mpv"))) {
        InstallDep "mpv" "extras"
    }
    
    if (-Not (Test-CommandAvailable("fzf"))) {
        InstallDep "fzf"
    }    
}

Prechecks

pip install mov-cli

Write-InstallInfo "mov-cli installed. >.<"

$Test = Read-Host -Prompt "Test it? (y/n)"

if ($Test.ToLower() -eq "y") {
    mov-cli -s test abc
}