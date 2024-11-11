# ������� ��� ������ INI �����
function Get-IniContent {
    param (
        [string]$Path
    )

    $ini = @{}
    if (Test-Path $Path) {
        $currentSection = ''

        foreach ($line in Get-Content $Path) {
            $line = $line.Trim()
            if ($line -eq '' -or $line -like ';*') { continue } # ���������� ������ ������ � �����������

            if ($line -match '^\[(.*?)\]$') {
                # ���� ������ �������� ���������� ������
                $currentSection = $matches[1]
                $ini[$currentSection] = @{}
            } elseif ($currentSection -ne '') {
                # ���� ��� ������ � ����� ����-��������
                $keyValue = $line -split '=\s*', 2  # ��������� �� = � ������� �������
                if ($keyValue.Count -eq 2) {
                    $ini[$currentSection][$keyValue[0].Trim()] = $keyValue[1].Trim()
                }
            }
        }
    }
    return $ini
}

# ������� ��� ������� ������������
function Debug-IniContent {
    param (
        [string]$Xms,
        [string]$Xmx,
        [string]$Jar
    )

    # ��������� ���������
    if (-not $Xms -or -not $Xmx -or -not $Jar) {
        Write-Host "������: ������������ ��������� ��� ������� �������."
        Write-Host "���������: Xms=$Xms, Xmx=$Xmx, Jar=$Jar"
        return
    } else {
        Write-Host "��������� ������� ���������: Xms=$Xms, Xmx=$Xmx, Jar=$Jar"
    }
}

# ��������� ������������ �� INI �����
$config = Get-IniContent -Path "config.ini"

# ��������� ���������� �� ������������
$Xms = $config.Server.Xms
$Xmx = $config.Server.Xmx
$Jar = $config.Server.Jar

# ����� ������� ��� �������
Debug-IniContent -Xms $Xms -Xmx $Xmx -Jar $Jar

# ������� ��� ������� �������
function Start-MinecraftServer {
    if (-not $Xms -or -not $Xmx -or -not $Jar) {
        Write-Host "������: ������������ ��������� ��� ������� �������."
        return
    }

    Write-Host "������ ������� Minecraft � Xms=${Xms}, Xmx=${Xmx}..."

    # ���� ������� ��� ������� �������
    $command = "java -Xms$Xms -Xmx$Xmx --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -jar $Jar --nogui"
    
    Invoke-Expression $command
}

# �������� ���� ��� ����������� ������� ����� ��� ���������
while ($true) {
    Start-MinecraftServer
    Write-Host "������ ����������, ���������� ����� 5 ������..."
    Start-Sleep -Seconds 5
}
