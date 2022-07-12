# Installing the OpenSSH using Chocolatey

This is an option of installing OpenSSH on windows 10 when it is not installed by default.
Chocolatey is a software management solution unlike any you've ever experienced on Windows. It allows you to write your deployment once for any software, then deploy it with any solution everywhere you have Windows.

> Open PowerShell command prompt (or cmd.exe) as Administrator

With PowerShell, you must ensure **Get-ExecutionPolicy** is not Restricted. We suggest using **Bypass** to bypass the policy to get things installed or **AllSigned** for quite a bit more security.

```Run Get-ExecutionPolicy. If it returns Restricted, then run Set-ExecutionPolicy AllSigned or Set-ExecutionPolicy Bypass -Scope Process```

Now run the following command:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

If you don't see any errors, you are ready to use Chocolatey! 

To install OpenSSH , Run the following command: 

```choco install openssh -params ‘”/SSHServerFeature /KeyBasedAuthenticationFeature”‘ –y```

start using ssh. you may need to restart powershell.
