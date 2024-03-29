#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '4.0.0' }

using namespace System.Collections.Generic
using namespace System.Management.Automation

param()

Add-Type -AssemblyName Microsoft.VisualBasic


Describe 'Get-TypeName Test' {
	Context '$null' {
		It 'Length -eq 0' {
			@(Get-TypeName $null).Length | Should -BeExactly 0
		}
	}
	Context 'New-Object -ComObject WScript.Shell' {
		It 'IWshShell3' {
			Get-TypeName (New-Object -ComObject WScript.Shell) | Should -BeExactly 'IWshShell3'
		}
	}
	Context 'New-Object -ComObject Shell.Application' {
		It 'match ^IShellDispatch\d+$' {
			Get-TypeName (New-Object -ComObject Shell.Application) | Should -MatchExactly '^IShellDispatch\d+$'
		}
	}
	Context "[Microsoft.VisualBasic.Interaction]::GetObject(`"$($Env:COMPUTERNAME),computer`")" {
		It '_ComObject' {
			$lm = [Microsoft.VisualBasic.Interaction]::GetObject("WinNT://$($Env:COMPUTERNAME),computer")
			Get-TypeName $lm | Should -BeExactly '_ComObject'
		}
	}
	Context 'Get-CimInstance Win32_OperatingSystem' {
		It 'Microsoft.Management.Infrastructure.CimInstance#root/cimv2/Win32_OperatingSystem' {
			Get-TypeName (Get-CimInstance Win32_OperatingSystem) |
				Should -BeExactly 'Microsoft.Management.Infrastructure.CimInstance#root/cimv2/Win32_OperatingSystem'
		}
	}
	Context '[wmi]''Win32_OperatingSystem=@''' {
		It 'System.Management.ManagementObject#root\cimv2\Win32_OperatingSystem' {
			Get-TypeName ([wmi]'Win32_OperatingSystem=@') |
				Should -BeExactly 'System.Management.ManagementObject#root\cimv2\Win32_OperatingSystem'
		}
	}
	Context '''abc''' {
		It 'System.String' {
			Get-TypeName 'abc' | Should -BeExactly 'System.String'
		}
	}
	Context '[int[]]@(0, 1, 2)' {
		It 'System.Int32[]' {
			Get-TypeName ([int[]]@(0, 1, 2)) | Should -BeExactly 'System.Int32[]'
		}
	}
	Context '[Dictionary[[string], [int]]]::new()' {
		It 'System.Collections.Generic.Dictionary`2' {
			Get-TypeName ([Dictionary[[string], [int]]]::new()) |
				Should -BeExactly 'System.Collections.Generic.Dictionary`2[System.String,System.Int32]'
		}
	}
	Context '[List[int][]]@([List[int]]::new())' {
		It 'System.Collections.Generic.List`1[System.Int32][]' {
			Get-TypeName ([List[int][]]@([List[int]]::new())) |
				Should -BeExactly 'System.Collections.Generic.List`1[System.Int32][]'
		}
	}
	Context '[List[int[, ]]]::new()' {
		It 'System.Collections.Generic.List`1[System.Int32[,]]' {
			Get-TypeName ([List[int[, ]]]::new()) |
				Should -BeExactly 'System.Collections.Generic.List`1[System.Int32[,]]'
		}
	}
	Context 'Get-TypeName -ProgId Scripting.FileSystemObject' {
		It 'IFileSystem3' {
			Get-TypeName -ProgId Scripting.FileSystemObject | Should -BeExactly 'IFileSystem3'
		}
	}
	Context 'Get-TypeName -ProgId ???' {
		It 'Length -eq 0' {
			@(Get-TypeName -ProgId ??? -ErrorAction SilentlyContinue).Length | Should -BeExactly 0
		}
		It 'throw COMException' {
			{ Get-TypeName -ProgId ??? -ErrorAction Stop } |
				Should -Throw -ExceptionType System.Runtime.InteropServices.COMException
		}
	}
	Context 'Get-TypeName -ProgId ''''' {
		It 'throw ParameterBindingException' {
			{ Get-TypeName -ProgId '' } | Should -Throw -ExceptionType ([ParameterBindingException])
		}
	}
	Context '1.0, (New-Object -ComObject Scripting.Dictionary) | Get-TypeName' {
		It 'System.Double, IDictionary' {
			1.0, (New-Object -ComObject Scripting.Dictionary) |
				Get-TypeName |
				Should -BeExactly @('System.Double', 'IDictionary')
		}
	}
	Context '$null | Get-TypeName' {
		It 'Length -eq 0' {
			@($null | Get-TypeName -ErrorAction Stop).Length | Should -BeExactly 0
		}
	}
	Context '1, $null, ''foo'' | Get-TypeName' {
		It 'System.Int32, System.String' {
			1, $null, 'foo' | Get-TypeName | Should -BeExactly @('System.Int32', 'System.String')
		}
	}
}

Describe 'Get-PsTypeName Test' {
	Context 'adsi' {
		It 'adsi' {
			Get-PsTypeName adsi | Should -BeExactly 'adsi'
		}
	}
	Context 'foobar' {
		It 'throw RuntimeException' {
			{ Get-PsTypeName foobar -ErrorAction Stop } | Should -Throw -ExceptionType ([RuntimeException])
		}
	}
	Context 'System.String' {
		It 'string' {
			Get-PsTypeName System.String | Should -BeExactly 'string'
		}
	}
	Context 'int' {
		It 'int, int32' {
			Get-PsTypeName int | Should -BeExactly @('int', 'int32')
		}
	}
	# System.の省略
	Context 'Xml.XmlDocument' {
		It 'xml' {
			Get-PsTypeName Xml.XmlDocument | Should -BeExactly 'xml'
		}
	}
	Context 'Management.Automation.PSObject' {
		It 'pscustomobject, psobject' {
			Get-PsTypeName Management.Automation.PSObject | Should -BeExactly @('pscustomobject', 'psobject')
		}
	}
	Context 'System.Poo' {
		It 'throw RuntimeException' {
			{ Get-PsTypeName System.Poo -ErrorAction Stop } | Should -Throw -ExceptionType ([RuntimeException])
		}
	}
	Context '''''' {
		It 'throw ParameterBindingException' {
			{ Get-PsTypeName '' } | Should -Throw -ExceptionType ([ParameterBindingException])
		}
	}
	Context '1.0, $null, ''foo'' | Get-TypeName | Get-PsTypeName' {
		It 'double, string' {
			1.0, $null, 'foo' | Get-TypeName | Get-PsTypeName | Should -BeExactly @('double', 'string')
		}
	}
	Context '$null | Get-PsTypeName' {
		It 'throw ParameterBindingException' {
			{ $null | Get-PsTypeName -ErrorAction Stop } | Should -Throw -ExceptionType ([ParameterBindingException])
		}
	}
}

Describe 'Get-SystemTypeName test' {
	Context int {
		It System.Int32 {
			Get-SystemTypeName int | Should -BeExactly System.Int32
		}
	}
	Context 'foo psobject double | Get-SystemTypeName' {
		'foo', 'psobject', 'double' | Get-SystemTypeName | Should -BeExactly @('System.Management.Automation.PSObject', 'System.Double')	}
}
