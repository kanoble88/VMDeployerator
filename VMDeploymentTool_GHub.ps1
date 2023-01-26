<#
Version : 1
By: Keith Noble
Description : GUI to Automate the Cloning and Deployment of VMs for my team
** I copied the GUI and some functions from some other dude who had a template until I receive a Sapien license

Currently Supports:
- Windows 10 VM Cloning
* Linux Is Not Yet Working

- Future Plans:
    - Re-Do code to use RunSpace & XAML to free up processes and remediate PowerShell Hanging when running the script multiple times
    - Create/Delete User Accounts in AD From Tool
    - Add Option to Deploy Windows and Linux VMs, create a vApp for them and move them into the vApp and into their proper folder

** I am by no means a good at PowerShell or Scripting or Programming so the code is probably beyond sloppy as this is a work in progress

* There are no plans to provide support for this, as it was something I did just to make my life easier cause I am lazy.

Requires PowerCLI to be installed on the system running the GUI

#>


# VARIABLES
# Deployment Threshold
# - If Threshold is met VM Won't Be Deployed
$DSMinFreeSpacePercent   = 10
$DSMaxProvisionedPercent = 300
$MemMaxusedPercent = 90
$CPUMaxUsedPercent = 90
# Deployment Threshold Warning
# - Warn User Threshold is close To Being Met - But Still Deploy
$DSWarningFreeSpacePercent   = 20
$DSWarningProvisionedPercent = 150
$MemWarningusedPercent = 80
$CPUWarningUsedPercent = 80

# Windows Form Creation
# - Create GUI
Function Show-Form {

<# 
Copied This Form Template From A PoSH GUI Template I Found
Until Ryan Gets Me A Sapien License
#>

# VM Variables
# - Variables For Dropdowns
$CPUSizes    = 1,2,4,8
$MemorySizes = 1..16
$DiskSizes   = 32,64,80,128
#$vNicCount   = 1,2,3,4 - Not Quite Ready For Use
#Add Domains Here That Cloned VMs can be added to
$DomainList  = "domain1.com","domain2.com","domain3.com"

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.Height                     = 900
$Form.Width                      = 500
$Form.text                       = "VM Deployerator"
$Form.TopMost                    = $false
$Form.MaximizeBox                = $false

<#
#Icon in Base64
$iconBase64      = 'Add Base64 Code Here for Icon'
$iconBytes       = [Convert]::FromBase64String($iconBase64)
$stream          = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
$stream.Write($iconBytes, 0, $iconBytes.Length);
$Form.Icon       = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -ArgumentList $stream).GetHIcon())
#>
# Labels for GUI
# - Creating Labels For Each GUI Element

# - vCenter Label
$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "vCenter"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(17,18)
$Label1.Font                     = 'Microsoft Sans Serif,10'

# - Username Label
$Label117                        = New-Object system.Windows.Forms.Label
$Label117.text                   = "Username"
$Label117.AutoSize               = $true
$Label117.width                  = 25
$Label117.height                 = 10
$Label117.location               = New-Object System.Drawing.Point(17,44)
$Label117.Font                   = 'Microsoft Sans Serif,10'

# - Password Label
$Label118                        = New-Object system.Windows.Forms.Label
$Label118.text                   = "Password"
$Label118.AutoSize               = $true
$Label118.width                  = 25
$Label118.height                 = 10
$Label118.location               = New-Object System.Drawing.Point(17,68)
$Label118.Font                   = 'Microsoft Sans Serif,10'

# - VM Name Label
$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "VM Name"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(17,191)
$Label2.Font                     = 'Microsoft Sans Serif,10'

# - Cluster Label
$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Cluster"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(17,224)
$Label3.Font                     = 'Microsoft Sans Serif,10'

# - Datastore Label
$Label4                          = New-Object system.Windows.Forms.Label
$Label4.text                     = "Datastore"
$Label4.AutoSize                 = $true
$Label4.width                    = 25
$Label4.height                   = 10
$Label4.location                 = New-Object System.Drawing.Point(17,250)
$Label4.Font                     = 'Microsoft Sans Serif,10'

# - Portgroup Label
$Label5                          = New-Object system.Windows.Forms.Label
$Label5.text                     = "PortGroup"
$Label5.AutoSize                 = $true
$Label5.width                    = 25
$Label5.height                   = 10
$Label5.location                 = New-Object System.Drawing.Point(17,280)
$Label5.Font                     = 'Microsoft Sans Serif,10'

# - vCPU Label
$Label6                          = New-Object system.Windows.Forms.Label
$Label6.text                     = "vCPU"
$Label6.AutoSize                 = $true
$Label6.width                    = 25
$Label6.height                   = 10
$Label6.location                 = New-Object System.Drawing.Point(17,430)
$Label6.Font                     = 'Microsoft Sans Serif,10'

# - Memory Label
$Label7                          = New-Object system.Windows.Forms.Label
$Label7.text                     = "Memory GB"
$Label7.AutoSize                 = $true
$Label7.width                    = 25
$Label7.height                   = 10
$Label7.location                 = New-Object System.Drawing.Point(102,430)
$Label7.Font                     = 'Microsoft Sans Serif,10'

# - vNIC Label
# Not Used
$Label8                          = New-Object system.Windows.Forms.Label
$Label8.text                     = "" #"vNIC"
$Label8.AutoSize                 = $true
$Label8.width                    = 25
$Label8.height                   = 10
$Label8.location                 = New-Object System.Drawing.Point(202,339)
$Label8.Font                     = 'Microsoft Sans Serif,10'

# - HD Labels
$Label9                          = New-Object system.Windows.Forms.Label
$Label9.text                     = "Base disk"
$Label9.AutoSize                 = $true
$Label9.width                    = 25
$Label9.height                   = 10
$Label9.location                 = New-Object System.Drawing.Point(17,480)
$Label9.Font                     = 'Microsoft Sans Serif,10'

$Label10                         = New-Object system.Windows.Forms.Label
$Label10.text                    = "Disk 2"
$Label10.AutoSize                = $true
$Label10.width                   = 25
$Label10.height                  = 10
$Label10.location                = New-Object System.Drawing.Point(102,480)
$Label10.Font                    = 'Microsoft Sans Serif,10'

$Label11                         = New-Object system.Windows.Forms.Label
$Label11.text                    = "Disk 3"
$Label11.AutoSize                = $true
$Label11.width                   = 25
$Label11.height                  = 10
$Label11.location                = New-Object System.Drawing.Point(202,480)
$Label11.Font                    = 'Microsoft Sans Serif,10'

$Label12                         = New-Object system.Windows.Forms.Label
$Label12.text                    = "Disk 4"
$Label12.AutoSize                = $true
$Label12.width                   = 25
$Label12.height                  = 10
$Label12.location                = New-Object System.Drawing.Point(297,480)
$Label12.Font                    = 'Microsoft Sans Serif,10'

# - IP Label
$Label13                         = New-Object system.Windows.Forms.Label
$Label13.text                    = "IP"
$Label13.AutoSize                = $true
$Label13.width                   = 25
$Label13.height                  = 10
$Label13.location                = New-Object System.Drawing.Point(17,540)
$Label13.Font                    = 'Microsoft Sans Serif,10'

