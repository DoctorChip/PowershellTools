##
##  Script to find, recursively, any files from a filename list in a directory, 
##  and move them to a new directory. Optionally, remove the source files after copying.
##


## CONFIG    
        
    ## The parent directory to search from
    $SearchDirectory = "C:\Users\ChrisWalker\Desktop"

    ## The list of filenames we want to find
    $FileNames = @(
        @{Source = "01.txt"; Dest = "03.txt"},
        @{Source = "02.txt"; Dest = "04.txt"}
    )

    ## The destination directory
    $DestDir = "C:\Users\ChrisWalker\Desktop"
    $ResultsFolderName = "Results"

    ## Remove the old files?
    $RemoveOldFiles = $TRUE


## RUN

    Write-Host "---"
    ## Recursively search our target directory for any of our files
    $FoundFiles = @();
    foreach ($search in $FileNames)
    {
        $file = Get-ChildItem -Path $SearchDirectory -Filter $search.Source -Recurse -ErrorAction SilentlyContinue -Force
        $FoundFiles += @{ DestName = $search.Dest; File = $file }
    }

    ## Bail out if we didnt find any files
    if ($FoundFiles.Length -eq 0)
    {
        Write-Host "We didnt find any files."
    }

    ## Ensure our results directory can be made, and make it
    if (!(Test-Path ($DestDir + '\' + $ResultsFolderName) -PathType Container))
    {
        $d = New-Item -ItemType Directory -Force -Path ($DestDir + '\' + $ResultsFolderName)
    }
    else
    {
        Write-Host "Unable to create results directory."
        return
    }

    ## Move our files
    foreach ($file in $FoundFiles)
    {
        Write-host "Moving:" $file.File.Name

        if(!($file.File.Name -eq $null))
        {
              $newDir = $DestDir + '\' + $ResultsFolderName + '\' + $file.DestName
              $c = $file.File.CopyTo($newDir)

              if (Test-path ($DestDir + '\' + $ResultsFolderName + '\' + $file.DestName))
              {
                  if ($RemoveOldFiles -eq $TRUE)
                  {
                      Write-host "Removing:" $file.File.Name
                      Remove-item ($file.File.FullName)
                  }
              }
          }
    }

    # Fin
    Write-Host "---"
    Write-Host "Finished"
