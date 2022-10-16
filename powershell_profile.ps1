$Env:KEY='240 91 89 201 193 167 96 19 196 13 79 240 167 234 86 201 167 115 109 145 165 129 73 3 102 188 236 225 70 176 74 159'

$Env:AWS_CLI_AUTO_PROMPT='off'
$Env:AWS_PROFILELOCATION="$Home\.aws\credentials"

$Env:AWS_CSM_ENABLED=$true
$Env:AWS_CSM_PORT=31000
$Env:AWS_CSM_HOST=127.0.0.1



#region load AWS Profile if found
if (Test-Path -Path $Env:AWS_PROFILELOCATION) {
    function stc
    {
        param($pf)
        $Env:AWS_ACCESS_KEY_ID 
    
        Set-AWSCredentials -AccessKey $Env:AWS_ACCESS_KEY_ID -SecretKey $Env:AWS_SECRET_ACCESS_KEY -SessionToken $Env:AWS_SESSION_TOKEN -StoreAs $pf -ProfileLocation $Env:AWS_PROFILELOCATION
    }

    function sac
    {
        param($pf)
        $Env:AWS_PROFILE=$pf
        Set-AWSCredential -ProfileName $pf -ProfileLocation $Env:AWS_PROFILELOCATION
        $cred=Get-AWSCredential -ProfileName $pf -ProfileLocation $Env:AWS_PROFILELOCATION
        $Env:AWS_ACCESS_KEY_ID=$cred.GetCredentials().AccessKey
        $Env:AWS_SECRET_ACCESS_KEY=$cred.GetCredentials().SecretKey
        $Env:AWS_SESSION_TOKEN=$cred.GetCredentials().Token

    }
}
else {
    <# Action when all if and elseif conditions are false #>
    Write-Output "AWS credentials not available"
    Write-Output "Copy file to: $Home\.aws\credentials"
    Write-Output "Download from AWS Console on web"
}
#endregion

function Set-Key
{
    $Env:KEY = Get-Clipboard
}

function Invoke-DisplayKey
{
    Write-Host $Env:KEY
}
Set-Alias -Name dk -Value Invoke-DisplayKey

function Invoke-AssignKey
{
    param($k)
    $Env:KEY+=$k
}
Set-Alias -Name ak -Value Invoke-AssignKey




function Invoke-EncryptStuff
{ 
    Param(
        [Parameter(ValueFromPipeline)]
        $InputObject,
        $Key
    )
    BEGIN {
        if ( ($null -ne $Env:KEY) -and ($null -eq $Key) )
        {
            $Key = $Env:KEY -Split ' '
        }
        if ($null -eq $Key)
        {
            $Key = (1..16)
        }
   }

    PROCESS {
    #write-host $Key
        $sstr = $InputObject | ConvertTo-SecureString -AsPlainText -Force 
        ConvertFrom-SecureString -SecureString $sstr -Key $Key
    }
}
Set-Alias -Name Encrypt-Stuff -Value Invoke-EncryptStuff

function Invoke-DecryptStuff
{ 
    Param(
        [Parameter(ValueFromPipeline)]
        $InputObject,
        $Key
    )
    BEGIN {
        if ( ($null -ne $Env:KEY) -and ($null -eq $Key) )
        {
            $Key = $Env:KEY -Split ' '
        }
        if ($null -eq $Key) 
        {
            $Key = (1..16)
        }
    }
    PROCESS {
        #"Input:{0}, {1}"  -f $inputobject,$Key
        #Write-Host $Key
        $SecString = $InputObject | ConvertTo-SecureString -Key $Key
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecString)
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    }
}
Set-Alias -Name Decrypt-Stuff -Value Invoke-DecryptStuff

function csql
{
    Write-Host -ForegroundColor Green ("Log in as {0} onto {1}" -f $Env:SCHEMA, $Env:TNS)
    sqlplus  $Env:SCHEMA`/$Env:PASSWD`@$Env:TNS
}

function Get-SQLEnv
{
    Param(
        [Parameter(ValueFromPipeline)]
        $InputObject,
        $c1,
        $c2
    )
    BEGIN {
        if ($null -eq $InputObject)
        {
                $inputObject = (Get-Content -Path $Home\vault | Decrypt-Stuff | ConvertFrom-Json )
        }
    }
    PROCESS {
        $inputobject | Where-Object tns -like ("*{0}*" -f $c1) | Where-Object schema -like ("*{0}*" -f $c2)
    }
}

function Set-SQLEnv
{
    Param(
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    BEGIN {

    }
    PROCESS {
        $Env:TNS = $InputObject.tns
        $Env:SCHEMA = $InputObject.schema
        $Env:PASSWD = $InputObject.passwd
    }
}

function Test-Tcp
{
    param($1,$2);
    try {
        $null = New-Object System.Net.Sockets.TCPClient -ArgumentList $1,$2;
        $true;
    } catch {
        $false;
    }
}

# 7-Zip
$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"
if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
    throw "7 zip file '$7zipPath' not found"
}
Set-Alias 7za $7zipPath