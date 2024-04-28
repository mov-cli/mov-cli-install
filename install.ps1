# Test-CommandAvailable, Write-InstallInfo, Deny-Install and Test-IsAdministrator are all from: https://raw.githubusercontent.com/scoopinstaller/install/master/install.ps1

param(
    [Parameter(Mandatory = $False, Position = 0)]
    [Bool] $vlc = $False
)

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
        [String] $String
    )

    Write-Output "`n$String`n"
}

function Test-IsAdministrator {
    return ([Security.Principal.WindowsPrincipal]`
            [Security.Principal.WindowsIdentity]::GetCurrent()`
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Deny-Install {
    param(
        [String] $message,
        [Int] $errorCode = 1
    )

    Write-InstallInfo $message

    break
}

$manager = "scoop"

if (Test-CommandAvailable("scoop")) {
    $manager = "scoop"

    Write-InstallInfo "Using scoop"
}
elseif (Test-CommandAvailable("choco")) {
    $manager = "choco"

    Write-InstallInfo "Using choco"
}
else {
    Invoke-RestMethod -Uri "get.scoop.sh" | Invoke-Expression | Out-Null

    $manager = "scoop"

    Write-InstallInfo "Installed scoop"
}

function InstallDep {
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [String] $dep,
        [Parameter(Mandatory = $False, Position = 1)]
        [String] $bucket = $null
    )

    if ($bucket -and $manager -eq "scoop") {
        if (-Not (Test-CommandAvailable("git"))) {
            scoop install git

            Write-InstallInfo "Installed git for $bucket"
        }

        scoop bucket add $bucket
    }

    if ($manager -eq "scoop") {
        Invoke-Expression "$manager install $dep"
    } else {
        if (Test-IsAdministrator) {
            Invoke-Expression "$manager install $dep -y"
        }
        else {
            start-process powershell -Verb "runas" -ArgumentList "-noexit -command 'Invoke-Expression '$manager install $dep -y'"
        }
    }

    Write-InstallInfo "Installed $dep"
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
    
    if (-Not (Test-CommandAvailable("vlc")) -and $vlc -eq $true) {
        InstallDep "vlc" "extras"
    } 
    elseif (-Not (Test-CommandAvailable("mpv")) -and $vlc -eq $false) {
        InstallDep "mpv" "extras"
    }
    
    if (-Not (Test-CommandAvailable("fzf"))) {
        InstallDep "fzf"
    }    
}

Prechecks

if ($manager -eq "choco") {
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
    refreshenv
}

pip install mov-cli

Write-InstallInfo "mov-cli installed. >.<"