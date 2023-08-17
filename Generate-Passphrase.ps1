<#
.SYNOPSIS
    https://xkcd.com/936/

.DESCRIPTION
    A PowerShell module that generates 1 or more passwords or passphrases and writes them out to a file or displays them on-screen. Passwords/Passphrases are randomly generated to allow for better proctection when securing accounts, data, or devices.

.PARAMETER Count
    Mandatory.
    The amount of passwords or passphrases that the script should generate.

.PARAMETER Phrases
    Mandatory Switch.
    When used, the 'Phrase' switch will generate passphrases based on word count.
    Not specifying this switch will force the script to default to generating passwords based on string length.

.PARAMETER Spaces
    Optional Switch.
    Only used in conjunction with the 'Phrases' switch
    When used, the 'Spaces' switch will generate passphrases that include spaces, whereas not using it will generate passphrases that do not include spaces.
    The option exists strictly for those who prefer a passphrase that includes spaces.

.PARAMETER WordCount
    Optional.
    Only used in conjunction with the 'Phrases' switch.
    This is the number of words to use in a passphrase.
    Defaults to 4 words unless otherwise specified.
    Maximum supported word count is 8.

.PARAMETER StringLength
    Optional.
    Sets the length of each password string.
    Defaults to a minimum of 12 characters unless otherwise specified.
    Maximum supported length is 64 characters.

.PARAMETER ConsoleOnly
    Optional Switch.
    When used, the 'ConsoleOnly' switch will force the output of the passphrases/passwords directly to the current console window.

.INPUTS
    .\dictionary.csv
        A csv file containing words used in the creation of randomly generated passphrases.
        Only the first column (Header="Words") is used in the process, so creation of additional columns will not affect the process of generating passphrases.
        The first column must contain a header title "Words" for the process of generating passphrases to work correctly.

.OUTPUTS
    .\GeneratedObjects.txt
        A file containing all generated passwords or passphrases if the 'ConsoleOnly' switch is not used.
        The file is created in the same folder as the script and dictionary files.

.NOTES
    Author:         | Jason B. Darling
    Date:           | [YMD] 2023.08.12
    Edit:           | [YMD] 2023.08.17
    Version:        | 0.3
    License:        | MIT -- https://opensource.org/licenses/MIT -- Copyright (c) 2023 JBS Solutions

.EXAMPLE
    Generate-Passphrase -Count 50 -Phrases -WordCount 6

        (Script is imported as a module.)
        This will produce the output of 50 passphrases with 6 words used in each passphrase.

.EXAMPLE
    Generate-Passphrase -Count 50 -Phrases -WordCount 4 -Spaces

        (Script is imported as a module.)
        This will produce the output of 50 passphrases with 4 words used in each passphrase that also contain spaces.

.EXAMPLE
    .\Generate-Passphrase.ps1 -Count 4 -Phrases -Spaces -ConsoleOnly

        (Script is called directly from command line.)
        This will produce the output of 4 passphrases with 4 (default) words used in each passphrase that also contain spaces.

.EXAMPLE
    Generate-Passphrase -Count 12 -StringLength 15

        (Script is imported as a module.)
        This will produce the output of 12 passwords with a length of 15 characters.

.EXAMPLE
    .\Generate-Passphrase.ps1 -Count 25 -StringLength 16 -ConsoleOnly

        (Scipt is called directly from command line.)
        This method is calling the script directly from the prompt while the script is not imported.
        This will produce the output of 25 passwords with a length of 16 characters and displays them in the current console window.
#>

