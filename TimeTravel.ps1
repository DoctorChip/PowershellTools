param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

exit
}

$global:ChangeSeconds = 0;
$global:LastCommand = '';

function Get-Modifier([String]$Str){
    $mod = $Str.Substring(0,1)

    if ($mod -eq '-' -or $mod -eq '+')
    {
        return "$mod"
    }

    Write-Host("TTM Pilot: 'Wooooah, Captain! The first character of your request needs to be a + or - symbol! Aborting Mission!'")
    return $null
}

function Get-Count([String]$Str)
{
    if ($Str.Length -eq 2)
    {
        Write-Host("TTM Pilot: 'Wooooah, Captain! You missed a parameter! Aborting Mission!'")
        return $null
    }

    $cnt = $Str.Substring(1, ($Str.Length - 2))

    $castToInt = $cnt -as [int]

    if ($castToInt -eq $null)
    {
        Write-Host("TTM Pilot: 'Wooooah, Captain! The second parameter needs to be a whole-number! Aborting Mission!'")
        return $null
    }

    if ($castToInt -eq 0)
    {
        Write-Host("TTM Pilot: 'Uhhh, okay... well... we're here? You did ask us to move, like, 0 units of time. Duh.'")
        return $null
    }

    return "$castToInt"
}

function Get-Unit([String]$Str)
{
    $unit = $Str.Substring(($Str.Length - 1), 1)

    if ($unit -eq "s" -or $unit -eq "m" -or $unit -eq "h" -or $unit -eq "d")
    {
        return "$unit"
    }

    Write-Host("TTM Pilot: 'Wooooah, Captain! The last parameter needs to be a 's', 'm', 'h' or 'd'! Aborting Mission!'")
    return $null    
}

function Process-Request([String]$mod, [Int]$cnt, [String]$unit)
{
    $secondsToMove = 0

    if ($unit -eq 's') { $secondsToMove = $cnt }
    if ($unit -eq 'm') { $secondsToMove = ($cnt * 60) }
    if ($unit -eq 'h') { $secondsToMove = ($cnt * 60 * 60) }
    if ($unit -eq 'd') { $secondsToMove = ($cnt * 60 * 60 * 24) }

    if ($mod -eq '-') { $secondsToMove *= -1 }

    $global:ChangeSeconds = ($global:ChangeSeconds + $secondsToMove)

    Write-Host("TTM Pilot: 'Warping...'")
    $TimeWarp = Set-Date -Adjust (New-TimeSpan -Seconds $secondsToMove)
    Write-Host("TTM PIlot: 'Welcome to $TimeWarp, Captain!'")
    Write-Host("")
}

function AddTime
{
    ""
    $request = $param.ToString()

    $mod = Get-Modifier -Str $request
    if ($mod -eq $null) { return $null }

    $cnt = Get-Count -Str $request
    if ($cnt -eq $null) { return $null }

    $unit = Get-Unit -Str $request
    if ($unit -eq $null) { return $null }

    Process-Request $mod $cnt $unit

    $global:LastCommand = $request
}

function ResetTime
{
    if ($global:ChangeSeconds -ne 0)
    {
        $Reset = Set-Date -Adjust (New-TimeSpan -Seconds ($ChangeSeconds * -1))
        $global:ChangeSeconds = 0
    }
}

"|----------------------------------------|"
"|-- WELCOME TO THE TIME TRAVEL MACHINE --|"
"|----------------------------------------|"
"                                          "
"                                          "
" The TTM accepts a single parameter per   "
" line, built up of 3 elements.            "
"                                          "
"                                          "
" The direction to travel:                 "
"      + or -                              "
"                                          "
"                                          "
" The amount of units to travel:           "
"      1 to infinity                       "
"      (but dont go past 2039!)            "
"                                          "
"                                          "
" The units:                               "
"     s, m, h, d                           "
"                                          "
"     s = seconds                          "
"     m = minutes                          "
"     h = hours                            "
"     d = days                             "
"                                          "
"                                          "
"------------------------------------------"
"                                          "
"                                          "
" For example:                             "
"      +1d   = Forward 1 day.              "
"      -30m  = Back 30 minutes.            "
"      +10000s  = Forward 10,000 seconds.  "
"                                          "
"                                          "
"------------------------------------------"
"                                          "
"                                          "
"                                          "
" When finished, type 'reset' to           "
" set your time back to the correct time!  "
"                                          "
" If you want to repeat a command, you     "
" can do so with . (period)                "
"                                          "
"                                          "
"                Have fun!                 "
"                                          "
"------------------------------------------"
"                                          "
"                                          "

while ($true)
{
    $param = Read-Host "TTM Pilot: 'When to, Captain?'"

    if ($param -eq "reset" )
    {
        if ($global:ChangeSeconds -eq 0)
        {
            Write-Host("TTM Pilot: 'Sir, we're in our home-time! There's nothing to reset!'")
        }
        else
        {
            "TTM Pilot: 'Okay. Resetting!'"
            ResetTime
        }
    }
    else
    {
        if  ($param -eq ".")
        {
            if ($global:LastCommand -eq '')
            {
                Write-Host("TTM Pilot: 'Sir, we don't have any commands to repeat!'")
                Write-Host("")
            }
            else
            {
                Write-Host("TTM Pilot: 'Wanna go again? Okay!'")
                $param = $global:LastCommand
                Addtime $param
            }
        }
        else
        {
            "TTM Pilot: 'Okay, Captain! Command received!'"
            AddTime $param
        }
    }
}
