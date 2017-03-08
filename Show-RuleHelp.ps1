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
		A description of the Name parameter.
	
	.EXAMPLE
		PS C:\> Show-RuleHelp -Name PSMisleadingBacktick
		
		.EXAMPLE\
		
		
		PS C:\> Get-ScriptAnalyzerRule  | Show-RuleHelp -Name PSMisleadingBacktick
	
	.NOTES
		Additional information about the function.
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
		Write-Verbose "Stop here"
		
		# $ruleName might be a wildcard pattern
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