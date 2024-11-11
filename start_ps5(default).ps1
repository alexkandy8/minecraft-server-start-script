# Функция для чтения INI файла
function Get-IniContent {
    param (
        [string]$Path
    )

    $ini = @{}
    if (Test-Path $Path) {
        $currentSection = ''

        foreach ($line in Get-Content $Path) {
            $line = $line.Trim()
            if ($line -eq '' -or $line -like ';*') { continue } # Пропускаем пустые строки и комментарии

            if ($line -match '^\[(.*?)\]$') {
                # Если строка является заголовком секции
                $currentSection = $matches[1]
                $ini[$currentSection] = @{}
            } elseif ($currentSection -ne '') {
                # Если это строка с парой ключ-значение
                $keyValue = $line -split '=\s*', 2  # Разделяем по = и убираем пробелы
                if ($keyValue.Count -eq 2) {
                    $ini[$currentSection][$keyValue[0].Trim()] = $keyValue[1].Trim()
                }
            }
        }
    }
    return $ini
}

# Функция для отладки конфигурации
function Debug-IniContent {
    param (
        [string]$Xms,
        [string]$Xmx,
        [string]$Jar
    )

    # Проверяем параметры
    if (-not $Xms -or -not $Xmx -or -not $Jar) {
        Write-Host "Ошибка: некорректные параметры для запуска сервера."
        Write-Host "Параметры: Xms=$Xms, Xmx=$Xmx, Jar=$Jar"
        return
    } else {
        Write-Host "Параметры успешно загружены: Xms=$Xms, Xmx=$Xmx, Jar=$Jar"
    }
}

# Загружаем конфигурацию из INI файла
$config = Get-IniContent -Path "config.ini"

# Установка переменных из конфигурации
$Xms = $config.Server.Xms
$Xmx = $config.Server.Xmx
$Jar = $config.Server.Jar

# Вызов функции для отладки
Debug-IniContent -Xms $Xms -Xmx $Xmx -Jar $Jar

# Функция для запуска сервера
function Start-MinecraftServer {
    if (-not $Xms -or -not $Xmx -or -not $Jar) {
        Write-Host "Ошибка: некорректные параметры для запуска сервера."
        return
    }

    Write-Host "Запуск сервера Minecraft с Xms=${Xms}, Xmx=${Xmx}..."

    # Ваша команда для запуска сервера
    $command = "java -Xms$Xms -Xmx$Xmx --add-modules=jdk.incubator.vector -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -jar $Jar --nogui"
    
    Invoke-Expression $command
}

# Основной цикл для перезапуска сервера после его окончания
while ($true) {
    Start-MinecraftServer
    Write-Host "Сервер остановлен, перезапуск через 5 секунд..."
    Start-Sleep -Seconds 5
}
