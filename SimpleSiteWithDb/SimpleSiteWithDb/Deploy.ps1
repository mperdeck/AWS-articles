# This file must be part of the project, 
# and must have property "Copy to Output Directory" set to "Copy always".
# That way it will be packaged and deployed.

Function WaitUntilWebsiteReachesState([string]$siteName, [string]$state)
{
	do { 
		Start-Sleep -m 50; 
		$webSiteState = (cmd /c %systemroot%\system32\inetsrv\appcmd list site $siteName /text:state) | Out-String
	} while ($webSiteState.Trim() -ne $state)
}




    Write-Host ">>> dewploy"

# Find the directory that this script is running in
$scriptpath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptpath

# -------------------
add-windowsfeature web-webserver -includeallsubfeature -logpath $env:temp\webserver_addrole.log
add-windowsfeature web-mgmt-tools -includeallsubfeature -logpath $env:temp\mgmttools_addrole.log


# Stop the Default Web Site
cmd /c %systemroot%\system32\inetsrv\appcmd stop site /site.name:"Default Web Site"

# Give it an application pool that runs .Net 4.0
cmd /c %systemroot%\system32\inetsrv\appcmd add apppool /name:"v4.0" /managedRuntimeVersion:"v4.0" /managedPipelineMode:Integrated
cmd /c %systemroot%\system32\inetsrv\appcmd set site /site.name:"Default Web Site" "/[path='/'].applicationPool:v4.0"

# Wait until the web site has stopped
do { 
	Start-Sleep -m 50; 
	$defaultWebSiteState = (cmd /c %systemroot%\system32\inetsrv\appcmd list site "Default Web Site" /text:state) | Out-String
	$defaultWebSiteState
} while ($defaultWebSiteState -ne "Stopped")

# Remove all its files
$physicalPath = Get-ItemProperty 'IIS:\Sites\Default Web Site' physicalPath
$physicalPathContent = [System.Environment]::ExpandEnvironmentVariables("$physicalPath") + '\*'
Remove-Item $physicalPathContent -recurse

# Deploy the files to the root directory of the Default Web Site
copy-item "$scriptDir\*" $physicalPath -force -recurse
# CMD /C release.deploy.cmd /Y  "-setParam:kind=TextFile,scope=\\web.config$,match=@@DbServer@@,value='xxx yyy zz-----z' -setParam:kind=TextFile,scope=\\web.config$,match=@@DbUsername@@,value='xxx yyy z----zz2aaa' -setParam:kind=TextFile,scope=\\web.config$,match=@@DbPassword@@,value='xxx yyy zzz----3aaaaa' -setparam:name='IIS Web Application Name',kind=providerpath,scope=apphostconfig,value='default web site'"

# Start the web site again
cmd /c %systemroot%\system32\inetsrv\appcmd start site /site.name:"Default Web Site"

