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


function New-ValidationDynamicParam
{
	<#
.NOTES
By Adam Bertram
http://www.adamtheautomator.com/psbloggingweek-dynamic-parameters-and-parameter-validation
	
.SYNOPSIS
Adds a dynamic parameter with a dynamic value set to a script or function. The valid 
values of the parameter are determined at runtime.

.DESCRIPTION
The New-ValidationDynamicParam function creates a dynamic parameter with a set of valid 
values that are determined at runtime. The values must be strings or be convertible to
strings.

You can use New-ValidationDynamicParam to add this type of dynamic parameter to the 
functions and scripts that you write. The dynamic value set works like the ValidateSet 
attribute of parameters, but the values in the set are determined only when the script 
or function runs. 

To use the function, add the New-ValidationDynamicParam function to your script or 
function. Then, place a call to New-ValidationDynamicParam in a DynamicParam script 
block. You can also use other methods to get New-ValidationDynamicParam into your 
function scope, including dot-sourcing a script that includes the function. 

To set the values of the dynamic parameter, use the ValidateSetOptions parameter. 
Enclose the commands that get the values in parentheses, not in a script block. 

This function creates a dynamic parameter with a dynamic validation set. For 
information about how to create other types of dynamic parameters, see 
about_Functions_Advanced_Parameters at http://go.microsoft.com/fwlink/?LinkID=135173.


.PARAMETER Name
Specifies the name of the dynamic parameter. The Name value cannot be the same as the 
name of any other parameter, including standard (non-dynamic) parameters. A Name value 
is required and can't be an empty string ("").

.PARAMETER ValidateSetOptions
Specifies the commands that determine the parameter values. Enclose the commands in 
parentheses. This parameter is required.

.PARAMETER Mandatory
Makes the dynamic parameter mandatory. By default, it is optional. If the dynamic 
parameter appears in all parameter sets (the default), the value of Mandatory applies 
to all parameter sets. 

.PARAMETER ParameterSetName
Adds the dynamic parameter to the specified parameter set. Enter the name of one 
parameter set. By default, it is added to all parameter sets.

.PARAMETER ValueFromPipeline
Adds the ValueFromPipeline attribute to the parameter. This parameter sets the
attribute, but does not add commands to manage pipeline input, such as a Process 
block.

.PARAMETER ValueFromPipelineByPropertyName
Adds the ValueFromPipelinebyPropertyName attribute to the parameter. This parameter 
sets the attribute, but does not add commands to manage pipeline input.

.INPUTS
None. You cannot pipe input to this function.

.OUTPUTS
System.Management.Automation.RuntimeDefinedParameter

.NOTES
This function creates a parameter that takes a string value. 

.EXAMPLE
This command creates a Font dynamic parameter. The values of Font are the names of 
fonts on the system. To get the font names, the command uses a Get-ChildItem command 
for TTF files in the C:\Windows\Fonts directory. It gets the BaseName property, because
the parameter type is a string.

New-ValidationDynamicParam -Name Font `
	-ValidateSetOptions (Get-ChildItem C:\Windows\Fonts\*ttf | Foreach {$_.BaseName} )


.EXAMPLE
This command creates a Process dynamic parameter whose values are limited to the 
names of processes running on the computer. It is a mandatory parameter in the ProcessSet 
parameter set and you can pipe string values to it.

New-ValidationDynamicParam -Name Process -ParameterSetName ProcessSet `
	-ValueFromPipeline -ValidateSetOptions (Get-Process | foreach {$_.Name})

When you run the function, you can use Get-Command to verify that the Process parameter
is dynamic and has the attributes that you specified.

PS C:\> ((Get-Command Get-TheAwesome).ParameterSets.Parameters | where Name -eq "Process").IsDynamic
True                                                                                                                    
PS C:\> ((Get-command Get-TheAwesome).ParameterSets.Parameters | where Name -eq "Process").Attributes                                                                                                                        
                                                                                                                        
Position                        : -2147483648                                                                           
ParameterSetName                : ProcessSet                                                                            
Mandatory                       : False                                                                                 
ValueFromPipeline               : True                                                                                  
ValueFromPipelineByPropertyName : False                                                                                 
ValueFromRemainingArguments     : False                                                                                 
HelpMessage                     :                                                                                       
HelpMessageBaseName             :                                                                                       
HelpMessageResourceId           :                                                                                       
DontShow                        : False                                                                                 
TypeId                          : System.Management.Automation.ParameterAttribute                                       
                                                                                                                        
IgnoreCase  : True                                                                                                      
ValidValues : {AcroRd32, AVControlCenter32, CamMute, conhost...}                                                        
TypeId      : System.Management.Automation.ValidateSetAttribute                                                         



.EXAMPLE
This example shows how to use the New-ValidationDynamicParam function in your function. 
This function has a standard parameter named ID and the Font dynamic parameter.

Add the New-ValidationDynamicParam function to your script or include it in your 
function. Then, add a DynamicParam script block to your function and place the call to 
New-ValidationDynamicParam in the script block.  

#My script
function New-ValidationDynamicParam {...}

function MyFunction {

	Param([Parameter()][int]$ID) 

	DynamicParam { 
		New-ValidationDynamicParam -Name Font `
			-ValidateSetOptions (Get-ChildItem C:\Windows\Fonts\*ttf | Foreach {$_.BaseName} ) 
	{
{


.EXAMPLE
This example shows how to refer to the dynamic parameter in your function. Unlike standard
parameters that become variables in the function, you have to use the $PSBoundParameters
automatic variable to get dynamic parameters. Every parameter in the function is a property 
of $PSBoundParameters, so the Font parameter is $PSBoundParameters.Font.


function MyFunction {

	Param([Parameter()][int]$ID) 

	DynamicParam { 
		New-ValidationDynamicParam -Name Font `
			-ValidateSetOptions (Get-ChildItem C:\Windows\Fonts\*ttf | Foreach {$_.BaseName} )
	}

	if ($PSBoundParameters.Font -like "comic*") {"This font is invalid."}	
{


.EXAMPLE
This example shows how to create a dynamic parameter whose values depend on the
values of another parameter in the script. In this case, the values of the Color
dynamic parameter depend on the value of the ID parameter.

The standard parameters and their values are not available in the DynamicParam
script block, so you need to refer to them as properties of the $PSBoundParameters
automatic variable, such as $PSBoundParameters.ID.

Also, the value of ValidateSetOptions, must be a command, not an expression.

	Param ([int]$ID)
	DynamicParam { 
		New-ValidationDynamicParam -Name Color -Mandatory'
			-ValidateSetOptions (Invoke-Command {
			if ($PsBoundParameters.ID -lt 20)
			{ return 'Red', 'Yellow', 'Blue' }	else { return 'Green', 'Orange', 'Purple' } })	
	}
	
.LINK
http://www.adamtheautomator.com/psbloggingweek-dynamic-parameters-and-parameter-validation/

.LINK 
about_Functions_Advanced_Parameters
#>
	[CmdletBinding()]
	[OutputType('System.Management.Automation.RuntimeDefinedParameter')]
	param (
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Name,
		
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory)]
		[array]
		$ValidateSetOptions,
		
		[switch]
		$Mandatory,
		
		[string]
		$ParameterSetName = '__AllParameterSets',
		
		[switch]
		$ValueFromPipeline,
		
		[switch]
		$ValueFromPipelineByPropertyName
	)
	
	$AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
	$ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
	$ParamAttrib.Mandatory = $Mandatory.IsPresent
	$ParamAttrib.ParameterSetName = $ParameterSetName
	$ParamAttrib.ValueFromPipeline = $ValueFromPipeline.IsPresent
	$ParamAttrib.ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName.IsPresent
	$AttribColl.Add($ParamAttrib)
	$AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($ValidateSetOptions)))
	$RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Name, [string], $AttribColl)
	$RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
	$RuntimeParamDic.Add($Name, $RuntimeParam)
	$RuntimeParamDic
	
}


