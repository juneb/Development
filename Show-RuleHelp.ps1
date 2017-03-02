<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.136
	 Created on:   	3/2/2017 2:46 PM
	 Created by:   	June Blender
	 Organization: 	SAPIEN Technologies, Inc
	 Filename:     	Show-RuleHelp.sp1
	===========================================================================
#>



<#
.SYNOPSIS
Opens rules help online

.DESCRIPTION
Show-RuleHelp displays online help for a PSScriptAnalyzer rule in the default internet browser.

.PARAMETER Name
Specifies the rule name. Enter a name string. Wildcards are not supported.

.EXAMPLE
PS C:\> Show-RuleHelp -Name PSMisleadingBacktick
#>
function Show-RuleHelp
{
	param
	(
		[Parameter(Mandatory = $true)]
		[String]
		$Name
	)
	
	if (Get-ScriptAnalyzerRule -Name $Name)
	{
		$URLName = $Name -replace "^PS", ""
		$URL = "https://github.com/PowerShell/PSScriptAnalyzer/blob/development/RuleDocumentation/$URLName.md"
		Start-Process $URL
	}
	else
	{
		"Invalid rule name: $Name"	
	}
}