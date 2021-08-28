################################################################
#                                                              #
#           3CX Extenstion Information Script                  # 
#                                                              #
#                                                              #
# Note: 1. Storing Credentials in a script is not recomended!  #
#            Consider using CredentialManager or clixml        #
#       2. Running this script is at your own risk             #
#                                                              #
#                                                              #
# Script By: Aaron Falzon - Chris Humphrey Office National     #
################################################################

$3cxurl  = '' #Enter your url here including the trailing forward slash (eg. https://xyz.3cx.com.au/)
$3cxuser = 'admin' #3cx admin user, consider creating a restricterd admin user 
$3cxpass = '' #3cx Password

$3cxcreds = "{`"Username`":`"$3cxuser`",`"Password`":`"$3cxpass`"}"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$login = Invoke-WebRequest -Uri "$($3cxurl)api/login" `
    -Method "POST" `
    -Headers @{
        "Accept"="application/json, text/plain, */*"; 
        "Referer"="$($3cxurl)"; 
        "Origin"="$($3cxurl)"; 
        "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36"
        } `
    -ContentType "application/json;charset=UTF-8" `
    -Body $3cxcreds `
    -SessionVariable sesh

if ($login.StatusCode -ne "200") {
    throw "Login to 3CX failed: $($login.content)"
    exit
} else {
#throw "Success!: $($login.content)"
$number="0"
$Extns = (irm -Uri "$($3cxurl)api/ExtensionList" -websession $sesh).list


$Extns |% {
    Write-Host "Checking VM for:" -ForegroundColor Green
   # Write-host "ID: $($_.id)"
    Write-host "Name: $($_.FirstName)"
    Write-host "Ext: $($_.Number)"
    $Ext = iwr -Uri "$($3cxurl)api/ExtensionList/set" -Method Post -websession $sesh -Body "{`"Id`":$($_.id)}" -ContentType "application/json;charset=UTF-8" 
    $greeting = ($Ext.Content |ConvertFrom-Json).activeobject.greetingdefault 
    Write-host "Greeting: $($greeting.selected)"
    }
}

