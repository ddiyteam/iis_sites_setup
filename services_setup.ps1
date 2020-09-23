param([String]$username=$null, [String]$password=$null, [String]$conffile=$null);

Write-Host "setup started with $conffile" -ForegroundColor green;

if(!$username)
{
    throw "username parameter is null"
}

if(!$password)
{
    throw "password parameter is null"
}

if(!$conffile)
{
    throw "conffile parameter is null"
}

Import-Module WebAdministration;
function RecreateApplicationPool($appPoolName, $isAutoStart, $username, $password) {
    if(Test-Path IIS:\AppPools\$appPoolName)
    {
        Remove-WebAppPool -Name $appPoolName;
    }

    New-WebAppPool -Name $appPoolName -Force;
    $newPool = Get-Item IIS:\AppPools\$appPoolName;
    $newPool.ProcessModel.Username = $username;
    $newPool.ProcessModel.Password = $password;
    $newPool.ProcessModel.IdentityType = 3;
    $newPool.managedRuntimeVersion = "";
    if($isAutoStart)
    {
        $newPool.autoStart = 'true';
        $newPool.startmode = 'alwaysrunning';
    }

    $newPool | Set-Item;
    Start-WebAppPool -Name $appPoolName;
}

function ConfigureServiceAuth($name, $site, $isAnonymousAuth, $isBasicAuth, $isWindowsAuth) {
    if($null -ne $isAnonymousAuth)
    {
        Set-WebConfigurationProperty -filter "/system.WebServer/security/authentication/AnonymousAuthentication" -name Enabled -value $isAnonymousAuth -location "$site/$name";	
    }

    if($null -ne $isBasicAuth)
    {
        Set-WebConfigurationProperty -filter "/system.WebServer/security/authentication/basicAuthentication" -name Enabled -value $isBasicAuth -location "$site/$name";
    }

    if($isWindowsAuth -eq $true -Or $isWindowsAuth -eq $false)
    {
        Set-WebConfigurationProperty -filter "/system.WebServer/security/authentication/windowsAuthentication" -name Enabled -value $isWindowsAuth -location "$site/$name";
    }
}

$serviceData = Get-Content -Raw -Path "$conffile" | ConvertFrom-Json
$serviceData | ForEach-Object {
    $name = $_.name;
    $port = $_.port;
    $path = $_.path;
    $appPoolName = $_.appPool.name;
    $isAutoStart = $_.appPool.isAutoStart;
    $isAnonymousAuth = $_.auth.anonymous;
    $isBasicAuth = $_.auth.basic;
    $isWindowsAuth = $_.auth.windows;

    $applications = $_.applications;

    RecreateApplicationPool $appPoolName $isAutoStart $username $password;

    if(Test-Path IIS:\Sites\$name)
    {
        Remove-Website -Name $name;
    }
    New-WebSite -Name $name -Port $port  -PhysicalPath $path -ApplicationPool $appPoolName -Force;
    ConfigureServiceAuth $name "" $isAnonymousAuth $isBasicAuth $isWindowsAuth;

    foreach($application in $applications)
    {
        $name = $application.name;
        $type = $application.type;
        $site = $application.site;
        $path = $application.path;
        $appPoolName = $application.appPool.name;
        $isAutoStart = $application.appPool.isAutoStart;
        $isAnonymousAuth = $application.auth.anonymous;
        $isBasicAuth = $application.auth.basic;
        $isWindowsAuth = $application.auth.windows;

        if($appPoolName)
        {
            RecreateApplicationPool $appPoolName $isAutoStart $username $password;
        }

        if($type -eq "virtual")
        {
            New-WebVirtualDirectory -Site $site -Name $name -PhysicalPath $path;
        }
        elseif($appPoolName)
        {
            New-WebApplication -Site $site -Name $name -PhysicalPath $path -ApplicationPool $appPoolName -Force;
            ConfigureServiceAuth $name $site $isAnonymousAuth $isBasicAuth $isWindowsAuth;
        }
    }
}

Write-Host "deploy was finished" -ForegroundColor green;
