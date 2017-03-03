<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.136
	 Created on:   	3/2/2017 3:51 PM
	 Created by:   	June Blender
	 Organization: 	SAPIEN Technologies, Inc
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

#Requires -Module @{ModuleName = 'PSScriptAnalyzer'; RequiredVersion = '1.11.0'}
. .\Get-RuleHelp.ps1


$rules = (Get-ScriptAnalyzerRule).RuleName
foreach ($rule in $rules)
{
	$URLName = $rule -replace "^PS", ""
	$URL = "https://github.com/PowerShell/PSScriptAnalyzer/blob/development/RuleDocumentation/$URLName.md"
	
	try
	{
		$null = Invoke-WebRequest $url -DisableKeepAlive -UseBasicParsing -Method head
	}
	catch [System.Net.WebException]
	{
		if ($_.Exception -like "*404*")
		{
			"Failed: $rule"
		}
		else
		{
			Write-Error "Cannot connect to Script Analyzer online."
		}
	}
}

