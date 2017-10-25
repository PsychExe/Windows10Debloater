#This utility removes all of the Windows 10 bloatware that is preinstalled. Use the # to comment
#out a bloatware app that you would like to keep.

#This function finds any AppX/AppXProvisioned package and uninstalls it, except for Freshpaint, Windows Calculator, Windows Store, and Windows Photos.
#Also, to note - This does NOT remove essential system services/software/etc such as .NET framework installations, Cortana, Edge, etc.
Function Start-Debloat {

    Get-AppxPackage -AllUsers |
        where-object {$_.name -notlike "*Microsoft.FreshPaint*"} |
        where-object {$_.name -notlike "*Microsoft.WindowsCalculator*"} |
        where-object {$_.name -notlike "*Microsoft.WindowsStore*"} |
        where-object {$_.name -notlike "*Microsoft.Windows.Photos*"} |
        Remove-AppxPackage -ErrorAction SilentlyContinue -Verbose


    Get-AppxProvisionedPackage -online |
        where-object {$_.packagename -notlike "*Microsoft.FreshPaint*"} |
        where-object {$_.packagename -notlike "*Microsoft.WindowsCalculator*"} |
        where-object {$_.name -notlike "*Microsoft.WindowsStore*"} |
        where-object {$_.name -notlike "*Microsoft.Windows.Photos*"} |
        Remove-AppxProvisionedPackage -online -ErrorAction SilentlyContinue -Verbose    
}
Function Remove-Keys {

    #These are the registry keys that it will delete.

    #Creates a "drive" to access the HKCR (HKEY_CLASSES_ROOT)
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
    
    $Keys = @(
    
        #Remove Background Tasks
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    
        #Windows File
        "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    
        #Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    
        #Scheduled Tasks to delete
        "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
    
        #Windows Protocol Keys
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
       
        #Windows Share Target
        "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    )
    
    ForEach ($Key in $Keys) {
        Write-Output "Removing $Key from registry"
        Remove-Item $Key -Recurse -ErrorAction SilentlyContinue
    }
}
    
Function Protect-Privacy {

    #Creates a "drive" to access the HKCR (HKEY_CLASSES_ROOT)
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
    Sleep 2
    
    #Disables Windows Feedback Experience
    If (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo') {
        $Advertising = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
        Set-ItemProperty $Advertising -Name Enabled -Value 0 -Verbose
    }
    
    #Stops Cortana from being used as part of your Windows Search Function
    If ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search') {
        $Search = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
        Set-ItemProperty $Search -Name AllowCortana -Value 0 -Verbose
    }
    
    #Stops the Windows Feedback Experience from sending anonymous data
    If (!('HKCU:\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds')) { 
        $Period = 'HKCU:\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds'
        New-Item $Period
        Set-ItemProperty -Name PeriodInNanoSeconds -Value 0 -Verbose
    }
           
    Write-Output "Adding Registry key to prevent bloatware apps from returning"
           
    #Prevents bloatware applications from returning
    If ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content\') {
        $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content"
        Mkdir $registryPath
        New-ItemProperty $registryPath -Name DisableWindowsConsumerFeatures -Value 1 -Verbose
    }
           
    Sleep 1
           
    Write-Output "Stopping Edge from taking over as the default .PDF viewer"
           
    #Stops edge from taking over as the default .PDF viewer
    If ('HKCR:\.pdf') {
        #This is the .pdf file association string
        $PDF = 'HKCR:\.pdf'
        New-ItemProperty $PDF -Name NoOpenWith -Verbose
        New-ItemProperty $PDF -Name NoStaticDefaultVerb -Verbose
    }
           
    Sleep 1
           
    If ('HKCR:\.pdf\OpenWithProgids') {
        #This is the .pdf file association string
        $Progids = 'HKCR:\.pdf\OpenWithProgids'
        New-ItemProperty $Progids -Name NoOpenWith -Verbose
        New-ItemProperty $Progids -Name NoStaticDefaultVerb -Verbose
    }

    If ('HKCR:\.pdf\OpenWithList') {
        $List = 'HKCR:\.pdf\OpenWithList'
        New-ItemProperty $List -Name NoOpenWith -Verbose
        New-ItemProperty $List -Name NoOpenWith -Verbose
    }

    #Appends an underscore '_' to the Registry key for Edge
    If ('HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723') {
        $Edge = 'HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723'
        Set-Item $Edge AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_ -Verbose
    }


    Write-Output "Disabling Mixed Reality Portal"
    If ('HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic') {
        $Holo = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic'
        Set-ItemProperty $Holo -Name FirstRunSucceeded -Value 0 -Verbose
    }
}
Function Revert-Changes {        

    #This function will revert the changes you made when running the Start-Debloat function.

    #This line reinstalls all of the bloatware that was removed
    Get-AppxPackage -AllUsers | ForEach {Add-AppxPackage -Verbose -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} -ErrorAction SilentlyContinue

    #Stops Cortana from being used as part of your Windows Search Function
    If ('HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search') {
        #Disables Cortana
        $Search = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
        Set-ItemProperty $Search -Name AllowCortana -Value 1 -Verbose
    }
       
    Write-Output "Adding Registry key to prevent bloatware apps from returning"
       
    #Prevents bloatware applications from returning
    If ("HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content\") {
        $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Cloud Content"
        Mkdir $registryPath
        New-ItemProperty $registryPath -Name DisableWindowsConsumerFeatures -Value 1 -Verbose
    }
       
    Sleep 1
       
    Write-Output "Stopping Edge from taking over as the default .PDF viewer"
       
    If (!(Get-ItemProperty 'HKCR:\.pdf' -Name NoOpenWith)) {
        #This is the .pdf file association string
        $PDF = 'HKCR:\.pdf'
        New-ItemProperty $PDF -Name NoOpenWith -Verbose
        New-ItemProperty $PDF -Name NoStaticDefaultVerb -Verbose
    }
    else {
        Break
    }
       
    Sleep 1
       
    If (!(Get-ItemProperty 'HKCR:\.pdf\OpenWithProgids' -Name NoOpenWith)) {
        #This is the .pdf file association string
        $Progids = 'HKCR:\.pdf\OpenWithProgids'
        New-ItemProperty $Progids -Name NoOpenWith -Verbose
        New-ItemProperty $Progids -Name NoStaticDefaultVerb -Verbose
    }
    else {
        Break
    }

    #Tells Windows to enable your advertising information.
    If ('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo') {
        $Advertising = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
        Set-ItemProperty $Advertising -Name Enabled -Value 1 -Verbose
    }
}
    
