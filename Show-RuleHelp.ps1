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
Opens rule help online.

.DESCRIPTION
Show-RuleHelp displays online help for a PSScriptAnalyzer rule in the default internet browser.

The online help is in the GitHub repo for the PSScriptAnalyzer project:  https://github.com/PowerShell/PSScriptAnalyzer/blob/development/RuleDocumentation

The function generates an error if the rule name is invalid, no help exists for the rule, or the function cannot connect to the site.

.PARAMETER Name
Specifies the rule name. Enter a name or name pattern. You can also pipe rule names to Show-RuleHelp, such as from Get-ScriptAnalyzer rule.

If the pattern matches multiple rule names, Show-RuleHelp opens a browser window for each help topic. 

.EXAMPLE 
PS C:\> Show-RuleHelp -Name PSMisleadingBacktick

.EXAMPLE
PS C:\> Get-ScriptAnalyzerRule -Name PSMisleadingBacktick | Show-RuleHelp

.EXAMPLE
PS C:\> Show-RuleHelp -Name *Backtick*

.INPUTS
System.String, Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.RuleInfo
#>
function Show-RuleHelp
{
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true)]
		[SupportsWildcards()]
		[ValidateNotNullOrEmpty()]
		[String]
		$Name
	)
	
	BEGIN
	{
	}
	PROCESS
	{
		# $ruleName can be a wildcard pattern that matches multiple rule names
		#     No error handling because Get-ScriptAnalyzerRule does not generate errors
		if ($rules = Get-ScriptAnalyzerRule -Name $Name)
		{
			foreach ($rule in $rules)
			{
				$RuleName = $rule.RuleName
				$URLName = $RuleName -replace "^PS", ""
				$URL = "https://github.com/PowerShell/PSScriptAnalyzer/blob/development/RuleDocumentation/$URLName.md"
				
				try
				{
					$null = Invoke-WebRequest $url -DisableKeepAlive -UseBasicParsing -Method head
					Start-Process $URL
				}
				catch [System.Net.WebException]
				{
					if ($_.Exception -like "*404*")
					{
						Write-Error "No online help for rule: $RuleName"
					}
					else
					{
						Write-Error "Cannot connect to Script Analyzer online."
					}
				}
			}
		}
		else
		{
			Write-Error -Message "Cannot find rule name like: $Name"
		}
	}
	END
	{
		if (!$Name)
		{
			Write-Error -Message "No values were piped to Show-RuleHelp."
		}
	}
}