# - Netmask Label
$Label14                         = New-Object system.Windows.Forms.Label
$Label14.text                    = "Netmask"
$Label14.AutoSize                = $true
$Label14.width                   = 25
$Label14.height                  = 10
$Label14.location                = New-Object System.Drawing.Point(102,540)
$Label14.Font                    = 'Microsoft Sans Serif,10'

# - Gateway Label
$Label15                         = New-Object system.Windows.Forms.Label
$Label15.text                    = "Gateway"
$Label15.AutoSize                = $true
$Label15.width                   = 25
$Label15.height                  = 10
$Label15.location                = New-Object System.Drawing.Point(202,540)
$Label15.Font                    = 'Microsoft Sans Serif,10'

# - DNS Label
$Label16                         = New-Object system.Windows.Forms.Label
$Label16.text                    = "DNS"
$Label16.AutoSize                = $true
$Label16.width                   = 25
$Label16.height                  = 10
$Label16.location                = New-Object System.Drawing.Point(297,540)
$Label16.Font                    = 'Microsoft Sans Serif,10'

# - Deploy Label
$deployButton                    = New-Object system.Windows.Forms.Button
$deployButton.text               = "Deploy"
$deployButton.width              = 164
$deployButton.height             = 30
$deployButton.enabled            = $false
$deployButton.location           = New-Object System.Drawing.Point(120,620)
$deployButton.Font               = 'Microsoft Sans Serif,10'

# - Progress Bar 
# Goes Underneath GUI To Provide Status - Sort of trash but works for now
$ProgressBar                     = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Width               = 365 
$ProgressBar.Height              = 20  
$ProgressBar.Location            = New-Object System.Drawing.Point(17,770)

# - vCenter Textbox
$vcentertextbox                  = New-Object system.Windows.Forms.TextBox
$vcentertextbox.multiline        = $false
$vcentertextbox.width            = 200
$vcentertextbox.height           = 20
$vcentertextbox.location         = New-Object System.Drawing.Point(105,14)
$vcentertextbox.Font             = 'Microsoft Sans Serif,10'

# - Username Textbox
$usernametextbox                 = New-Object system.Windows.Forms.TextBox
$usernametextbox.multiline       = $false
$usernametextbox.width           = 200
$usernametextbox.height          = 20
$usernametextbox.location        = New-Object System.Drawing.Point(105,40)
$usernametextbox.Font            = 'Microsoft Sans Serif,10'

#  - Password Textbox
$passwordtextbox                 = New-Object system.Windows.Forms.MaskedTextBox
$passwordtextbox.multiline       = $false
$passwordtextbox.PasswordChar    = '*'
$passwordtextbox.width           = 200
$passwordtextbox.height          = 20
$passwordtextbox.location        = New-Object System.Drawing.Point(105,68)
$passwordtextbox.Font            = 'Microsoft Sans Serif,10'

# - VM Name Textbox
$vmnameTextBox                   = New-Object system.Windows.Forms.TextBox
$vmnameTextBox.multiline         = $false
$vmnameTextBox.width             = 200
$vmnameTextBox.height            = 20
$vmnameTextBox.location          = New-Object System.Drawing.Point(105,190)
$vmnameTextBox.Font              = 'Microsoft Sans Serif,10'

# - Cluster Selection Dropdown
$clusterComboBox                 = New-Object system.Windows.Forms.ComboBox
$clusterComboBox.text            = "comboBox"
$clusterComboBox.width           = 200
$clusterComboBox.height          = 20
$clusterComboBox.location        = New-Object System.Drawing.Point(105,220)
$clusterComboBox.Font            = 'Microsoft Sans Serif,10'
$clusterComboBox.DropDownStyle   = "DropDownList"
$clusterComboBox.add_SelectedIndexChanged({Change-Cluster})

# - Datastore Selection Dropdown
$datastoreComboBox               = New-Object system.Windows.Forms.ComboBox
$datastoreComboBox.text          = "comboBox"
$datastoreComboBox.width         = 200
$datastoreComboBox.height        = 20
$datastoreComboBox.location      = New-Object System.Drawing.Point(105,250)
$datastoreComboBox.Font          = 'Microsoft Sans Serif,10'
$datastoreComboBox.DropDownStyle = "DropDownList"

# - Datastore Button To Show Datastore Memory Usage
$datastoreButton                 = New-Object system.Windows.Forms.Button
$datastoreButton.text            = "Details"
$datastoreButton.width           = 84
$datastoreButton.height          = 20
$datastoreButton.location        = New-Object System.Drawing.Point(314,250)
$datastoreButton.Font            = 'Microsoft Sans Serif,9'

# - Portgroup Selection Dropdown
$portgroupComboBox               = New-Object system.Windows.Forms.ComboBox
$portgroupComboBox.text          = "comboBox"
$portgroupComboBox.width         = 200
$portgroupComboBox.height        = 20
$portgroupComboBox.location      = New-Object System.Drawing.Point(105,280)
$portgroupComboBox.Font          = 'Microsoft Sans Serif,10'
$portgroupComboBox.DropDownStyle = "DropDownList"

# - CPU Selection Dropdown
$cpuComboBox                     = New-Object system.Windows.Forms.ComboBox
$cpuComboBox.width               = 70
$cpuComboBox.height              = 20
$CPUSizes | ForEach-Object {[void] $cpuComboBox.Items.Add($_)}
$cpuComboBox.location            = New-Object System.Drawing.Point(17,450)
$cpuComboBox.Font                = 'Microsoft Sans Serif,10'
$cpuComboBox.DropDownStyle       = "DropDownList"
$cpuComboBox.SelectedItem        = $cpuComboBox.Items[2]

# - Memory Selection Dropdown
$memoryComboBox                  = New-Object system.Windows.Forms.ComboBox
$memoryComboBox.width            = 70
$memoryComboBox.height           = 20
$MemorySizes | ForEach-Object {[void] $memoryComboBox.Items.Add($_)}
$memoryComboBox.location         = New-Object System.Drawing.Point(102,450)
$memoryComboBox.Font             = 'Microsoft Sans Serif,10'
$memoryComboBox.DropDownStyle    = "DropDownList"
$memoryComboBox.SelectedItem     = $memoryComboBox.Items[3]

<# vNIC Selection - Not Used
$vnicComboBox                    = New-Object system.Windows.Forms.ComboBox
$vnicComboBox.text               = "1"
$vnicComboBox.width              = 70
$vnicComboBox.height             = 20
$vNicCount | ForEach-Object {[void] $vnicComboBox.Items.Add($_)}
$vnicComboBox.location           = New-Object System.Drawing.Point(202,361)
$vnicComboBox.Font               = 'Microsoft Sans Serif,10'
$vnicComboBox.DropDownStyle      = "DropDownList"
$vnicComboBox.SelectedItem       = $vnicComboBox.Items[0]
#>

# - HD 1 Size Selection
$disk1ComboBox                   = New-Object system.Windows.Forms.ComboBox
$disk1ComboBox.width             = 70
$disk1ComboBox.height            = 20
$DiskSizes | ForEach-Object {[void] $disk1ComboBox.Items.Add($_)}
$disk1ComboBox.location          = New-Object System.Drawing.Point(17,500)
$disk1ComboBox.Font              = 'Microsoft Sans Serif,10'
$disk1ComboBox.DropDownStyle     = "DropDownList"

