$pcname = Read-host "Enter PC name (for logfile naming)"
$ignoreDrives = ()
#$ignoreDrives = @("A", "B" , "K" , "L" ) # A and B are USUALLY not relevant, D is the Azure temp disk; add any nessecary drives here.
$keyword = "*log4j-core*.jar"
$logpath = ".\Logs\scan" # If you need Logs to go on a network share, edit this parameter!
$logfile = "$path\log4j-servercheck-werkplek-$pcname.log"

If(!(test-path $logpath))
{
      New-Item -ItemType Directory -Force -Path $logpath
}

Start-Transcript -Path $logfile 


            $drives = Get-PSDrive -PSProvider FileSystem
            foreach ($drive in $drives) {
                if ($drive.Name -notin $ignoreDrives) {
                    $items = Get-ChildItem -Path $drive.Root -Filter $keyword -ErrorAction SilentlyContinue -File -Recurse
                    foreach ($item in $items) {
                        $item.FullName # Show all files found with full drive and path
                    }
                }
            }


Stop-Transcript

<#

This is a quick script, don't expect it to be too neat.
It should work for it's intended purpose, readability may be a bit harsh.

15-12-2021: Edited for offline use -> by Jan W
#>