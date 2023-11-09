@{
	ModuleVersion = '1.0.6'
	GUID = '26c9c70e-e2fa-4e3a-80c7-be2cad441b1d'
	Author = 'BaldCat'
	Copyright = '(c) 2020 BaldCat. All rights reserved.'
	Description = 'Get the type name of the object.'
	PowerShellVersion = '5.1'
	CompatiblePSEditions = @('Core', 'Desktop')
	RootModule = 'TypeName.psm1'
	FunctionsToExport = @('Get-TypeName', 'Get-PsTypeName', 'Get-SystemTypeName')
	CmdletsToExport = @()
	AliasesToExport = @()
	PrivateData = @{
		PSData = @{
			Tags = @('Object', 'Type')
		}
	}
}
