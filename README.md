# Windows10Debloater
Script/Utility to debloat Windows 10

This script will remove the bloatware from Windows 10 and then delete specific registry keys that are not removed when using Rempve-AppXPackage/Remove-AppXProvisionedPackage.

It will also first ask you if you want to enable System Restore on your machine, then will create a restore checkpoint if you choose yes, ask if you want to continue to run the script, and if you choose 'Yes' you will then need to choose to either 'Debloat' or 'Revert'. Depending on your choice, either one will run specific code to either debloat your Windows 10 machine or to reinstall the bloatware and change your registry keys back to default. Finally, you will also have the choice to change some privacy settings at the end, such as disabling Cortana and stopping the Feedback Experience.

# Purpose

I have found many different solutions online to debloat Windows 10 and many either worked but caused issues in the long run, or they did so little that it wasn't enough of a "debloat" experience. I decided to create a script that will debloat Windows 10 the way that I envision it, with the option of even being able to revert changes.

This comes in hand when setting up new Windows 10 machines without needing to manually remove the bloatware found within Windows 10, along with some "fail safe" features via the Revert-Changes function, and even stops Windows from installing the bloatware in new user profiles.

# How To Run

Download the Windows10Debloater.ps1 file. Next, copy the source code from Windows10Debloater.ps1 and throw it into PowerShell ISE or launch it with PowerShell as Administrator and click run.

Alternatively, you can download the Windows10Debloater.exe file and right click it and run it as administrator. This runs the same *exact* code as in the .ps1 file.

# Concerns over verbose output

This script does NOT remove anything related to the .NET framework, or any OS dependencies. When you run it, you may see some stuff that was targeted to be removed such as .NET, but that isn't the case.

The script just whitelists specific apps to not remove, such as the Store and Calculator, along with 2 others, and removes anything else that it deems an AppxPackage/AppxProvisionedPackage.

I added -ErrorAction SilentlyContinue -Verbose at the end of each Remove-AppxPackage/Remove-AppxProvisionedPackage so that the screen does not fill up with exceptions.
