# Vim config
New-Alias nvim ~\nvim\Neovim\bin\nvim 
New-Alias vim nvim
New-Alias cl 'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.28.29333\bin\Hostx86\x86\cl.exe'

New-Alias which Get-Command

pushd 'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\'
cmd /c "vcvars64.bat&set" |
foreach {
  if ($_ -match "=") {
		$v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
	}
}
popd
write-host "`nVisual Studio 2010 Command Prompt variables set." -ForegroundColor Yellow


