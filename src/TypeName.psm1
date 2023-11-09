using namespace Microsoft.VisualBasic
using namespace System.Collections.Generic
using namespace System.Management.Automation

function Get-TypeName {
	<#
	.SYNOPSIS
	Get a data-type information about a object.
	.DESCRIPTION
	Get a data-type information about a object.
	If the variable is a COM object, this function returns a interface name.
	.PARAMETER InputObject
	Any object.
	.PARAMETER ProgId
	ProgID you wants to get a interface name.
	.INPUTS
	System.Object
		You can pipe any object to 'Get-TypeName'.
	.OUTPUTS
	System.String
	.EXAMPLE
	PS >Get-TypeName 1.0

	System.Double
	.EXAMPLE
	PS >$fso = New-Object -ComObject Scripting.Dictionary
	PS >Get-TypeName $fso

	IDictionary
	.EXAMPLE
	PS >Get-TypeName -ProgId WScript.Shell

	IWshShell3
	#>

	[CmdletBinding(DefaultParameterSetName = 'InputObject')]
	[OutputType([string])]
	param (
		[Parameter(ParameterSetName = 'InputObject', ValueFromPipeline, Position = 0)]
		[Object]$InputObject,
		[Parameter(ParameterSetName = 'ProgId', Mandatory)][ValidateNotNullOrEmpty()]
		[string]$ProgId
	)

	begin {
		if ($PSCmdlet.ParameterSetName -eq 'ProgId') {
			try {
				$InputObject = New-Object -ComObject $ProgId
			} catch {
				$PSCmdlet.WriteError($_)
			}
		}
	}

	process {
		if ($null -eq $InputObject) {
			Write-Verbose 'Type: Null'
			return
		}
		if ($InputObject -is [__ComObject]) {
			Write-Verbose 'Type: ComObject'
			Add-Type -AssemblyName Microsoft.VisualBasic
			return [Information]::TypeName($InputObject)
		}
		if ($InputObject -is [ciminstance]) {
			Write-Verbose 'Type: CimInstance'
			$properties = $InputObject.CimClass.psbase.CimSystemProperties
			return "$($InputObject.GetType().FullName)#$($properties.Namespace)/$($properties.ClassName)"
		}
		if ($InputObject -is [wmi]) {
			Write-Verbose 'Type: WmiObject'
			$classPath = $InputObject.ClassPath
			return "$($InputObject.GetType().FullName)#$($classPath.NamespacePath)\$($classPath.ClassName)"
		}

		Write-Verbose 'Type: .NetObject'
		return $InputObject.GetType().ToString()
	}
}

function Get-PsTypeName {
	<#
	.SYNOPSIS
	Get a String value containing the PowerShell data type name (type accelerator).
	.PARAMETER Name
	Type name used by the common language runtime.
	.INPUTS
	System.String
		Type name used by the common language runtime.
	.OUTPUTS
	System.String
	.EXAMPLE
	Get-PsTypeName System.Boolean

	bool
	.EXAMPLE
	Get-PsTypeName System.Int32

	int, int32
	.LINK
	about_Type_Accelerators
	Get-SystemTypeName
	#>

	[CmdletBinding()]
	[OutputType([string])]
	param (
		[Parameter(Mandatory, ValueFromPipeline, Position = 0)][ValidateNotNullOrEmpty()]
		[string]$Name
	)

	begin {
		$ret = [List[string]]::new()
		$types = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get.GetEnumerator() |
			Sort-Object Key
	}

	process {
		try {
			$type = [type]$Name
			$ret.Clear()
			foreach ($pair in $types) {
				if ($type -eq $pair.Value) { $ret.Add($pair.Key) }
			}
			if ($ret.Length) { Write-Output ($ret -join ', ') }
		} catch {
			$PSCmdlet.WriteError($_)
		}

	}
}

function Get-SystemTypeName {
	<#
	.SYNOPSIS
	Returns a String value containing the system data type name of a variable.
	.DESCRIPTION
	Returns the name of the .NET class represented by the specified PowerShell type accelerator.
	.PARAMETER PsName
	The name of the PowerShell type accelerator.
	.INPUTS
	System.String
		The name of the PowerShell type accelerator.
	.OUTPUTS
	System.String
	.EXAMPLE
	PS >Get-SystemTypeName pscustomobject

	System.Management.Automation.PSObject
	.LINK
	about_Type_Accelerators
	Get-PsTypeName
	#>

	[CmdletBinding()]
	[OutputType([string])]
	param (
		[Parameter(Mandatory, ValueFromPipeline, Position = 0)]
		[string]$PsName
	)

	begin {
		$types = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
	}

	process {
		if ($types.ContainsKey($PsName)) {
			Write-Output $types[$PsName].FullName
		}
	}
}