# - HD 2 Size Selection
$disk2TextBox                    = New-Object system.Windows.Forms.TextBox
$disk2TextBox.multiline          = $false
$disk2TextBox.width              = 70
$disk2TextBox.height             = 20
$disk2TextBox.location           = New-Object System.Drawing.Point(102,500)
$disk2TextBox.Font               = 'Microsoft Sans Serif,10'

# - HD 3 Size Selection
$disk3TextBox                    = New-Object system.Windows.Forms.TextBox
$disk3TextBox.multiline          = $false
$disk3TextBox.width              = 70
$disk3TextBox.height             = 20
$disk3TextBox.location           = New-Object System.Drawing.Point(202,500)
$disk3TextBox.Font               = 'Microsoft Sans Serif,10'

# - HD 4 Size Selection
$disk4TextBox                    = New-Object system.Windows.Forms.TextBox
$disk4TextBox.multiline          = $false
$disk4TextBox.width              = 70
$disk4TextBox.height             = 20
$disk4TextBox.location           = New-Object System.Drawing.Point(297,500)
$disk4TextBox.Font               = 'Microsoft Sans Serif,10'

# - IP Address Textbox
$ipTextBox                       = New-Object system.Windows.Forms.TextBox
$ipTextBox.multiline             = $false
$ipTextBox.width                 = 75
$ipTextBox.height                = 20
$ipTextBox.location              = New-Object System.Drawing.Point(17,560)
$ipTextBox.Font                  = 'Microsoft Sans Serif,7'

# - Netmask Selection Textbox
$netmaskTextBox                  = New-Object system.Windows.Forms.TextBox
$netmaskTextBox.multiline        = $false
$netmaskTextBox.width            = 75
$netmaskTextBox.height           = 20
$netmaskTextBox.location         = New-Object System.Drawing.Point(102,560)
$netmaskTextBox.Font             = 'Microsoft Sans Serif,7'

# - Gateway Selection Textbox
$gatewayTextBox                  = New-Object system.Windows.Forms.TextBox
$gatewayTextBox.multiline        = $false
$gatewayTextBox.width            = 75
$gatewayTextBox.height           = 20
$gatewayTextBox.location         = New-Object System.Drawing.Point(202,560)
$gatewayTextBox.Font             = 'Microsoft Sans Serif,7'

# - DNS 1 Textbox
$dns1TextBox                     = New-Object system.Windows.Forms.TextBox
$dns1TextBox.multiline           = $false
$dns1TextBox.width               = 75
$dns1TextBox.height              = 20
$dns1TextBox.location            = New-Object System.Drawing.Point(297,560)
$dns1TextBox.Font                = 'Microsoft Sans Serif,7'

# - DNS 2 Textbox
$dns2TextBox                     = New-Object system.Windows.Forms.TextBox
$dns2TextBox.multiline           = $false
$dns2TextBox.width               = 75
$dns2TextBox.height              = 20
$dns2TextBox.location            = New-Object System.Drawing.Point(297,580)
$dns2TextBox.Font                = 'Microsoft Sans Serif,7'

# - Label for Template Selection - Need To Move Up
$Label17                         = New-Object system.Windows.Forms.Label
$Label17.text                    = "Template"
$Label17.AutoSize                = $true
$Label17.width                   = 25
$Label17.height                  = 10
$Label17.location                = New-Object System.Drawing.Point(17,310)
$Label17.Font                    = 'Microsoft Sans Serif,10'

# - Template Selection Dropdown
$templateComboBox                = New-Object system.Windows.Forms.ComboBox
$templateComboBox.text           = "comboBox"
$templateComboBox.width          = 200
$templateComboBox.height         = 20
$templateComboBox.location       = New-Object System.Drawing.Point(105,310)
$templateComboBox.Font           = 'Microsoft Sans Serif,10'
$templateComboBox.DropDownStyle  = "DropDownList"
$templateComboBox.add_SelectedIndexChanged({Change-Template})

# - OS CustomSpec Label
$Label18                         = New-Object system.Windows.Forms.Label
$Label18.text                    = "CustomSpec"
$Label18.AutoSize                = $true
$Label18.width                   = 25
$Label18.height                  = 10
$Label18.location                = New-Object System.Drawing.Point(17,340)
$Label18.Font                    = 'Microsoft Sans Serif,10'

# - OS CustomSpec Selection
# This is where the Configurations For The VM Are Stored
$customspecComboBox              = New-Object system.Windows.Forms.ComboBox
$customspecComboBox.text         = "comboBox"
$customspecComboBox.width        = 200
$customspecComboBox.height       = 20
$customspecComboBox.location     = New-Object System.Drawing.Point(105,340)
$customspecComboBox.Font         = 'Microsoft Sans Serif,10'
$customspecComboBox.DropDownStyle= "DropDownList"
$customspecComboBox.add_SelectedIndexChanged({Change-CustomSpec})

# - Domain Selection Label
$Label19                         = New-Object system.Windows.Forms.Label
$Label19.text                    = "Domain"
$Label19.AutoSize                = $true
$Label19.width                   = 25
$Label19.height                  = 10
$Label19.location                = New-Object System.Drawing.Point(17,370)
$Label19.Font                    = 'Microsoft Sans Serif,10'

# - Domain Selection Dropdown
$domainComboBox                  = New-Object system.Windows.Forms.ComboBox
$domainComboBox.text             = "comboBox"
$domainComboBox.width            = 200
$domainComboBox.height           = 20
$domainComboBox.location         = New-Object System.Drawing.Point(105,370)
$domainComboBox.Font             = 'Microsoft Sans Serif,10'
$DomainList | ForEach-Object {[void] $domainComboBox.Items.Add($_)}
$domainComboBox.SelectedItem       = $domainComboBox.Items[0]

# - Domain Cred Button
# Opens Prompt For Username/Password To Add VM To Domain
$domainButton                    = New-Object system.Windows.Forms.Button
$domainButton.text               = "Credentials"
$domainButton.width              = 84
$domainButton.height             = 20
$domainButton.location           = New-Object System.Drawing.Point(314,370)
$domainButton.Font               = 'Microsoft Sans Serif,9'

# - Connect Button
# Connect to vCenter
$connectButton                   = New-Object system.Windows.Forms.Button
$connectButton.text              = "Connect"
$connectButton.width             = 84
$connectButton.height            = 20
$connectButton.location          = New-Object System.Drawing.Point(314,14)
$connectButton.Font              = 'Microsoft Sans Serif,9'

# - Connection Status Indicator
# Shows Red If Disconnected From VC - Green If Connected
$connectStatus                   = New-Object system.Windows.Forms.Label
$connectStatus.text              = "Disconnected"
$connectStatus.AutoSize          = $true
$connectStatus.ForeColor         = "Red"
$connectStatus.width             = 10
$connectStatus.height            = 10
$connectStatus.location          = New-Object System.Drawing.Point(314,35)
$connectStatus.Font              = 'Microsoft Sans Serif,8'

# - Folder Selection Label
$Label20                         = New-Object system.Windows.Forms.Label
$Label20.text                    = "Folder"
$Label20.AutoSize                = $true
$Label20.width                   = 25
$Label20.height                  = 10
$Label20.location                = New-Object System.Drawing.Point(17,400)
$Label20.Font                    = 'Microsoft Sans Serif,10'

