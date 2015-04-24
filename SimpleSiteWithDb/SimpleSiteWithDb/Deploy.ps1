# This file must be part of the project, 
# and must have property "Copy to Output Directory" set to "Copy always".
# That way it will be packaged and deployed.

    Write-Host ">>> dewploy"

$scriptpath = $MyInvocation.MyCommand.Path
$scriptpath
$scriptDir = Split-Path $scriptpath
$scriptDir

    Write-Host "<<< dewploy"
return





cd $scriptDir


# -------------------
add-windowsfeature web-webserver -includeallsubfeature -logpath $env:temp\webserver_addrole.log
add-windowsfeature web-mgmt-tools -includeallsubfeature -logpath $env:temp\mgmttools_addrole.log


# Stop the Default Web Site
cmd /c %systemroot%\system32\inetsrv\appcmd stop site /site.name:"Default Web Site"

# Give it an application pool that runs .Net 4.0
cmd /c %systemroot%\system32\inetsrv\appcmd add apppool /name:"v4.0" /managedRuntimeVersion:"v4.0" /managedPipelineMode:Integrated
Set-ItemProperty 'IIS:\Sites\Default Web Site' ApplicationPool "v4.0"

############## wait unitl web site stopped. Then wipe its files
do { Start-Sleep -m 50; $defaultWebSiteState = Get-ItemProperty 'IIS:\Sites\Default Web Site' State } while ($defaultWebSiteState.Value -ne "Stopped")

# remove all files from the Default Web Site
$physicalPath = Get-ItemProperty 'IIS:\Sites\Default Web Site' physicalPath
$physicalPath = [System.Environment]::ExpandEnvironmentVariables("$physicalPath") + '\*'
Remove-Item $physicalPath -recurse

# Deploy the files to the root directory of the Default Web Site
CMD /C release.deploy.cmd /Y  "-setParam:kind=TextFile,scope=\\web.config$,match=@@DbServer@@,value='xxx yyy zz-----z' -setParam:kind=TextFile,scope=\\web.config$,match=@@DbUsername@@,value='xxx yyy z----zz2aaa' -setParam:kind=TextFile,scope=\\web.config$,match=@@DbPassword@@,value='xxx yyy zzz----3aaaaa' -setparam:name='IIS Web Application Name',kind=providerpath,scope=apphostconfig,value='default web site'"

# Start the Default Web Site
start-website -name "Default Web Site"
cmd /c %systemroot%\system32\inetsrv\appcmd start site /site.name:"Default Web Site"

