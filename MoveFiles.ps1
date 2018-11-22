##
##  Script to find, recursively, any files from a filename list in a directory, 
##  and move them to a new directory. Optionally, remove the source files after copying.
##


## CONFIG    
        
    ## The parent directory to search from
    $SearchDirectory = "C:\"

    ## The list of filenames we want to find
    $FileNames = @(
        "01.txt",
        "02.txt"
    )

    ## The destination directory
    $DestDir = "D:\"

    ## Remove the old files?
    $RemoveOldFiles = $FALSE


## RUN

    ## Recursively search our target directory for any of our files
    $FoundFiles = @();
    foreach ($search in $FileNames)
    {
        $file = Get-ChildItem -Path $SearchDirectory -Filter $search -Recurse -ErrorAction SilentlyContinue -Force
        $FoundFiles += $file
    }

    ## Bail out if we didnt find any files
    if ($FoundFiles.Length -eq 0)
    {
        Write-Host "We didnt find any files."
    }

    ## Ensure our results directory can be made, and make it
    if (!(Test-Path ($DestDir + '\' + "RESULTS") -PathType Container))
    {
        New-Item -ItemType Directory -Force -Path ($DestDir + '\' + "RESULTS")
    }
    else
    {
        Write-Host "Unable to create results directory."
        return
    }

    ## Move our files
    foreach ($file in $FoundFiles)
    {
        Write-host $file.Name

        if(!($file.Name -eq $null))
        {
              $newDir = $DestDir + '\' + "RESULTS" + '\' + $file.Name
              $file.CopyTo($newDir)

              if (Test-path ($DestDir + '\' + "RESULTS" + '\' + $file))
              {
                  if ($RemoveOldFiles -eq $TRUE)
                  {
                      Write-host "Removing item: " + $file
                      Remove-item ($file.FullName)
                  }
              }
          }
    }

    # Fin
    Write-Host "Finished. :)"