# - Folder Selection Dropdown
$folderComboBox                  = New-Object system.Windows.Forms.ComboBox
$folderComboBox.text             = "comboBox"
$folderComboBox.width            = 200
$folderComboBox.height           = 20
$folderComboBox.location         = New-Object System.Drawing.Point(105,400)
$folderComboBox.Font             = 'Microsoft Sans Serif,10'
$folderComboBox.DropDownStyle    = "DropDownList"

# - Creates Gridview Status Window
$DataGridView1                   = New-Object system.Windows.Forms.DataGridView
$DataGridView1.width             = 365 
$DataGridView1.height            = 104 
$DataGridView1.ColumnCount       = 1
$DataGridView1.ColumnHeadersVisible = $true
$DataGridView1.Columns[0].Name      = "Validation"
$DataGridView1.location             = New-Object System.Drawing.Point(17,660)
$DataGridView1.AutoSizeColumnsMode  = "Fill"
$DataGridView1.ReadOnly             = $true
$DataGridView1.AllowUserToAddRows   = $false
$DataGridView1.AllowUserToDeleteRows= $false

$Form.controls.AddRange(@(
    $Label1,
    $label117,
    $label118,
    $Label2,
    $Label3,
    $Label4,
    $Label5,
    $Label6,
    $Label7,
    $Label8,
    $Label9,
    $Label10,
    $Label11,
    $Label12,
    $Label13,
    $Label14,
    $Label15,
    $Label16,
    $deployButton,
    $ProgressBar,
    $vcentertextbox,
    $usernametextbox,
    $passwordtextbox,
    $domainButton,
    $vmnameTextBox,
    $clusterComboBox,
    $datastoreComboBox,
    $datastoreButton,
    $portgroupComboBox,
    $cpuComboBox,
    $memoryComboBox,
    $disk1ComboBox,
    $disk2TextBox,
    $disk3TextBox,
    $disk4TextBox,
    $ipTextBox,
    $netmaskTextBox,
    $gatewayTextBox,
    $dns1TextBox,
    $Label17,
    $templateComboBox,
    $Label18,
    $customspecComboBox,
    $Label19,
    $domainComboBox,
    $dns2TextBox,
    $connectButton,
    $Label20,
    $folderComboBox,
    $DataGridView1,
    $connectStatus
))

# - Allows Enter To Be Pressed To Connect
$form.AcceptButton = $connectButton

# - Assigned Button Actions
$connectButton.Add_Click({ConnectButton})
$DeployButton.Add_Click({Validate-Form})
$datastoreButton.Add_Click({datastoreButton})
$domainButton.Add_Click({domainButton})

# - Lock Form
Lock-Form

# - Action For When GUI Is Closed
$Form.add_FormClosing({Close-Form})

# - Show Form
$Form.ShowDialog()
}

Function Show-WarningForm {
<#
.Description
    This form pops up if the soft resource thresholds are met.
    The operator can choose to ignore them by clicking "Proceed" or go back to the deployment form by clicking "Abort".
    When a button is clicked, the global variable $global:Proceed is populated for use by the "Validate-Form" Function.
#>
param($Warning)
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$WarningForm                     = New-Object system.Windows.Forms.Form
$WarningForm.ClientSize          = '456,332'
$WarningForm.text                = "Resources Warnings /!\"
$WarningForm.TopMost             = $false
$WarningForm.MaximizeBox         = $false
$WarningForm.FormBorderStyle     = 'Fixed3D'
$WarningDataGridView             = New-Object system.Windows.Forms.DataGridView
$WarningDataGridView.width       = 421
$WarningDataGridView.height      = 224
$WarningDataGridView.location    = New-Object System.Drawing.Point(16,37)
$WarningDataGridView.ColumnCount = 1
$WarningDataGridView.ColumnHeadersVisible = $true
$WarningDataGridView.Columns[0].Name = "Warnings"
$WarningDataGridView.AutoSizeColumnsMode = "Fill"
$WarningDataGridView.ReadOnly = $true
$Proceedbutton                    = New-Object system.Windows.Forms.Button
$Proceedbutton.text               = "Proceed"
$Proceedbutton.width              = 122
$Proceedbutton.height             = 40
$Proceedbutton.location           = New-Object System.Drawing.Point(316,277)
$Proceedbutton.Font               = 'Microsoft Sans Serif,10'
$AbortButton                     = New-Object system.Windows.Forms.Button
$AbortButton.text                = "Abort"
$AbortButton.width               = 122
$AbortButton.height              = 40
$AbortButton.location            = New-Object System.Drawing.Point(17,277)
$AbortButton.Font                = 'Microsoft Sans Serif,10'
$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Consider the following warnings before proceeding to the deployment."
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(17,12)
$Label1.Font                     = 'Microsoft Sans Serif,10'
$WarningForm.controls.AddRange(@(
    $WarningDataGridView,
    $Proceedbutton,
    $AbortButton,
    $Label1
))

# Configure buttons
$global:Proceed = "Aborted"
$AbortButton.Add_Click({$WarningForm.Close()})
$Proceedbutton.Add_Click({$global:Proceed = "OK"; $WarningForm.Close()})

# Clear Warning table
$WarningDataGridView.Rows.Clear()

# Populate Warning table
$Warning | ForEach-Object {$WarningDataGridView.Rows.Add("! $_")}

# Display Warning form
$WarningForm.ShowDialog()
}
Function Show-AttributesForm {
<#
.Description
    This form pops up before the deployment of the VM to specify the custom attributes to apply.
    The attributes table is fed using the vCenter attributes of Type VM and Null.
    The operator can populate the second column with the attributes' values.
    At the end the global variable $Global:CustomAttributes is populated with a table that replicates 
    the one filled by the operator for use by the "Deploy-VM" function at the end of the script.
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$AttributesForm                     = New-Object system.Windows.Forms.Form
$AttributesForm.ClientSize          = '650,332' 
$AttributesForm.text                = "Custom Attributes"
$AttributesForm.TopMost             = $false
$AttributesForm.MaximizeBox         = $false
$AttributesForm.FormBorderStyle     = 'Fixed3D'
$AttributesDataGridView             = New-Object system.Windows.Forms.DataGridView
$AttributesDataGridView.width       = 615
$AttributesDataGridView.height      = 224
$AttributesDataGridView.location    = New-Object System.Drawing.Point(16,37) 
$AttributesDataGridView.AutoSizeColumnsMode = "Fill"
$AttributesDataGridView.AllowUserToAddRows = $false
$AttributesDataGridView.AllowUserToDeleteRows = $false

# Create table columns
$AttributesDataGridView.ColumnCount = 2
$AttributesDataGridView.ColumnHeadersVisible = $true
$AttributesDataGridView.Columns[0].Name = "Attribute"
$AttributesDataGridView.Columns[0].ReadOnly = $true
$AttributesDataGridView.Columns[1].Name = "Value"
$Attributesbutton                    = New-Object system.Windows.Forms.Button
$Attributesbutton.text               = "Proceed"
$Attributesbutton.width              = 122
$Attributesbutton.height             = 40
$Attributesbutton.location           = New-Object System.Drawing.Point(500,277)
$Attributesbutton.Font               = 'Microsoft Sans Serif,10'
$AttributesForm.controls.AddRange(@($AttributesDataGridView,$Attributesbutton))

# Actions On Proceed Button Click
$Attributesbutton.Add_Click({
    
    # Initialize variable table.
    $Global:CustomAttributes = @()
   
    # Loop through records of the grid table.
    for ($i=0 ; $i -lt $AttributesDataGridView.RowCount ; $i++) {
       
    # Add grid table record to variable.
        $Global:CustomAttributes+= @{
        $AttributesDataGridView.Rows[$i].Cells["Attribute"].Value = $AttributesDataGridView.Rows[$i].Cells["Value"].Value
        }
    }
    $AttributesForm.Close()
})
$AttributesDataGridView.Rows.Clear()

# Gather list of attributes applicable to VMs without the need of a VM object
$custom = get-view $DefaultVIServer.ExtensionData.content.CustomFieldsManager
$customFields = $custom.field | where {$_.ManagedObjectType -eq "virtualmachine" -or !$_.ManagedObjectType}
if ($customFields) {
    $customFields | ForEach-Object {$AttributesDataGridView.Rows.Add($_.Name,"")}
    $AttributesForm.ShowDialog()
}
}

