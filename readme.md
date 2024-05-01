<div align="center">

  ## mov-cli-install
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
irm https://raw.githubusercontent.com/mov-cli/mov-cli-install/v1/install.ps1 | iex 
```

- **Manual Installation:**
Save the [install.ps1](https://raw.githubusercontent.com/mov-cli/mov-cli-install/v1/install.ps1) file, then navigate to its directory and execute:
```powershell
.\install.ps1
```
