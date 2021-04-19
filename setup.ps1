# Simple installation script 
#
# This will enable one command installation of my configuration.
#
# This script should be run with elevated rights.

$tempPath="~\AppData\Local\Temp"
$repo="~\Documents\auto-tooling"
$appPath="~\AppData\Local\AutoTool"
New-Item -ItemType directory -Path $appPath -Force
New-Item -ItemType directory -Path $appPath\tasksCompleted -Force

function Mark-Complete {
	param (
		$taskName
	)

	New-Item -ItemType file -Path $appPath\tasksCompleted\$taskName
}

function Is-Complete {
	param (
		$taskName
	)

	if (Test-Path $appPath\tasksCompleted\$taskName) {
		return 0 
	} else {
		return 1 
	}
}

<#
# GitHub Access
#
# This will generate a generate a ssh key and direct the user to github. The
# user will then have to login to github and paste the generated key.
#>
$taskName = "gitconfig" 
if (Is-Complete $taskName) {
	#
	# Install OpenSSH
	$OpenSSHClient = Get-WindowsCapability -Online | ? Name -like "OpenSSH.Client*"
	Add-WindowsCapability -Online -Name $OpenSSHClient.Name

	# Configure OpenSSH
	$SSHAgentSvc = Get-Service -Name "ssh-agent"
	Set-Service -Name $SSHAgentSvc.Name -StartupType Automatic
	Start-Service -Name $SSHAgentSvc.Name

	# Generate SSH Key
	$githubEmail = Read-Host -Prompt "What is your GitHub Email"
	ssh-keygen -t ed25519 -C $githubEmail 
	ssh-add

	# Configure access on GitHub
	Get-Content -Path $HOME\.ssh\id_ed25519.pub | Set-Clipboard
	Start-Process "https://github.com/settings/ssh/new"
	Read-Host -Confirm "Enter when complete"

	# Configer Git to see ssh client
	# NOTE: Not sure if this needs to be done everytime
	$SSHPath = (Get-Command -Name "ssh.exe").Source
	[Environment]::SetEnvironmentVariable("GIT_SSH", $SSHPath, "User")
	
	Mark-Complete $taskName 
}


<# Chocolatey 
#>
$taskName = "chocolatey" 
if (Is-Complete $taskName) {

	Set-ExecutionPolicy Bypass -Scope Process -Force;
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
	iex ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"));

	Mark-Complete $taskName 
}

<# Git
#>
$taskName = "git" 
if (Is-Complete $taskName) {

	choco install git -y

	Mark-Complete $taskName 
}

git clone git@github.com:Liamdoult/auto-tooling.git $repo

<# Hypervisor
#>
$taskName = "Hypervisor" 
if (Is-Complete $taskName) {

	Add-WindowsFeature -Name RSAT-Hyper-V-Tools

	Mark-Complete $taskName 
}

<# Docker
#>
$taskName = "Docker" 
if (Is-Complete $taskName) {

	Install-Package -Name docker -ProviderName DockerMsftProvider

	Mark-Complete $taskName 
}

<# WSL2
#>
$taskName = "WSL2" 
if (Is-Complete $taskName) {

	# Enable wsl
	dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

	# Enable VM engine
	dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

	# Insatll linux Kernal
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Invoke-WebRequest -Uri "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -OutFile $tempPath\wsl_update.msi
	Install-Script $($tempPath + "\wsl_update.msi /quiet InstallAllUsers=0 PrependPath=1 Include_test=0")

	Start-Process "https://www.microsoft.com/store/productId/9n6svws3rx71"
	Read-Host -Confirm "Enter when complete"

	Mark-Complete $taskName 
}

<# Windows Terminal 
#>
$taskName = "windowsterminal" 
if (Is-Complete $taskName) {

	Start-Process "https://www.microsoft.com/store/productId/9N0DX20HK701"
	Read-Host -Confirm "Enter when complete"

	Mark-Complete $taskName 
}

<# PowerToys
#>
$taskName = "PowerToys" 
if (Is-Complete $taskName) {

	choco install powertoys -y

	Mark-Complete $taskName 
}

<# Python
#>

$taskName = "python" 
if (Is-Complete $taskName) {

	$pythonVersions = @("3.9.1")

	function Install-Python {
		param (
			$version
		)

		$tempPythonPath="$tempPath\python-$pythonVersion.exe"
		if (-not (Test-Path $tempPythonPath)) {
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
			Invoke-WebRequest -Uri "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion.exe" -OutFile $tempPythonPath 
		}
		Install-Script $($tempPythonPath + " /quiet InstallAllUsers=0 PrependPath=1 Include_test=0")
		pip install virtualenv

	}

	foreach ($version in $pythonVersions) {
		Install-Python -version $version
	}

	Mark-Complete $taskName 
}

<# Visual Studios 
#>
$taskName = "visualstudios" 
if (Is-Complete $taskName) {
	$title    = "VS SKU"
	$question = "Would you like Enterprise or Community version?"

	$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
	$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&Enterprise"))
	$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList "&Community"))

	$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
	if ($decision -eq 0) {
		$sku="enterprise"
	} else {
		$sku="community"
	}

	choco install visualstudio2019$sku --add "Microsoft.VisualStudio.Workload.NativeDesktop;Microsoft.VisualStudio.Workload.NativeCrossPlat;Microsoft.VisualStudio.Workload.Azure;" --includeRecommended -y

	# TODO Link MS build to Vim LSP/Omnisharp-roslyn

	Mark-Complete $taskName 
}

<# Vim
#>
$taskName = "vim" 
if (Is-Complete $taskName) {

	choco install neovim -y

	# Link config
	New-Item -ItemType SymbolicLink -Path "~\AppData\Local\nvim\init.vim" -Target $repo\configs\vim.vim

	# Install vimplug
	iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |` ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force
	
	# Install plugins
	nvim +PluginInstall +qall

	Mark-Complete $taskName 
}

<# PowerShell 
#>
$taskName = "powershell" 
if (Is-Complete $taskName) {

	# Link config
	New-Item -ItemType SymbolicLink -Path $PROFILE -Target $repo\configs\PS.ps1

	Mark-Complete $taskName 
}

# Restart-Computer –Force