<#
	.SYNOPSIS
		Opens rules help online
	
	.DESCRIPTION
		Show-RuleHelp displays online help for a PSScriptAnalyzer rule in the default internet browser.
	
	.PARAMETER Name
		Specifies the rule name. Enter a name string. Wildcards are not supported.
	
	.EXAMPLE
		PS C:\> Show-RuleHelp -Name PSMisleadingBacktick
		
		.EXAMPLE\
		
		
		PS C:\> Get-ScriptAnalyzerRule  | Show-RuleHelp -Name PSMisleadingBacktick
	
	.NOTES
		Additional information about the function.
#>
function Show-RuleHelp
{
	[CmdletBinding(DefaultParameterSetName = 'NameSet')]
	Param ()
	
	DynamicParam
	{
		New-ValidationDynamicParam -Name Name -Mandatory -ValueFromPipeline -ValidateSetOptions ((Get-ScriptAnalyzerRule).RuleName) -ParameterSetName NameSet
	}
	
	BEGIN	{}
	PROCESS
	{
		# Create a variable for the Name dynamic parameter and its value
		New-Variable -Name 'Name' -Value $PSBoundParameters['Name'] 
		
		if (Get-ScriptAnalyzerRule -Name $Name)
		{
			$URLName = $Name -replace "^PS", ""
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
					Write-Error "No online help for rule: $Name"
				}
				else
				{
					Write-Error "Cannot connect to Script Analyzer online."
				}
			}
		}
	}
	END   {}
}