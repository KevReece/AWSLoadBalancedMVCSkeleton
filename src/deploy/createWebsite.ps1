Write-Host "Creating website in IIS..."

$ErrorActionPreference = "Stop"

$deployWebPath = "c:\ExampleApp\deploy\Web\"
$webPath = "c:\ExampleApp\Web\"
$iisAppPoolName = "ExampleApp"
$iisSiteName = "ExampleApp"
$iisAppPoolDotNetVersion = "v4.0"
$defaultAppPoolName = "DefaultAppPool"
$defaultSiteName = "Default Web Site"

Write-Host "Import-Module WebAdministration"
Import-Module WebAdministration

Write-Host "Import-Module AWSPowerShell"
Import-Module AWSPowerShell

Write-Host "Get instance Id"
$metaDataUrl = 'http://169.254.169.254/latest/meta-data/'
$webClient = New-Object Net.WebClient
$instanceId = $webClient.DownloadString($metaDataUrl + 'instance-id')

Write-Host "Get auto scaling group"
$availabilityZone = $webClient.DownloadString($metaDataUrl + 'placement/availability-zone')
$region = Get-AWSRegion | where { $availabilityZone -match $_.Region }
$autoScalingGroupName = (Get-ASAutoScalingInstance -InstanceId $instanceId -MaxRecord 1 -Region $region).AutoScalingGroupName

function RemoveExistingSite() 
{
    if (Test-Path "IIS:\Sites\$iisSiteName" -pathType container)
    {
        Write-Host "Removing existing site"
        Remove-Website $iisSiteName
    }

    if (Test-Path "IIS:\AppPools\$iisAppPoolName" -pathType container)
    {
        Write-Host "Removing existing app pool"
        Remove-WebAppPool $iisAppPoolName
    }

    if (Test-Path "IIS:\Sites\$defaultSiteName" -pathType container)
    {
        Write-Host "Removing default site"
        Remove-Website $defaultSiteName
    }

    if ((Test-Path "IIS:\AppPools\$defaultAppPoolName" -pathType container))
    {
        Write-Host "Removing default app pool"
        Remove-WebAppPool $defaultAppPoolName
    }

    if (Test-Path $webPath -pathType container)
    {
        Write-Host "Delete old web folder"
        &cmd.exe /c rd /s /q $webPath
    }
}

function CreateNewSite()
{
    Write-Host "Copying web folder"
    Copy-Item $deployWebPath $webPath -recurse

    Write-Host "Creating the app pool"
    cd IIS:\AppPools\
    New-Item $iisAppPoolName `
        | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
    Stop-WebAppPool $iisAppPoolName

    Write-Host "Creating the website"
    cd IIS:\Sites\
    New-Item $iisSiteName -bindings @{protocol="http";bindingInformation=":80:"} -physicalPath $webPath `
        | Set-ItemProperty -Name "applicationPool" -Value $iisAppPoolName

    Write-Host "Starting app pool"
    Start-WebAppPool $iisAppPoolName
}

function DetachInstanceFromAutoScalingGroup()
{
    Write-Host "DetachInstanceFromAutoScalingGroup..."
    $instanceAutoScalingState = (Get-ASAutoScalingInstance -InstanceId $instanceId).LifecycleState
    if ($instanceAutoScalingState -eq "InService")
    {
        Enter-ASStandby -InstanceId $instanceId -AutoScalingGroupName $autoScalingGroupName -ShouldDecrementDesiredCapacity $true -Force
        WaitForAutoscalingStatus("Standby")
        Write-Host "DetachInstanceFromAutoScalingGroup complete"
    }
    else
    {
        Write-Host "DetachInstanceFromAutoScalingGroup skipped as instance autoscaling state is: " + $instanceAutoScalingState
    }
}

function AttachInstanceToAutoScalingGroup()
{
    Write-Host "AttachInstanceToAutoScalingGroup..."
    $instanceAutoScalingState = (Get-ASAutoScalingInstance -InstanceId $instanceId).LifecycleState
    if ($instanceAutoScalingState -eq "Standby")
    {
        Exit-ASStandby -InstanceId $instanceId -AutoScalingGroupName $autoScalingGroupName -Force
        WaitForAutoscalingStatus("InService")
        Write-Host "AttachInstanceToAutoScalingGroup complete"
    }
    else
    {
        Write-Host "AttachInstanceToAutoScalingGroup skipped as instance autoscaling state is: " + $instanceAutoScalingState
    }
}

function WaitForAutoscalingStatus([string]$statusToWaitFor)
{
    Write-Host "Waiting for status: " + $statusToWaitFor
    $timeout = New-Timespan -Minutes 5
    $stopWatch = [Diagnostics.Stopwatch]::StartNew()
    while ($stopWatch.elapsed -lt $timeout)
    {
        $instanceAutoScalingState = (Get-ASAutoScalingInstance -InstanceId $instanceId).LifecycleState
        if ($instanceAutoScalingState -eq $statusToWaitFor) {
            Write-Host "Status acheived"
            return
        }
        Start-Sleep -seconds 1
    }
    Write-Host "Wait timeout. Status: " + $instanceAutoScalingState
}

DetachInstanceFromAutoScalingGroup
RemoveExistingSite
CreateNewSite
AttachInstanceToAutoScalingGroup

Write-Host "Finished creating website in IIS"
