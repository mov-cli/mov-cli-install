<div align="center">

  ## mov-cli-test
  <sub>Think of it as arch-install, but for mov-cli</sub>

</div>

### How to Use:

First, ensure PowerShell execution policy allows script execution:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Now, there are two ways to install mov-cli:

- **One-Line Command:**
```powershell
iem https://raw.githubusercontent.com/mov-cli/mov-cli-install/v1/install.ps1 | irm
```

- **Manual Installation:**
Save the [install.ps1](https://raw.githubusercontent.com/mov-cli/mov-cli-install/v1/install.ps1) file, then navigate to its directory and execute:
```powershell
.\install.ps1
```

### What it does?:

This script automates the installation process for mov-cli by performing the following tasks:

- Downloads scoop package manager.
- Installs dependencies like python, fzf, git, and mpv for mov-cli.