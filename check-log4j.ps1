$prefix = Read-host "Enter used prefix for all servers"
$computerNames = @(get-adcomputer -Filter { OperatingSystem -Like '*Windows Server*' } -Properties * |  where { ($_.Name -like "$prefix*" )} | Select name )
$ignoreDrives = @("A", "B" ) # A and B not relevant, D is temp drive of Azure VMs
$keyword = "*log4j-*.jar"
$server = Read-Host "Enter server to store logfile"
$path = Read-Host "Enter share to store logfile"
$logfile = "\\$server\$path\log4j-servercheck.log-$prefix"

If(!(test-path \\$server\$path))
{
      New-Item -ItemType Directory -Force -Path \\$server\$path
}

Start-Transcript -Path $logfile -NoClobber

foreach ($computer in $computerNames) {
    $computer.name # Show computername
    if ((Test-Connection -computername $computer.name -Quiet) -eq $true) {
        Invoke-Command -ComputerName $computer.name -ScriptBlock {
            $drives = Get-PSDrive -PSProvider FileSystem
            foreach ($drive in $drives) {
                if ($drive.Name -notin $using:ignoreDrives) {
                    $items = Get-ChildItem -Path $drive.Root -Filter $using:keyword -ErrorAction SilentlyContinue -File -Recurse
                    foreach ($item in $items) {
                        $item.FullName # Show all files found with full drive and path
                    }
                }
            }
        }
    }
    else{
     "Offline"
     }
}

Stop-Transcript

<#

This is a quick script, don't expect it to be too neat.
It should work for it's intended purpose, readability may be a bit harsh.

#>
