# Generate Passphrases and Passwords

[XKCD Reference](https://xkcd.com/936/)

A PowerShell module that generates 1 or more passwords or passphrases and writes them out to a file or displays them on-screen. Passwords/Passphrases are randomly generated to allow for better proctection when securing accounts, data, or devices.


# Parameters
Count
  * Mandatory.
  * The amount of passwords or passphrases that the script should generate.

Phrases
  * Mandatory Switch.
  * When used, the 'Phrase' switch will generate passphrases based on word count.
  * Not specifying this switch will force the script to default to generating passwords based on string length.

Spaces
  * Optional Switch.
  * Only used in conjunction with the 'Phrases' switch
  * When used, the 'Spaces' switch will generate passphrases that include spaces, whereas not using it will generate passphrases that do not include spaces.
  * The option exists strictly for those who prefer a passphrase that includes spaces.

WordCount
  * Optional.
  * Only used in conjunction with the 'Phrases' switch.
  * This is the number of words to use in a passphrase.
  * Defaults to 4 words unless otherwise specified.
  * Maximum supported word count is 8.

StringLength
  * Optional.
  * Sets the length of each password string.
  * Defaults to a minimum of 12 characters unless otherwise specified.
  * Maximum supported length is 64 characters.

ConsoleOnly
  * Optional Switch.
  * When used, the 'ConsoleOnly' switch will force the output of the passphrases/passwords directly to the current console window.

# Inputs
.\dictionary.csv
  * A csv file containing words used in the creation of randomly generated passphrases.
  * Only the first column (Header="Words") is used in the process, so creation of additional columns will not affect the process of generating passphrases.
  * The first column must contain a header title "Words" for the process of generating passphrases to work correctly.

# Outputs
.\GeneratedObjects.txt
  * A file containing all generated passwords or passphrases if the 'ConsoleOnly' switch is not used.
  * The file is created in the same folder as the script and dictionary files.


# Examples
  1. Generate-Passphrase -Count 50 -Phrases -WordCount 6
    * (Script is imported as a module.)
    * This will produce the output of 50 passphrases with 6 words used in each passphrase.

  2. Generate-Passphrase -Count 50 -Phrases -WordCount 4 -Spaces
    * (Script is imported as a module.)
    * This will produce the output of 50 passphrases with 4 words used in each passphrase that also contain spaces.

  3. .\Generate-Passphrase.ps1 -Count 4 -Phrases -Spaces -ConsoleOnly
    * (Script is called directly from command line.)
    * This will produce the output of 4 passphrases with 4 (default) words used in each passphrase that also contain spaces.

  4. Generate-Passphrase -Count 12 -StringLength 15
    * (Script is imported as a module.)
    * This will produce the output of 12 passwords with a length of 15 characters.

  5. .\Generate-Passphrase.ps1 -Count 25 -StringLength 16 -ConsoleOnly
    * (Scipt is called directly from command line.)
    * This method is calling the script directly from the prompt while the script is not imported.
    * This will produce the output of 25 passwords with a length of 16 characters and displays them in the current console window.