# Button Functions
Function ConnectButton {
<#
.Description
    If A Successful vCenter Connection Occurs:
        - Enables Disabled Fields
        - Disable the vCenter fields
#>
Connect-VIServer -Server $vcenterTextBox.Text -Username $usernametextbox.Text -Password $passwordtextbox.Text
    if ($DefaultVIServer.name -eq $vcenterTextBox.Text) {
        
        # Disable connect fields
        $connectButton.Enabled      = $true
        $connectButton.Text         = "Connected"
        $connectStatus.ForeColor    = "Green"
        $connectStatus.Text         = "Connected"
        $vcenterTextBox.Enabled     = $false
        $usernametextbox.Enabled    = $false
        $passwordtextbox.Enabled    = $false
        
        # Enable fields
        $deployButton.Enabled       = $true
        $vmnameTextBox.Enabled      = $true
        $clusterComboBox.Enabled    = $true
        $templateComboBox.Enabled   = $true
        $customspecComboBox.Enabled = $true
        $domainComboBox.Enabled     = $true
        $folderComboBox.Enabled     = $true
        $cpuComboBox.enabled        = $true
        $memoryComboBox.enabled     = $true
        $disk2TextBox.enabled       = $true
        $disk3TextBox.enabled       = $true
        $disk4TextBox.enabled       = $true
        $ipTextBox.enabled          = $true
        $netmaskTextBox.enabled     = $true
        $gatewayTextBox.enabled     = $true
        $dns1TextBox.enabled        = $true
        $dns2TextBox.enabled        = $true
        
        # Process clusters
        $Clusters = Get-Cluster
        $clusterComboBox.Items.Clear()
        $Clusters.Name | Sort  | ForEach-Object {[void] $clusterComboBox.Items.Add($_)}
        
        <# 
            Process Templates
            Searches for VMs that are only set as templates and have Win10 OS
        #>
        $Templates = Get-Template |  Where {$_.ExtensionData.Summary.Guest.GuestFullName -like "*Windows 10*"}
        $templateComboBox.Items.Clear()
        $Templates.Name | Sort  | ForEach-Object {[void] $templateComboBox.Items.Add($_)}
        
        # Process Custom specs
        $CustomSpec = Get-OSCustomizationSpec
        $customspecComboBox.Items.Clear()
        $CustomSpec.Name | Sort  | ForEach-Object {[void] $customspecComboBox.Items.Add($_)}
        
        <# 
            Process Folders
            Shows Folders that aren't named 'Templates'
        #>
        $Folderss = Get-Datacenter | Get-Folder | ? {$_.Type -match "VM"} | ? {$_.Parent -notmatch "vm"} | ? {$_.Name -notmatch "Templates"}
        $folderComboBox.Items.Clear()
        
 <# - List Folders By Parent & Child
        This Is Done Because We Use Duplicate Folder Names, and Power CLI Cannot 
        Distinguish Exactly Which Folder To Move the VM To. So This Was Added To Show 
        The the Parent Folder And Child Folders

        This is probably a trash way to to do it, I'm sure there is a better way but I
        Really don't feel like looking for a better one since this one works for now.
 #>     
  Foreach ($Folder in $Folderss){
	 $Folders1 = $Folder.Parent 
     $Folders2 = $Folder.Name
     $Folders = "$Folders1"+" - "+"$Folders2"
     $Folders |ForEach-Object {[void] $folderComboBox.Items.Add($_)}
     
     #Prob Need to Remove This Global Call
     $Global:Flddr = $folderComboBox.SelectedItem
  }
    } else {
        $connectButton.text = "Retry"  
    }
}

Function datastoreButton {
<#
.Description
    This button displays a table with advanced information about datastores (provisioned, free, used ...) 
    using the "Get-DatastoreList" Function. If the operator selects a datastore and presses enter 
    or clicks "OK" the datastore is selected in the form.

    You'll need to fill in the Datastore info if you have Datastores that you don't want VMs to use or
    you can just comment out the current DSSelect block of code and uncomment the other one and it will
    list all Datastores.
#>
$DSSelect = Get-DatastoreList (Get-Cluster $clusterComboBox.text | Get-Datastore | 
Where {($_.Name -like "*Datastore1*") -or 
($_.Name -Like "*Datastore2*") -or 
($_.Name -Like "*Datastore3*")} | Sort | where accessible) | Out-GridView -PassThru
#$DSSelect = Get-DatastoreList (Get-Cluster $clusterComboBox.text | Get-Datastore | Sort | where accessible) | Out-GridView -PassThru
$datastoreComboBox.text = $DSSelect.name
}

Function domainButton {
<#
.Description
    This button opens a credentials box for the domain credentials for joining the VM
    to the selected domain.
#>
$Global:DomainCredentials = Get-Credential -Message $domainComboBox.text
}

### FORM ACTIONS
Function Close-Form {
<#
.Description
    This function is used to disconnect vCenter if the top right red cross is clicked.
#>
if ($DefaultVIServer) {Disconnect-VIServer -Confirm:$false}
}
Function Lock-Form {
param([switch]$Unlock = $false)
<#
.Description
    This Function locks most fields when the script starts.
    Used for flexibility purpose. Keeps people from trying
    to deploy a VM before being connected to vCenter.
#>
    $deployButton.enabled        = $Unlock
    $vmnameTextBox.enabled       = $Unlock
    $clusterComboBox.enabled     = $Unlock
    $datastoreComboBox.enabled   = $Unlock
    $datastoreButton.Enabled     = $Unlock
    $portgroupComboBox.enabled   = $Unlock
    $templateComboBox.enabled    = $Unlock
    $customspecComboBox.enabled  = $Unlock
    $domainComboBox.enabled      = $Unlock
    $domainButton.Enabled        = $Unlock
    $folderComboBox.enabled      = $Unlock
    $cpuComboBox.enabled         = $Unlock
    $memoryComboBox.enabled      = $Unlock
    $disk1ComboBox.enabled       = $Unlock
    $disk2TextBox.enabled        = $Unlock
    $disk3TextBox.enabled        = $Unlock
    $disk4TextBox.enabled        = $Unlock
    $ipTextBox.enabled           = $Unlock
    $netmaskTextBox.enabled      = $Unlock
    $gatewayTextBox.enabled      = $Unlock
    $dns1TextBox.enabled         = $Unlock
    $dns2TextBox.enabled         = $Unlock
    
}

<# GetFolderByPath Function
     Created by LucD on the VMware Forums
