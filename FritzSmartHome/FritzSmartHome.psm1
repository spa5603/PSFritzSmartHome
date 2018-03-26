function Get-StringMD5Hash {

    Param (
        [Parameter (Mandatory = $true)]
        [string]$string
        )
    
        $MD5 = [System.Security.Cryptography.md5]::Create()
        $InputString = [System.Text.Encoding]::Unicode.GetBytes($string)
        $Hash = $MD5.ComputeHash($InputString)
    
        $StringBuilder = New-Object System.Text.StringBuilder
        for ($i = 0; $i -lt $Hash.Length; $i++)
        {
            $null = $StringBuilder.Append($Hash[$i].ToString("x2"))
        }
        $MD5Hash = $StringBuilder.ToString()

    # Return
    Return $MD5Hash
}

function Get-FritzBoxSID {

    Param (
        [Parameter (Mandatory = $true)][string]$Password,
        [string]$LoginUrl = 'http://fritz.box/login_sid.lua'
        )

        # Get Challenge
        [xml]$ChallengeXML = (Invoke-WebRequest -Uri $LoginUrl).Content
        [string]$Challenge = $ChallengeXML.SessionInfo.Challenge
        [string]$HashString = $Challenge + '-' + $Password
        [string]$Response = $Challenge + '-' + (Get-StringMD5Hash -string $HashString)
        # Get SID

        [xml]$SIDXML = (Invoke-WebRequest -Uri ($LoginUrl + '?response=' + $Response)).Content
        [string]$SID = $SIDXML.SessionInfo.SID
    
    # Return
    Return $SID
}

function Get-HtrMeasuredTemp {

    Param (
        [Parameter (Mandatory = $true)][string]$Ain,
        [Parameter (Mandatory = $true)][string]$SID
        )

        [double]$Temp = (((Invoke-WebRequest -Uri ("http://fritz.box/webservices/homeautoswitch.lua?ain=$Ain&switchcmd=gettemperature&sid=$SID")).Content).ToString()).Insert(2,'.')

        # Return
    Return $Temp
}