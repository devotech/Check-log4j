#$prefix = Read-host "Enter used prefix for all servers"
$computerNames = @(get-adcomputer -Filter { OperatingSystem -Like '*Windows Server*'}) # -and name -like "$prefix*" } )
$ignoreDrives = @("A", "B" ) # A and B not relevant, D is temp drive of Azure VMs
$keyword = "*log4j-*.jar"
$logfile = "\\$server\$path\log4j-servercheck.log"

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