#>
function Get-FolderByPath{
    <#
    .SYNOPSIS Retrieve folders by giving a path
    .DESCRIPTION The function will retrieve a folder by it's path.
    The path can contain any type of leave (folder or datacenter).
    .NOTES
    Author: Luc Dekens .PARAMETER Path The path to the folder. This is a required parameter.
    .PARAMETER
    Path The path to the folder. This is a required parameter.
    .PARAMETER
    Separator The character that is used to separate the leaves in the path. The default is '/'
    .EXAMPLE
    PS> Get-FolderByPath -Path "Folder1/Datacenter/Folder2"
    .EXAMPLE
    PS> Get-FolderByPath -Path "Folder1>Folder2" -Separator '>'
    #>
    #$DCC = Get-Datacenter
    param(
    [CmdletBinding()]
    [parameter(Mandatory = $true)]
    [System.String[]]${Path},
    [char]${Separator} = '/'
    )
    process{
    if((Get-PowerCLIConfiguration).DefaultVIServerMode -eq "Multiple"){
    $vcs = $global:defaultVIServers
    }
    else{
    $vcs = $global:defaultVIServers[0]
    }
    $folders = @()
    foreach($vc in $vcs){
    $si = Get-View ServiceInstance -Server $vc
    $rootName = (Get-View -Id $si.Content.RootFolder -Property Name).Name
    foreach($strPath in $Path){
    $root = Get-Folder -Name $rootName -Server $vc -ErrorAction SilentlyContinue
    $strPath.Split($Separator) | %{
    $root = Get-Inventory -Name $_ -Location $root -NoRecursion -Server $vc -ErrorAction SilentlyContinue
    if((Get-Inventory -Location $root -NoRecursion | Select -ExpandProperty Name) -contains "vm"){
    $root = Get-Inventory -Name "vm" -Location $root -Server $vc -NoRecursion
    }
    }
    $root | where {$_ -is [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl]}|%{
    $folders += Get-Folder -Name $_.Name -Location $root.Parent -NoRecursion -Server $vc
    }
    }
    }
    $folders
    }
    }
  
Function Change-Cluster {
 <#
.Description
    This Function Updates some fields (datastore, portgroup) when the selected cluster is changed.
#>
    $Cluster = Get-Cluster $clusterComboBox.text
    
    # Enable datastore and portgroup buttons
    $datastoreComboBox.Enabled = $true
    $datastoreButton.Enabled   = $true
    $portgroupComboBox.Enabled = $true
    
    # Process datastores - Remove Datastore From List That We Don't Use
    #Need to Update the Datastores that you want to be listed.
    $DatastoreList = $Cluster | Get-Datastore | Where {($_.Name -like "*Datastore1*") -or ($_.Name -Like "*Datastore2*") -or ($_.Name -Like "*Datastore3*")} | Sort | where accessible
    $datastoreComboBox.Items.Clear()
    $DatastoreList | select -ExpandProperty name | Sort  | ForEach-Object {[void] $datastoreComboBox.Items.Add($_)}
    
    # Process port groups
    $PortgroupList = $cluster | Get-VMHost | Get-VirtualPortGroup | select -Unique
    $portgroupComboBox.Items.Clear()
    
    $PortgroupList.Name | Sort | ForEach-Object {[void] $portgroupComboBox.Items.Add($_)}
}

Function Change-Template {
<#
.Description
    This Function Updates the authorized disk 1 size when the selected template is changed to avoid the operator shrinking the disk.
#>
    $Template  = Get-Template $templateComboBox.Text

    # Process disk
    $FirstDisk = $Template | Get-HardDisk -Name "Hard disk 1"
    $disk1ComboBox.Items.Clear()
    # Need To Change The Disk Sizes Allows For HD 1
    $DiskSizesAuthorized = $DiskSizes 
    $DiskSizesAuthorized += $FirstDisk.capacityGB
    $DiskSizesAuthorized | Sort | ForEach-Object {[void] $disk1ComboBox.Items.Add($_)}
    $disk1ComboBox.enabled = $true
}

Function Change-CustomSpec {
if ( (Get-OSCustomizationSpec -Name $customspecComboBox.text).OSType -eq "Linux" ) { $domainButton.Enabled = $false } else { $domainButton.Enabled = $True }
}

# - Utility Functions
Function Get-DatastoreList {
<#
.Description
    This Function provides the advanced information about datastores to the datastore button.
#>
param ($DatastoreList)
foreach ($ds in $DatastoreList) {
    
    # Basic Datastore logic
    $CapacityGB    = [Math]::Round(($ds.extensiondata.summary.capacity   / 1GB),2)
    $FreeGB        = [Math]::Round(($ds.extensiondata.summary.FreeSpace  / 1GB),2)
    $UsedGB        = [Math]::Round((($ds.extensiondata.summary.capacity  / 1GB) - ($ds.extensiondata.summary.FreeSpace / 1GB)),2)
    $ProvisionedGB = [Math]::Round((($ds.extensiondata.summary.capacity  / 1GB) - ($ds.extensiondata.summary.FreeSpace / 1GB) + ($ds.extensiondata.summary.Uncommitted / 1GB)),2)
    $ProvisionedPercent = [Math]::Round($ProvisionedGB / $CapacityGB * 100,1)
    # Information returned about datastores
    [pscustomobject]@{
        Name          = $ds.name
        Accessible    = $ds.Accessible
        CapacityGB    = $CapacityGB
        FreeSpaceGB   = $FreeGB
        FreeSpace     = "$([math]::round($FreeGB / $CapacityGB * 100,1))%"
        UsedSpaceGB   = $UsedGB
        ProvisionedGB = $ProvisionedGB
        Provisioned   = "$ProvisionedPercent%"
    }
}
}

Function Get-LongestString {
<#
.Description
    This Function returns the length of the longest string in a collection.
    This can be used to extend the width of a box.
    
    * Not used at the moment.
#>

param([string[]]$Strings)
($Strings | select -ExpandProperty length | sort | select -last 1) * 7
}

Function Set-ProgressBar {
param($Description, $Value)
$DataGridView1.Rows.Clear()
$DataGridView1.Rows.Add($vmnameTextBox.text + " : " + $Description)
$ProgressBar.Value = $Value
}