[cmdletbinding()]
param(
    [Parameter(ValueFromPipelineByPropertyName =$true, HelpMessage="Required parameter [Count] is incorrect. Accepted values: 1 to 100.")]
    [ValidateNotNullOrEmpty()][ValidateRange(1,100)]
    [int]$Count = 1,

    [Parameter(ValueFromPipelineByPropertyName =$true)]
    [switch]$Phrases,

    [Parameter(ValueFromPipelineByPropertyName =$true)]
    [switch]$Spaces,

    [Parameter(ValueFromPipelineByPropertyName =$true, HelpMessage="Parameter [WordCount] is incorrect. Accepted values: 4, 5, 6.")]
    [ValidateNotNullOrEmpty()][ValidateRange(4,8)]
    [int]$WordCount = 4,

    [Parameter(ValueFromPipelineByPropertyName =$true, HelpMessage="Parameter [StringLength] is incorrect. Accepted values: 12 to 64.")]
    [ValidateNotNullOrEmpty()][ValidateRange(12,64)]
    [int]$StringLength = 12,

    [Parameter(ValueFromPipelineByPropertyName =$true)]
    [switch]$ConsoleOnly
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$dictFile   = Join-Path -Path $scriptPath -ChildPath "Dictionary.csv"
$output     = Join-Path -Path $scriptPath -ChildPath "GeneratedObjects.txt"
$CharacterSet = @{
    Alpha = @("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
    Numeric = @("0","1","2","3","4","5","6","7","8","9")
    SpecialChar = @('~','!','@','#','$','%','^','&','*','(',')','_','+','`','-','=','[',']','{','}',';',':',',','.','<','>','?')
}

#---------------------------------------------------------[Initializations]--------------------------------------------------------
$ErrorActionPreference = "SilentlyContinue"

#-----------------------------------------------------------[Functions]------------------------------------------------------------
function Get-RandomAlphanumericString() {
	[CmdletBinding()]
	Param ([int]$Length)

    $randSpCh = (2..3 | Get-Random)
    $charLength = ($Length - $randSpCh)

    $spNoise = -join ((0x21..0x21) + (0x23..0x26) + (0x28..0x2F) + (0x3A..0x40) + (0x5B..0x5F) + (0x7B..0x7E) | Get-Random -Count $randSpCh | % {[char]$_})
    $charNoise = -join ((0x30..0x39) + (0x41..0x5A) + (0x61..0x7A) | Get-Random -Count $charLength | % {[char]$_})
    $combinedNoise = -join ("$spNoise" + "$charNoise")

    $newPass = -join (($combinedNoise).ToCharArray() | Get-Random -Count $Length | % {[char]$_})
    return $newPass
}

function Write-ColorOutput() {
    [CmdletBinding()]
    Param(
         [Parameter(Mandatory=$False,Position=1,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][Object] $Object,
         [Parameter(Mandatory=$False,Position=2,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][ConsoleColor] $ForegroundColor,
         [Parameter(Mandatory=$False,Position=3,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][ConsoleColor] $BackgroundColor,
         [Switch]$NoNewline
    )

    $previousForegroundColor = $host.UI.RawUI.ForegroundColor
    $previousBackgroundColor = $host.UI.RawUI.BackgroundColor

    if($BackgroundColor -ne $null) {
       $host.UI.RawUI.BackgroundColor = $BackgroundColor
    }

    if($ForegroundColor -ne $null) {
        $host.UI.RawUI.ForegroundColor = $ForegroundColor
    }

    if($Object -eq $null) {
        $Object = ""
    }

    if($NoNewline) {
        [Console]::Write($Object)
    } else {
        Write-Output $Object
    }

    $host.UI.RawUI.ForegroundColor = $previousForegroundColor
    $host.UI.RawUI.BackgroundColor = $previousBackgroundColor
}

#-----------------------------------------------------------[Execution]-------------------------------------------------------------
#Clear-Host

# Verify dictionary file
if (-Not (test-path $dictFile)) {
    Write-ColorOutput "Could not locate file $($dictFile)" -ForegroundColor Red
    Write-ColorOutput "Script will now exit..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    Exit 1
} else {
    $wordlist = Import-Csv -Path $dictFile
}

# Begin
Write-ColorOutput "Generating security objects..." -ForegroundColor Cyan
if ($Phrases) {
    for ($i = 1; $i -le $Count; $i++){
        $passwordPrefixWords = $wordlist.Words | Get-Random -Count $WordCount | % {$_.substring(0,1).toupper()+$_.substring(1).tolower()}
        $passwordSuffix = $($CharacterSet.Numeric | Get-Random -Count 1) + $($CharacterSet.SpecialChar | Get-Random -Count 1) + $($CharacterSet.Numeric | Get-Random -Count 1) + $($CharacterSet.SpecialChar | Get-Random -Count 1)
        if ($Spaces) {
            $passwordPrefix = $passwordPrefixWords -join(" ")
            $newPhrase = $passwordPrefix + " " + $passwordSuffix
        } else {
            $passwordPrefix = $passwordPrefixWords -join("")
            $newPhrase = $passwordPrefix + $passwordSuffix
        }
        if ($ConsoleOnly){
            $newPhrase
        } else {
            Add-Content -Path $output -Value $newPhrase
        }
    }
} else {
    for ($i = 1; $i -le $Count; $i++) {
        $newPassword = Get-RandomAlphanumericString -Length $StringLength

        if ($ConsoleOnly) {
            $newPassword
        } else {
            Add-Content -Path $output -Value $newPassword
        }
    }
}
Write-ColorOutput "Done!" -ForegroundColor Green

# End
Write-ColorOutput "Press any key to continue..." -ForegroundColor Yellow
[void][System.Console]::ReadKey($true)
exit
