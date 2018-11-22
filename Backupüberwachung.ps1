# Änderungshistorie
# 2018-07-17 ko@osthoff.net T20180710.0083 
# --- Veeam Agent Überwachung ergänzt
# --- Funktionen vereinfacht, Ausgabe am Ende zusammengefasst     
# --- es wird immer ein Fehler ausgegeben, wenn kein erfolgreiches Backup welcher Art auch immer gefunden wird


# KB-Article for fast and superior support experience!
#  - document the Job/Monitoring-Component
#  - document how to solve that Monitoring/Job-Event if some Ticket occours
$KBURL = "https://www.google.at"
$KBARTICLE = "KB-Article to deal with that ticket: " + $KBURL




if(Test-Path env:\PeriodHoursCheck) {
    Write-Host "PeriodHoursCheck Variable defined."
    Write-Host "PeriodHoursCheck = " + $Env:PeriodHoursCheck
    $PeriodHourscheck = $Env:PeriodHoursCheck
} else
{
    Write-Host "PeriodHoursCheck NOT DEFINED. Running in Debug Mode."
    $PeriodHourscheck = -100

}


$Global:result
$Global:AEM_Exit = $true

$CustomField = 1
$Backup = ""
$Backup_found = 0
$result_ok = "BACKUPS="
$result_fail = "NO-BACKUP="

#$CustomField = 1

$lastweek = (Get-Date) - (New-TimeSpan -Days 30)

$BackupWindows = Get-WinEvent -LogName "Microsoft-Windows-Backup" | where-object {($_.TimeCreated -ge $lastweek)} -ErrorAction SilentlyContinue
$BackupVeeam = Get-EventLog -LogName "Veeam Backup" -After (Get-Date).AddDays(-10) -ErrorAction SilentlyContinue
$BackupVeeamAgent = Get-EventLog -LogName "Veeam Agent" -After (Get-Date).AddDays(-10) -ErrorAction SilentlyContinue
$BackupShadowProtect = Get-EventLog -LogName Application -After (Get-Date).AddDays(-30) -Source "ShadowProtectSvc" -ErrorAction SilentlyContinue
$BackupShadowProtextSPX = Get-EventLog -LogName Application -After (Get-Date).AddDays(-30) -Source "ShadowProtectSPX" -ErrorAction SilentlyContinue
$Acronis = Get-EventLog -LogName Application -After (Get-Date).AddDays(-10) | where {($_.Source -like "Acronis*") -and ($_.ID -eq 1)} -ErrorAction SilentlyContinue
$ArcServe = Get-EventLog -LogName Application -After (Get-Date).AddDays(-10) | where {($_.Source -like "ESE") -and ($_.ID -eq 213)} -ErrorAction SilentlyContinue
$BackupExec = Get-EventLog -LogName Application -After (Get-Date).AddDays(-1) | where {($_.Source -like "Backup Exec") -and ($_.ID -eq 34112)} -ErrorAction SilentlyContinue


Function WindowsBackup 
    {
        
        $yesterday = (Get-Date) - (New-TimeSpan -Days 1)
        $NewWindowsEvents = Get-WinEvent -LogName "Microsoft-Windows-Backup" | where-object {($_.TimeCreated -ge $yesterday) -and ($_.ID -eq 14)} -ErrorAction SilentlyContinue

        $Count = @($NewWindowsEvents).Count
        $LastBackup = $NewWindowsEvents.TimeCreated

        $myName = $MyInvocation.MyCommand.Name
        $Count = @($Events).Count
            
        If ($Count -gt 1)
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $false
                }
            Else
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $true
                }

          $Global:result = $result
          $Global:AEM_Exit =  $AEM_Exit
    }

Function Veeam
    {
        $Events = Get-EventLog -LogName "Veeam Backup" -After (Get-Date).AddHours($PeriodHourscheck) -InstanceId 110 -EntryType Information -ErrorAction SilentlyContinue

               $myName = $MyInvocation.MyCommand.Name
        $Count = @($Events).Count
            
        If ($Count -gt 1)
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $false
                }
            Else
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $true
                }

          $Global:result = $result
          $Global:AEM_Exit =  $AEM_Exit
    }


    Function VeeamAgent
    {
        $Events = Get-EventLog -LogName "Veeam Agent" -After (Get-Date).AddHours($PeriodHourscheck) -InstanceId 190 -EntryType Information,Warning -ErrorAction SilentlyContinue
        $myName = $MyInvocation.MyCommand.Name
        $Count = @($Events).Count
            
        If ($Count -gt 1)
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $false
                }
            Else
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $true
                }

          $Global:result = $result
          $Global:AEM_Exit =  $AEM_Exit
    }