Function Validate-Form {
<#
.Description
    Triggered by the "Deploy" button and contains all the logic to validate the deployments:
        - Check required fields are populated
        - Check for enough compute and storage resources
        - Display problems in the bottom grid table
        - Open the Warning form in case of soft thresholds met
        - Start the deployment
#>

$DCC = Get-Datacenter
# Empty the bottom grid table.
$DataGridView1.Rows.Clear()
# Initialize the soft and hard thresholds tables.
$Issues = @()
$Warning = @()

#  Check if all fields are populated
if (!$vmnameTextBox.text) {$Issues += "Specify a VM name"}
    elseif (Get-VM $vmnameTextBox.Text -ErrorAction SilentlyContinue) {$Issues += "$($vmnameTextBox.Text) already in use"}

if (!$clusterComboBox.text) {$Issues += "Specify a valid cluster"}
    elseif (! ($Cluster = Get-cluster $clusterComboBox.text) ) {$Issues += "Specify a valid cluster"}

if (!$portgroupComboBox.text) {$Issues += "Specify a valid port group"}
    elseif (! ($cluster | Get-VMHost | Get-VirtualPortGroup -Name $portgroupComboBox.text) ) {$Issues += "Specify a valid port group"}

if (!$templateComboBox.text) {$Issues += "Specify a valid template"}
    elseif (! (Get-template $templateComboBox.text) ) {$Issues += "Specify a valid template"}

if (!$customspecComboBox.text) {$Issues += "Specify a valid custom spec"}
    elseif (! ($customspec = Get-OSCustomizationSpec $customspecComboBox.text) ) {$Issues += "Specify a valid custom spec"}


$FldrCmboBox = $($folderComboBox.Text) -Replace " - ","/"
if (!$FldrCmboBox ) {$Issues +="1- Specify Correct VM Folder"}
    elseif (! ($FldrCmboBox = Get-FolderByPath -Path $DCC/$FldrCmboBox) ) {$Issues += "2- Specify Correct VM Folder"}
        elseif ($FldrCmboBox.count -gt 1) {$Issues += "$($FldrCmboBox.count) folders with name $($FldrCmboBox)"}

if ( !$disk1ComboBox.text ) {$Issues += "Specify size for the base disk"}

if (! ($ipTextBox.text -and $netmaskTextBox.text -and $gatewayTextBox.text -and $dns1TextBox.text -and $domainComboBox.text) ) {$Issues += "Specify minimum Network settings (Domain, IP, Netmask, Gateway, 1 DNS)"}
    elseif (! ($ipTextBox.text -like "*.*.*.*" -and 
        $netmaskTextBox.text -like "*.*.*.*" -and 
        $gatewayTextBox.text -like "*.*.*.*" -and 
        $dns1TextBox.text -like "*.*.*.*") -or 
        ($dns2TextBox.text -and !($dns2TextBox.text -like "*.*.*.*")) ) 
    {$Issues += "Provide valid IP addresses"}
    elseif (! ($ipTextBox.text -as [ipaddress] -and 
        $netmaskTextBox.text -as [ipaddress] -and 
        $gatewayTextBox.text -as [ipaddress] -and 
        $dns1TextBox.text -as [ipaddress]) -or 
        ($dns2TextBox.text -and !($dns2TextBox.text -as [ipaddress])) ) 
    {$Issues += "Provide valid IP addresses"}
if ($domainComboBox.text -ne "No-Domain" -and !$DomainCredentials -and $customspec.ostype -eq "Windows") {$Issues += "Specify credentials for $($domainComboBox.text)"}
if ($domainComboBox.text -eq "No-Domain" -and $customspec.ostype -eq "Linux") {$Issues += "Specify a domain is mandatory for Linux deployment"}

# Validating resources
$ClusterHosts = $cluster | get-vmhost

# Storage - Check for free and provisioned space.
if (!$datastoreComboBox.text) {$Issues += "Specify a valid datastore"}
    elseif (! ($datastore = Get-Datastore $datastoreComboBox.text) ) {$Issues += "Specify a valid datastore"}
else {
    $VMDiskSize = [int]$disk1ComboBox.text + [int]$disk2TextBox.text + [int]$disk3TextBox.text + [int]$disk4TextBox.text + [int]$memoryComboBox.text
    $DSInfo = Get-DatastoreList -DatastoreList $datastore
    
    # Freespace
    $DSFreeSpaceAfter = $DSInfo.FreeSpaceGB - $VMDiskSize
    $DSFreeSpaceAfter = [math]::round($DSFreeSpaceAfter/$DSInfo.CapacityGB*100,1)
if ($DSFreeSpaceAfter -lt $DSMinFreeSpacePercent)         {$Issues  += "Datastore free space with VM disk: $DSFreeSpaceAfter% (Hard threshold: $DSMinFreeSpacePercent%)"}
    elseif ($DSFreeSpaceAfter -lt $DSWarningFreeSpacePercent) {$Warning += "Datastore free space with VM disk: $DSFreeSpaceAfter% (Soft threshold: $DSWarningFreeSpacePercent%)"}
    
    #Provisionedspace
    $DSProvSpaceAfter = $DSInfo.ProvisionedGB + $VMDiskSize
    $DSProvSpaceAfter = [math]::round($DSProvSpaceAfter/$DSInfo.CapacityGB*100,1)
if ($DSProvSpaceAfter -gt $DSMaxProvisionedPercent)         {$Issues  += "Datastore provisioned space with VM disk: $DSProvSpaceAfter% (Hard threshold: $DSMaxProvisionedPercent%)"}
    elseif ($DSProvSpaceAfter -gt $DSWarningProvisionedPercent) {$Warning += "Datastore provisioned space with VM disk: $DSProvSpaceAfter% (Soft threshold: $DSWarningProvisionedPercent%)"}
}

# Memory - Check for enough memory in the cluster.
if (! ($memoryComboBox.text) ) {$Issues += "Specify memory requirements"}
else {
    $ClusterMemoryGBTotal = $ClusterHosts | Measure-Object -Property MemoryTotalGB -Sum | select -ExpandProperty sum
    $ClusterMemoryGBUsed  = $ClusterHosts | Measure-Object -Property MemoryUsageGB -Sum | select -ExpandProperty sum
    $ClusterMemoryUsedPercentAfter = [math]::round(($ClusterMemoryGBUsed + [int]$memoryComboBox.text)/$ClusterMemoryGBTotal*100,1)
if ($ClusterMemoryUsedPercentAfter -gt $MemMaxusedPercent)         {$Issues  += "Cluster Memory usage with VM: $ClusterMemoryUsedPercentAfter % (Hard threshold: $MemMaxusedPercent %)"}
    elseif ($ClusterMemoryUsedPercentAfter -gt $MemWarningusedPercent) {$Warning += "Cluster Memory usage with VM: $ClusterMemoryUsedPercentAfter % (Soft threshold: $MemWarningusedPercent %)"}
}

# CPU - Check the current CPU usage in the cluster.
if (! ($cpuComboBox.text) ) {$Issues += "Specify CPU requirements"}
    else {
    $ClusterCPUUsed = $ClusterHosts | Measure-Object -Property CpuUsageMhz -Sum | select -ExpandProperty sum
    $ClusterCPUTotal = $ClusterHosts | Measure-Object -Property CpuTotalMhz -Sum | select -ExpandProperty sum
    $ClusterCPUUsedPercent = [math]::round($ClusterCPUUsed/$ClusterCPUTotal*100,1)
if ($ClusterCPUUsedPercent -gt $CpuMaxusedPercent)         {$Issues  += "Cluster CPU usage with VM: $ClusterCPUUsedPercent% (Hard threshold: $CpuMaxusedPercent%)"}
    elseif ($ClusterCPUUsedPercent -gt $CpuWarningusedPercent) {$Warning += "Cluster CPU usage with VM: $ClusterCPUUsedPercent% (Soft threshold: $CpuWarningusedPercent%)"}
}

# Validation outcome
# Hard threshold - Deployment not authorized.
if ($Issues) {   
    $Issues | ForEach-Object {$DataGridView1.Rows.Add("! $_")}

# Soft threshold - Deployment if warning form overridden.
} elseif ($Warning) {  
    # Open warning form - which populates the $Proceed variable.
    Show-WarningForm -Warning $Warning
    $DataGridView1.Rows.Add($global:Proceed)
if ($Global:Proceed -eq "ok") {
    Show-AttributesForm
    
    Deploy-VM
    }
# Deployment authorized.
} else {
    $DataGridView1.Rows.Add("Deploying")
    Show-AttributesForm
    
    Deploy-VM
}
}

