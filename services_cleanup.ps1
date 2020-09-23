param([String]$conffile=$null);

Write-Host "cleaup started with $conffile.json" -ForegroundColor green;

Import-Module WebAdministration;

$serviceData = Get-Content -Raw -Path services_conf.json | ConvertFrom-Json
$serviceData | ForEach-Object {
    $name = $_.name;   
    $appPoolName = $_.appPool.name;

    $applications = $_.applications;

    if(Test-Path IIS:\AppPools\$appPoolName)
    {
        Remove-WebAppPool -Name $appPoolName;	
    }
    
    if(Test-Path IIS:\Sites\$name)
    {
        Remove-Website -Name $name;
    }    

    foreach($application in $applications)
    {
        $name = $application.name;      
        $appPoolName = $application.appPool.name;       

        if($appPoolName)
        {
            if(Test-Path IIS:\AppPools\$appPoolName)
            {
                Remove-WebAppPool -Name $appPoolName;	
            }
        }       
    }
}

Write-Host "cleanup was finished" -ForegroundColor green;