Function ShadowProtect
    {
        $Events = Get-EventLog -LogName Application -After (Get-Date).AddHours($PeriodHourscheck) -Source "ShadowProtectSvc" | Where-Object { $_.EventID -eq "1120" }
        $myName = $MyInvocation.MyCommand.Name
        $Count = @($Events).Count
            
        If ($Count -gt 1)
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $false
                }
            Else
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $true
                }

          $Global:result = $result
          $Global:AEM_Exit =  $AEM_Exit
    }





Function ShadowProtectSPX
    {
        $Events = Get-EventLog -LogName Application -After (Get-Date).AddHours($PeriodHourscheck) | where {($_.Source -like "ShadowProtectSPX") -and ($_.InstanceID -eq 3)}
        $myName = $MyInvocation.MyCommand.Name
        $Count = $Events.Count
            
        If ($Count -gt 1)
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $false
                }
            Else
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $true
                }

          $Global:result = $result
          $Global:AEM_Exit =  $AEM_Exit
    }




Function Acronis
    {
        $Events = Get-EventLog -LogName Application -After (Get-Date).AddHours($PeriodHourscheck) | where {($_.Source -like "Acronis*") -and ($_.ID -eq 1)} -ErrorAction SilentlyContinue

           $myName = $MyInvocation.MyCommand.Name
        $Count = @($Events).Count
            
        If ($Count -gt 1)
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $false
                }
            Else
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $true
                }

          $Global:result = $result
          $Global:AEM_Exit =  $AEM_Exit
    }
                    
Function ArcServe
    {
        $Events = Get-EventLog -LogName Application -After (Get-Date).AddHours($PeriodHourscheck) | where {($_.Source -like "ESE") -and ($_.ID -eq 213)} -ErrorAction SilentlyContinue

                $myName = $MyInvocation.MyCommand.Name
        $Count = @($Events).Count
            
        If ($Count -gt 1)
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $false
                }
            Else
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $true
                }

          $Global:result = $result
          $Global:AEM_Exit =  $AEM_Exit
    }
 
 Function BackupExec
    {
        $Events = Get-EventLog -LogName Application -After (Get-Date).AddHours($PeriodHourscheck) | where {($_.Source -like "Backup Exec") -and ($_.ID -eq 34112)} -ErrorAction SilentlyContinue

               $myName = $MyInvocation.MyCommand.Name
        $Count = @($Events).Count
            
        If ($Count -gt 1)
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $false
                }
            Else
                {
                    $result = "$myName($Count)"
                    $resultCF = $result
                    $AEM_Exit = $true
                }

          $Global:result = $result
          $Global:AEM_Exit =  $AEM_Exit
    }      
    
    
    
    
    
    
If ($BackupWindows)     {
        $Backup_found = 1
        $Backup = "Windows"
        WindowsBackup
        
    }

If ($BackupVeeam)
    {
        $Backup_found = 1
        $Backup = "Veeam"
        Veeam        
    }


If ($BackupVeeamAgent)
    {
        $Backup_found = 1
        $Backup = "Veeam Agent"
        VeeamAgent        
    }



If ($BackupShadowProtect)
    {
        $Backup_found = 1
        $Backup = "Shadow Protect"
        ShadowProtect
    }
If ($BackupShadowProtextSPX)

    {
        $Backup_found = 1
        $Backup = "Shadow Protect SPX"
        ShadowProtectSPX
    }
If ($Acronis)
    {
        $Backup_found = 1
        $Backup = "Acronis"
        Acronis
    }
If ($ArcServe)
    {
        $Backup_found = 1
        $Backup = "ArcServe"
        ArcServe
    }
If ($BackupExec)
    {
        $Backup_found = 1
        $Backup = "Backup Exec"
        BackupExec
    }







if ($Global:AEM_Exit -eq $true) {
Write-Host "<-Start Result->"
Write-Host "-=NO BACKUPS FOUND! Really? (Checked $PeriodHourscheck hours)"
Write-Host "<-End Result->"

Write-Host "<-Start Diagnostic->"
write-Host "BACKUP-Monitor überwacht auf erfolgreiche Einträge im Eventlog. Bei Fragen an Kai wenden!"
Write-Host $AEM_Diagnostic + "`n `n" + $KBARTICLE
Write-Host "<-End Diagnostic->"
Set-ItemProperty -Path HKLM:\Software\CentraStage -Name Custom$CustomField -Value "NO BACKUPS FOUND! Really? (Checked $PeriodHourscheck hours)"
Exit 1
}
else
{
Write-Host "<-Start Result->"
#Write-Host "-=All fine!"
Write-Host "Backups found ($PeriodHourscheck h)=$result" 
Write-Host "<-End Result->"
Set-ItemProperty -Path HKLM:\Software\CentraStage -Name Custom$CustomField -Value "$result"
Exit 0

}