Function Write-DeployLog {
param ($DeploymentLog)
[pscustomobject]@{
    Name = $vmnameTextBox.Text
    DeployedBy = $env:USERNAME
    Date = get-date -Format u
    vCenter = $vcentertextbox.Text
    Username = $usernametextbox.Text
    Password = $passwordtextbox.Text
    Cluster = $clusterComboBox.Text
    Portgroup = $portgroupComboBox.Text
    Domain = $domainComboBox.Text
    CPU = $cpuComboBox.Text
    Memory = $memoryComboBox.Text
    Disk = "$($disk1ComboBox.Text,$disk2TextBox.Text,$disk3TextBox.Text,$disk4TextBox.Text | Measure-Object -Sum | select -ExpandProperty sum) GB"
    IP = $ipTextBox.Text
    Mask = $netmaskTextBox.Text
    GW = $gatewayTextBox.Text
    DNS1 = $dns1TextBox.Text
    DNS2 = $dns2TextBox.Text
    } 
}

# Deploy VM
Function Deploy-VM {
<#
.Description
    This Function is triggered by the "Validate-Form" Function when the deployment is authorized. It runs the commands that will deploy the VM.
#>

Lock-Form
$DataGridView1.Columns[0].Name = "Progress"
TRY {
    # Cloning existing custom specs to a peristent one with a unique ID as name.
    Set-ProgressBar -Description "Preparing customization" -Value 2
    $CustomSpec = New-OSCustomizationSpec -OSCustomizationSpec $customspecComboBox.Text -Name ([guid]::NewGuid().guid) -Type Persistent
    
    # Set domain info common to Windows and Linux.
    if ($domainComboBox.text -ne "No-Domain") {
    if ($customspec.ostype -eq "Windows") {$CustomSpec = $CustomSpec | Set-OSCustomizationSpec -Domain $domainComboBox.text -DomainCredentials $DomainCredentials}
        else {$CustomSpec = $CustomSpec | Set-OSCustomizationSpec -Domain $domainComboBox.text}
    } 
        elseif ($customspec.ostype -eq "Windows") {$CustomSpec = $CustomSpec | Set-OSCustomizationSpec -Workgroup "WORKGROUP"}
    
    # Prepare the DNS servers to use whether 1 or 2 are specified.
    if ($dns2TextBox.Text) {$DNS = $dns1TextBox.Text,$dns2TextBox.Text} else {$DNS = $dns1TextBox.Text}
    
    # Prepare the custom spec specific to Linux.
    if ($CustomSpec.OSType -eq "Linux")   {$CustomSpec | Set-OSCustomizationSpec -DnsServer $DNS}
    
    # Prepare the custom spec Common to Windows and Linux.
    $OSCustomizationNicMappingParams = @{IpMode = 'UseStaticIP' ; IpAddress = $ipTextBox.Text ; SubnetMask = $netmaskTextBox.Text ; DefaultGateway = $gatewayTextBox.Text}
    
    # Prepare the NIC custom spec specific to Windows.
    if ($CustomSpec.OSType -eq "Windows") {$OSCustomizationNicMappingParams.Add('Dns',$DNS)}
    
    # Process the custom specs to use.
    $CustomSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping @OSCustomizationNicMappingParams
    
    # Deploying the VM.
    $NewVMTask = New-VM -Template $templateComboBox.Text -OSCustomizationSpec $CustomSpec -ResourcePool $cluster -Datastore $datastoreComboBox.Text -DiskStorageFormat Thin -Name $vmnameTextBox.Text -RunAsync
    Set-ProgressBar -Description $NewVMTask.description -Value $ProgressBar.Value
    while ( $TaskStatus.State -ne "Success" ) {
        $TaskStatus = get-task -Id $NewVMTask.id
        Set-ProgressBar -Description $NewVMTask.description -Value ( ($TaskStatus.PercentComplete * 0.8) + 2 )
        sleep -Milliseconds 500
    }
    $NewVM = get-vm -id $NewVMTask.ExtensionData.Info.result
    
    # Connecting the correct portgroup.
    Set-ProgressBar -Description "Configuring portgroup" -Value 82
    $NewVM | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected $true -Confirm:$false -NetworkName $portgroupComboBox.Text
    
    # VM CPU and memory settings.
    Set-ProgressBar -Description "Configuring resources" -Value 85
    $NewVM | Set-VM -MemoryGB $memoryComboBox.text -NumCpu $cpuComboBox.text -Confirm:$false
    
    # Processing disks.
    Set-ProgressBar -Description "Configuring virtual disks" -Value 88
    $HardDisk1 = $NewVM | Get-HardDisk -Name "Hard Disk 1"
    
    # Edit disk 1 only if specified disk size is greated than existing one.
    if ($HardDisk1.capacityGB -lt [int]$disk1ComboBox.Text) {$HardDisk1 | Set-HardDisk -CapacityGB ([int]$disk1ComboBox.Text) -Confirm:$false}
    if ([int]$disk2TextBox.text -gt 0) { New-HardDisk -CapacityGB $disk2TextBox.text -DiskType Flat -ThinProvisioned -VM $NewVM }
    if ([int]$disk3TextBox.text -gt 0) { New-HardDisk -CapacityGB $disk3TextBox.text -DiskType Flat -ThinProvisioned -VM $NewVM }
    if ([int]$disk4TextBox.text -gt 0) { New-HardDisk -CapacityGB $disk4TextBox.text -DiskType Flat -ThinProvisioned -VM $NewVM }
    
    # Move VM to inventory folder.
    Set-ProgressBar -Description "Moving VM folder" -Value 93
    $strChg = $folderCombobox.text -replace " - ","/"
    $vmFldr = Get-FolderByPath -Path "$DCC/$strChg"
    write-host "vmFldr- " $vmFldr
    Write-host "DC/TextBox- " $DCC/$strChg
    Get-VM $NewVM | Move-VM -InventoryLocation $vmFldr -Confirm:$false
    
    # Starting the VM.
    Set-ProgressBar -Description "Starting VM" -Value 94
    $NewVM | Start-VM
    
    # Process custom attributes.
    Set-ProgressBar -Description "Setting custom attributes" -Value 98
    if ($CustomAttributes) { $CustomAttributes | ForEach-Object {Set-Annotation -Entity $NewVM -CustomAttribute ($_ | select -ExpandProperty keys) -Value ($_ | select -ExpandProperty values)} }
  
    # Refresh Datastore storage info
    (Get-Datastore $datastoreComboBox.Text).ExtensionData.RefreshDatastoreStorageInfo()
    Set-ProgressBar -Description "Deployment completed" -Value 0
   
    Write-DeployLog -DeploymentLog $DeploymentLog
} CATCH {
    
    Set-ProgressBar -Description $_.Exception -Value 0
    $DataGridView1.Rows.Clear()
    $DataGridView1.Rows.Add("Error : " + $_.Exception)
    
    
    Write-Error $_.Exception -ErrorAction Stop
} FINALLY {
    
    # Delete temporary custom specs.
    if ($CustomSpec) {$CustomSpec | Remove-OSCustomizationSpec -Confirm:$false}
    Lock-Form -Unlock
    $DataGridView1.Columns[0].Name = "Validation"
}
}
##

# Display GUI
Show-Form


