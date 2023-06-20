<# 
	SFDX PROJECT INITIALIZATION

	This script will
		- Create an sfdx project
		- Connect it to an org
		- Pull the org's code
		- Initialize git and commit the code
		- Open the project in vscode

	A custom manifest can also be automatically generated from a template file. To do this: 
		- Create an XML manifest file with the desired structure. For the <version> value, use the string '##VERSION_NUMMBER##'
		- Set the environment variable 'SFDX_MANIFEST_TEMPLATE_PATH' to the path of the template file

	Example usage: 
		sfdx-init -d my-project -a myorg-prod
		sfdx-init -d my-project -a myorg-sandbox -sandbox
#>

param (
	[Parameter(Mandatory=$true, Position=0)]
	[Alias("d")]
	[string]$directory,

	[Parameter(Mandatory=$true, Position=1)]
	[Alias("a")]
	[string]$orgAlias,

	[Parameter(Mandatory=$false)]
	[switch]$sandbox,

	[Parameter(Mandatory=$false)]
	[Alias("r")]
	[switch]$redirect,
	[string]$redirectValue
)

try {
	$pathStart = $PWD.Path

	# Initialize project folder w/ manifest
	sfdx project generate -n $directory -x
	cd $directory

	# Ignore .ini files 
	Add-Content -Path "./.forceignore" -Value "`n`n# Custom `n*.ini"

	# Initialize git
	git init
	git add .
	git commit -m "init commit - empty project"

	# Connect to org
	$authCommand = "sfdx org login web -a orgAlias -s "
	if ($sandbox -and $redirect) {
		throw "Cannot specify both sandbox and redirect options"
	}
	if ($sandbox) {
		$authCommand += "-r https://test.salesforce.com "
	}
	if ($redirect) {
		$authCommand += "-r $redirectValue "
	}
	Invoke-Expression $authCommand

	# Create manifest from template
	$manifestPath = ""
	if (![String]::IsNullOrEmpty($env:SFDX_MANIFEST_TEMPLATE_PATH)) {
		$projectConfig = Get-Content -Path ".\sfdx-project.json" | ConvertFrom-Json
		$manifestTemplate = Get-Content -Path $env:SFDX_MANIFEST_TEMPLATE_PATH
		$manifestContent = $manifestTemplate -replace '##VERSION_NUMMBER##', $projectConfig.sourceApiVersion
		$manifestPath = ".\manifest\custom.xml"
		$manifestContent | Out-File -FilePath $manifestPath
		Write-Host "Custom manifest created."
	} else {
		$manifestPath = ".\manifest\package.xml"
		Write-Host "Skipping custom manifest. No manifest template found."
	}
	
	# Pull & commit code
	Write-Host "Pulling code from org..."
	sfdx project retrieve start -x $manifestPath
	Write-Host "Finished pulling code from org."
	git add .
	git commit -m "initial pull (via script)"

	# Open project in vscode
	code ./

} catch {
	Write-Host $_
	Write-Host "Stack Trace: $($_.Exception.StackTrace)"
}
cd $pathStart
Write-Host "Finished."