#Switch statement containing Yes/No options
#This will ask you if you want to enable System Restore functionality and will enable it if you choose yes
Write-Output "Do you want to enable System Restore Functionality? (!RECOMMENDED!)" 
$Readhost = Read-Host " ( Yes / No ) " 
Switch ($ReadHost) { 
    Yes {
        Write-Output "Enabling System Restore Functionality" ; $PublishSettings = $true
        Enable-ComputerRestore -Drive "C:\"
    } 
    No {$PublishSettings = $false} 
}
    
#Switch statement containing Yes/No options
#It also allows you to create a system restore check point
Write-Output "Do you want to create a System Restore Checkpoint? (!RECOMMENDED!)" 
$Readhost = Read-Host " ( Yes / No ) " 
Switch ($ReadHost) { 
    Yes {
        Write-Output "Creating a system restore checkpoint...." ; $PublishSettings = $true
        Checkpoint-Computer -Description "Windows 10 Debloat" -RestorePointType "APPLICATION_UNINSTALL"
    } 
    No {$PublishSettings = $false} 
}
    
#Switch statement containing Yes/No options
Write-Output "Do you want to continue this script?"
$ReadHost = Read-Host " ( Yes / No ) "
Switch ($ReadHost) {
    Yes {Write-Output "Continuing..."; $PublishSettings = $true}
    No {
        Write-Output "Exiting script."; $PublishSettings = $false
        Sleep 1
        Exit
    }
}
    
#Switch statement containing Debloat/Revert options
Write-Output "The following options will allow you to either Debloat Windows 10, or to revert changes made after Debloating Windows 10.
    Choose 'Debloat' to Debloat Windows 10 or choose 'Revert' to revert changes." 
$Readhost = Read-Host " ( Debloat / Revert ) " 
Switch ($ReadHost) {
    #This will debloat Windows 10
    Debloat {
        Write-Output "Starting Debloat. Uninstalling bloatware and removing the registry keys."; $PublishSettings = $true
        Start-Debloat
        Remove-Keys
    }
    Revert {
        Write-Output "Reverting changes..."; $PublishSettings = $false
        Revert-Changes
    }
}
    
#Switch statement containing Yes/No options
Write-Output "Do you want to change some privacy settings? This will disable Cortana from acting within your Search, and disable feedback to Microsoft, as well as stop 
Edge from being the default PDF viewer."
$Readhost = Read-Host " ( Yes / No ) "
Switch ($ReadHost) {
    Yes {
        Write-Output "Disabling Cortana from being active within Windows Search, disabling Feedback to Microsoft, and stopping Edge from taking over as the PDF viewer."; $PublishSettings = $true
        Protect-Privacy
    }
    No {$PublishSettings = $false}
}

Write-Output "Script has finished. Exiting."
Sleep 2
Exit
