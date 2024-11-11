# Function to set colors
function Set-ConsoleColors {
    $global:green = "`e[32m"
    $global:red = "`e[31m"
    $global:reset = "`e[0m"
}

# Call the function to set colors
Set-ConsoleColors

# Function to read INI file
function Get-IniContent {
    param (
        [string]$Path
    )

    $ini = @{}
    if (Test-Path $Path) {
        $currentSection = ''

        foreach ($line in Get-Content $Path) {
            $line = $line.Trim()
            if ($line -eq '' -or $line -like ';*') { continue } # Skip empty lines and comments

            if ($line -match '^\[(.*?)\]$') {
                # If the line is a section header
                $currentSection = $matches[1]
                $ini[$currentSection] = @{}
            } elseif ($currentSection -ne '') {
                # If this is a key-value pair line
                $keyValue = $line -split '=\s*', 2  # Split by = and trim spaces
                if ($keyValue.Count -eq 2) {
                    $ini[$currentSection][$keyValue[0].Trim()] = $keyValue[1].Trim()
                }
            }
        }
    }
    return $ini
}

# Function to debug configuration
function Debug-IniContent {
    param (
        [string]$Xms,
        [string]$Xmx,
        [string]$Jar
    )

    # Validate parameters
    if (-not $Xms -or -not $Xmx -or -not $Jar) {
        Write-Host "${red}Error: invalid parameters to start the server.${reset}"
        Write-Host "Parameters: Xms=$Xms, Xmx=$Xmx, Jar=$Jar"
        return
    } else {
        Write-Host "${green}Parameters successfully loaded: Xms=$Xms, Xmx=$Xmx, Jar=$Jar${reset}"
    }
}

# Load configuration from INI file
$config = Get-IniContent -Path "config.ini"

# Set variables from configuration
$Xms = $config.Server.Xms
$Xmx = $config.Server.Xmx
$Jar = $config.Server.Jar

# Call the function to debug
Debug-IniContent -Xms $Xms -Xmx $Xmx -Jar $Jar

# Function to start the server
function Start-MinecraftServer {
    if (-not $Xms -or -not $Xmx -or -not $Jar) {
        Write-Host "${red}Error: invalid parameters to start the server.${reset}"
        return
    }

    Write-Host "${green}Starting Minecraft server with Xms=${Xms}, Xmx=${Xmx}...${reset}"

    # Your command to start the server
    $command = "java -Xms$Xms -Xmx$Xmx --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -jar $Jar --nogui"
    
    Invoke-Expression $command
}

# Main loop to restart the server after it stops
while ($true) {
    Start-MinecraftServer
    Write-Host "${red}Server stopped, restarting in 5 seconds...${reset}"
    Start-Sleep -Seconds 5
}