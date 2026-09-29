@echo off
:: ======================================
:: LANCADOR INTEGRADO DE FERRAMENTAS v4.3
:: ======================================
chcp 65001 >nul
set "SELF_PATH=%~f0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; try { $c = Get-Content -LiteralPath $env:SELF_PATH -Encoding UTF8; $idx = -1; for ($j=0; $j -lt $c.Count; $j++) { if ($c[$j] -match 'PS_MARKER_START') { $idx = $j + 1; break } }; if ($idx -lt 0) { throw 'Marker PS_MARKER_START nao encontrado' }; $body = ($c[$idx..($c.Count-1)]) -join [Environment]::NewLine; Invoke-Expression $body } catch { Write-Host ''; Write-Host '==========================================' -ForegroundColor Red; Write-Host '   ERRO NO LAUNCHER' -ForegroundColor Red; Write-Host '==========================================' -ForegroundColor Red; Write-Host ('Mensagem: ' + $_.Exception.Message) -ForegroundColor Yellow; Write-Host ('Linha   : ' + $_.InvocationInfo.ScriptLineNumber) -ForegroundColor Gray; Write-Host ('Stack   : ' + $_.ScriptStackTrace) -ForegroundColor Gray; Write-Host ''; Read-Host 'Pressione Enter para sair' }"
exit /b
::PS_MARKER_START

<#
.SYNOPSIS
    Ferramentas Unificadas de TI: Rede, Reparo, Sistema, Arquivos, Impressoras e Drivers.
.DESCRIPTION
    Versao 4.3 - Correcoes de robustez, deteccao PT-BR, progresso real e resiliencia.
.NOTES
    Autor: Gabriel Lopes
#>

# =============================================================
# INICIALIZACAO
# =============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Continue"
Set-ExecutionPolicy Bypass -Scope Process -Force | Out-Null

# Verifica admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "=====================================================================" -ForegroundColor Red
    Write-Host "   ESTE SCRIPT PRECISA SER EXECUTADO COMO ADMINISTRADOR!" -ForegroundColor Red
    Write-Host "   Feche e execute novamente com 'Executar como administrador'." -ForegroundColor Yellow
    Write-Host "=====================================================================" -ForegroundColor Red
    pause
    exit
}

# =============================================================
# ARTES ASCII (referencia: canivete suico)
# =============================================================

$ArtMain = @(
'                                     .:\  ',
'             /\                     /   : ',
' ''`.         /;Z                    /    / ',
' \  \      /;Z                    /    /  ',
'  \\ \    /;Z                    /  ///   ',
'   \\ \  /;Z                    /  ///    ',
'    \  \/_/____________________/    /     ',
'     `/                         \  /      ',
'     {  o    [+]       o  }''     Y         ',
'      \_________________________/         '
)

$ArtRede = @(
'       \_______/',
'   `.,-''\_____/`-.,''',
'    /`..''\ _ /`.,''\',
'   /  /`.,'' `.,''\  \',
'__/__/__/     \__\__\__',
'  \  \  \     /  /  /',
'   \  \,''`._,''`./  /',
'    \,''`./___\,''`./',
'   ,''`-./_____\,-''`.',
'       /       \'
)

$ArtReparo = @(
'                                           __',
'                               _____....--'' .''',
'                     ___...---''._ o      -`(',
'           ___...---''            \   .--.  `\',
' ___...---''                      |   \   \ `|',
'|                                |o o |  |  |',
'|                                 \___''.-`.  ''.',
'|                                      |   `---''',
'''^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
)

$ArtSistema = @(
'.=====================================================.',
'||   _       _--""--_                                ||',
'||     " --""   |    |   .--.           |    ||      ||',
'||   " . _|     |    |  |    |          |    ||      ||',
'||   _    |  _--""--_|  |----| |.-  .-i |.-. ||      ||',
'||     " --""   |    |  |    | |   |  | |  |         ||',
'||   " . _|     |    |  |    | |    `-( |  | ()      ||',
'||   _    |  _--""--_|             |  |              ||',
'||     " --""                      `--''              ||',
'`=====================================================`'
)

$ArtArquivos = @(
'       .--.                   .---.',
'   .---|__|           .-.     |~~~|',
'.--|===|--|_          |_|     |~~~|--.',
'|  |===|  |''\     .---!~|  .--|   |--|',
'|%%|   |  |.''\    |===| |--|%%|   |  |',
'|%%|   |  |\.''\   |   | |__|  |   |  |',
'|  |   |  | \  \  |===| |==|  |   |  |',
'|  |   |__|  \.''\ |   |_|__|  |~~~|__|',
'|  |===|--|   \.''\|===|~|--|%%|~~~|--|',
'^--^---''--^    `-''`---^-^--^--^---''--'''
)

$ArtImpressoras = @(
',----,------------------------------,------.',
'| ## |                              |    - |',
'| ## |                              |    - |',
'|    |------------------------------|    - |',
'|    ||............................||      |',
'|    ||,-                        -.||      |',
'|    ||___                      ___||    ##|',
'|    ||---`--------------------''---||      |',
'`--mb''|_|______________________==__|`------'''
)

$ArtDrivers = @(
'  .-|:""""":""""""''"""""":|-.',
' :  |''----''-------------''|  :',
' :  |               mga  |  :',
' :  | .----------------. |  :',
' :  |[ zip:          [i]]|  :',
' :  |[------------------]|  :',
' :  |[.....        PC100]|  :',
' :  |[::::::..    iomega]|  :',
' :  |""""""""""""""""""""|  :',
' ''--''--------------------''--'''
)

# =============================================================
# FUNCOES AUXILIARES
# =============================================================

function Get-ConsoleWidth {
    try { return [Console]::WindowWidth } catch { return 80 }
}

function Read-KeyChoice {
    try {
        $key = [Console]::ReadKey($true)
        # Esc como "voltar" universal
        if ($key.Key -eq [ConsoleKey]::Escape) { return '0' }
        return $key.KeyChar
    } catch {
        return '0'
    }
}

function Show-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Activity = "Processando",
        [string]$Detail = ""
    )
    if ($Total -le 0) { $Total = 1 }
    $percent = [math]::Round(($Current / $Total) * 100)
    $barWidth = 30
    $filled = [math]::Round(($Current / $Total) * $barWidth)
    if ($filled -gt $barWidth) { $filled = $barWidth }
    $empty = $barWidth - $filled
    $bar = ("#" * $filled) + ("-" * $empty)

    $maxWidth = (Get-ConsoleWidth) - 5
    $overhead = $barWidth + 25
    $detailMax = [Math]::Max(10, $maxWidth - $overhead)
    if ($Detail.Length -gt $detailMax) { $Detail = $Detail.Substring(0, $detailMax - 3) + "..." }

    $line = "[{0}] {1,3}% ({2}/{3}) {4} {5}" -f $bar, $percent, $Current, $Total, $Activity, $Detail
    if ($line.Length -gt $maxWidth) { $line = $line.Substring(0, $maxWidth) }
    Write-Host "`r$line" -NoNewline -ForegroundColor Cyan
}

function Show-Spinner {
    param(
        [string]$Message = "Processando",
        [scriptblock]$Condition
    )
    $spin = @('|','/','-','\')
    $i = 0
    while (& $Condition) {
        Write-Host "`r$($spin[$i % 4]) $Message..." -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
        $i++
    }
    Write-Host "`r$(' ' * ($Message.Length + 15))`r" -NoNewline
}

# --- Centralizacao baseada no canivete suico ---

function Get-ArtCenter {
    param([string[]]$Art)
    $minLeft = [int]::MaxValue
    $maxRight = 0
    foreach ($line in $Art) {
        $trimmed = $line.TrimEnd()
        if ($trimmed.Trim() -eq "") { continue }
        $left = $trimmed.Length - $trimmed.TrimStart().Length
        $right = $trimmed.Length
        if ($left -lt $minLeft) { $minLeft = $left }
        if ($right -gt $maxRight) { $maxRight = $right }
    }
    if ($minLeft -eq [int]::MaxValue) { return 0 }
    return [Math]::Round(($minLeft + $maxRight) / 2)
}

# Cache do centro do canivete (calculado uma vez)
$Global:ArtMainCenter = Get-ArtCenter -Art $ArtMain

function Draw-Header {
    param([string[]]$Art)
    Clear-Host
    if (-not $Art) { $Art = $ArtMain }

    $cleanArt = @()
    foreach ($line in $Art) { $cleanArt += $line.TrimEnd() }
    while ($cleanArt.Count -gt 0 -and $cleanArt[-1].Trim() -eq "") {
        if ($cleanArt.Count -le 1) { $cleanArt = @(); break }
        $cleanArt = $cleanArt[0..($cleanArt.Count - 2)]
    }

    $artCenter = Get-ArtCenter -Art $cleanArt
    $offset = $Global:ArtMainCenter - $artCenter

    foreach ($line in $cleanArt) {
        if ($line.Trim() -eq "") { Write-Host ""; continue }
        $padded = if ($offset -gt 0) {
            (' ' * $offset) + $line
        } elseif ($offset -lt 0) {
            $lead = $line.Length - $line.TrimStart().Length
            $toCut = [Math]::Min(-$offset, $lead)
            $line.Substring($toCut)
        } else { $line }
        Write-Host $padded -ForegroundColor Green
    }
    Write-Host ""
}

# =============================================================
# 1. REDE
# =============================================================

function Menu-Rede {
    do {
        Draw-Header -Art $ArtRede
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "               [ 1. FERRAMENTAS DE REDE ]            " -ForegroundColor Green
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] Ping de Rede (URL ou IP)" -ForegroundColor White
        Write-Host "  [2] Configuracao de Rede (IPConfig /All)" -ForegroundColor White
        Write-Host "  [3] Liberar e Renovar IP (Release / Renew)" -ForegroundColor White
        Write-Host "  [4] Limpar Cache de DNS (FlushDNS)" -ForegroundColor White
        Write-Host ""
        Write-Host "  [0] Voltar ao Menu Principal" -ForegroundColor Red
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " Opcao: " -NoNewline -ForegroundColor Yellow
        $op = Read-KeyChoice
        Write-Host $op
        switch ($op) {
            "1" { Ping-Rede }
            "2" { Configuracao-Rede }
            "3" {
                Write-Host "`nLiberando IP..." -ForegroundColor Yellow
                $r1 = ipconfig /release 2>&1 | Out-String
                if ($r1 -match "error|erro") { Write-Host "[AVISO] $r1" -ForegroundColor Yellow }
                Write-Host "Renovando IP..." -ForegroundColor Yellow
                $r2 = ipconfig /renew 2>&1 | Out-String
                if ($r2 -match "error|erro") { Write-Host "[AVISO] $r2" -ForegroundColor Yellow }
                Write-Host "[SUCESSO] IP renovado." -ForegroundColor Green
                Read-Host "`nPressione Enter para continuar"
            }
            "4" {
                ipconfig /flushdns | Out-Null
                Write-Host "[SUCESSO] Cache DNS limpo." -ForegroundColor Green
                Read-Host "`nPressione Enter para continuar"
            }
        }
    } while ($op -ne "0")
}

function Ping-Rede {
    Clear-Host
    Write-Host "--- PING DE REDE ---`n" -ForegroundColor Cyan
    $ip = Read-Host "Digite o IP ou site (ex: google.com)"
    if ([string]::IsNullOrWhitespace($ip)) { return }
    Write-Host "`n[1] Ping rapido (4 pacotes)  [2] Ping continuo (Ctrl+C para parar)" -ForegroundColor Yellow
    $modo = Read-KeyChoice
    if ($modo -eq "2") {
        ping $ip -t
    } else {
        ping $ip -n 4
        Read-Host "`nPressione Enter para continuar"
    }
}

function Configuracao-Rede {
    Clear-Host
    Write-Host "--- CONFIGURACOES DE REDE ---`n" -ForegroundColor Cyan
    ipconfig /all
    Read-Host "`nPressione Enter para continuar"
}

# =============================================================
# 2. REPARO
# =============================================================

function Menu-Reparo {
    do {
        Draw-Header -Art $ArtReparo
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "             [ 2. FERRAMENTAS DE REPARO ]            " -ForegroundColor Green
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] Correcao de Sistema Leve (FlushDNS/Temp)" -ForegroundColor White
        Write-Host "  [2] Correcao de Sistema Media (SFC /Scannow)" -ForegroundColor White
        Write-Host "  [3] Correcao Avancada (DISM + SFC + WinSxS)" -ForegroundColor White
        Write-Host "  [4] Gerenciador de Tarefas / Processos" -ForegroundColor White
        Write-Host "  [5] Limpeza de Temporarios" -ForegroundColor White
        Write-Host "  [6] Verificar Disco (CHKDSK com Diagnostico)" -ForegroundColor White
        Write-Host ""
        Write-Host "  [0] Voltar ao Menu Principal" -ForegroundColor Red
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " Opcao: " -NoNewline -ForegroundColor Yellow
        $op = Read-KeyChoice
        Write-Host $op
        switch ($op) {
            "1" {
                ipconfig /flushdns | Out-Null
                Write-Host "[SUCESSO] Cache de DNS limpo." -ForegroundColor Green
                Read-Host "`nPressione Enter para continuar"
            }
            "2" {
                Write-Host "`nIniciando SFC /scannow..." -ForegroundColor Yellow
                sfc /scannow
                Read-Host "`nPressione Enter para continuar"
            }
            "3" {
                Write-Host "`n[1/3] DISM RestoreHealth..." -ForegroundColor Yellow
                dism /online /cleanup-image /restorehealth
                Write-Host "`n[2/3] SFC /scannow..." -ForegroundColor Yellow
                sfc /scannow
                Write-Host "`n[3/3] DISM StartComponentCleanup (WinSxS)..." -ForegroundColor Yellow
                dism /online /cleanup-image /startcomponentcleanup
                Write-Host "`n[SUCESSO] Reparo avancado concluido." -ForegroundColor Green
                Read-Host "`nPressione Enter para continuar"
            }
            "4" { Gerenciador-Tarefas }
            "5" { Limpeza-Temporarios }
            "6" { Verificar-Disco }
        }
    } while ($op -ne "0")
}

function Gerenciador-Tarefas {
    Clear-Host
    Write-Host "--- GERENCIADOR DE PROCESSOS ---`n" -ForegroundColor Cyan
    Write-Host "[1] Listar Processos Ativos (Mais pesados)" -ForegroundColor White
    Write-Host "[2] Finalizar Processo por PID" -ForegroundColor White
    Write-Host "[3] Finalizar Processo por Nome" -ForegroundColor White
    Write-Host "[0] Voltar" -ForegroundColor Red
    Write-Host "`nEscolha: " -NoNewline -ForegroundColor Yellow
    $op = Read-KeyChoice
    Write-Host $op
    if ($op -eq "1") {
        Get-Process | Sort-Object -Property WorkingSet64 -Descending |
            Select-Object -First 20 -Property Id, ProcessName, @{N='RAM (MB)';E={[math]::Round($_.WorkingSet64 / 1MB, 2)}} | Format-Table -AutoSize
        Read-Host "`nPressione Enter para continuar"
    } elseif ($op -eq "2") {
        $pidNum = Read-Host "Digite o PID"
        if ($pidNum -match '^\d+$') {
            try { Stop-Process -Id $pidNum -Force -ErrorAction Stop; Write-Host "[SUCESSO] Finalizado." -ForegroundColor Green }
            catch { Write-Host "[ERRO] $_" -ForegroundColor Red }
        }
        Read-Host "`nPressione Enter para continuar"
    } elseif ($op -eq "3") {
        $pName = Read-Host "Digite o nome (sem .exe)"
        if ($pName) {
            try { Stop-Process -Name $pName -Force -ErrorAction Stop; Write-Host "[SUCESSO] Finalizado." -ForegroundColor Green }
            catch { Write-Host "[ERRO] $_" -ForegroundColor Red }
        }
        Read-Host "`nPressione Enter para continuar"
    }
}

function Limpeza-Temporarios {
    Clear-Host
    Write-Host "--- LIMPEZA DE TEMPORARIOS ---`n" -ForegroundColor Cyan
    $locais = @("$env:TEMP", "$env:SystemRoot\Temp", "$env:LOCALAPPDATA\Temp")
    $totalArquivos = 0
    $falhas = 0
    foreach ($local in $locais) {
        if (Test-Path $local) {
            $antes = (Get-ChildItem $local -Recurse -Force -ErrorAction SilentlyContinue).Count
            Remove-Item "$local\*" -Recurse -Force -ErrorAction SilentlyContinue
            $depois = (Get-ChildItem $local -Recurse -Force -ErrorAction SilentlyContinue).Count
            $removidos = $antes - $depois
            $totalArquivos += $removidos
            $falhas += $depois
            Write-Host "  $local -> $removidos removidos" -ForegroundColor White
        }
    }
    Write-Host "`n[SUCESSO] Total removido: $totalArquivos arquivos" -ForegroundColor Green
    if ($falhas -gt 0) { Write-Host "[AVISO] $falhas arquivos em uso nao puderam ser removidos." -ForegroundColor Yellow }
    Read-Host "Pressione Enter para continuar"
}

function Verificar-Disco {
    Clear-Host
    Write-Host "--- DIAGNOSTICO DE DISCO (CHKDSK) ---`n" -ForegroundColor Cyan
    Write-Host "Executando varredura em C:..." -ForegroundColor Yellow
    $out = chkdsk C: 2>&1 | Out-String
    Write-Host $out

    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "          RESUMO DO DIAGNOSTICO           " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan

    # Deteccao PT-BR + EN
    $saudavel = $out -match "found no problems|nao encontrou problemas|não encontrou problemas|no problems found|Windows has checked"
    $comErros = $out -match "found errors|encontrou erros|errors found"

    if ($comErros) {
        Write-Host "STATUS: ATENCAO! Foram encontrados erros no sistema de arquivos." -ForegroundColor Red
        $agendar = Read-Host "`nDeseja agendar CHKDSK /F para o proximo reboot? (S/N)"
        if ($agendar -match "^[Ss]$") {
            chkdsk C: /f
            Write-Host "[SUCESSO] Agendado para o proximo reboot." -ForegroundColor Green
        }
    } elseif ($saudavel) {
        Write-Host "STATUS: O disco esta SAUDAVEL." -ForegroundColor Green
    } else {
        Write-Host "STATUS: Varredura concluida sem alertas criticos." -ForegroundColor Yellow
    }
    Read-Host "`nPressione Enter para continuar"
}

# =============================================================
# 3. SISTEMA
# =============================================================

function Menu-Sistema {
    do {
        Draw-Header -Art $ArtSistema
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "            [ 3. INFORMACOES E SISTEMA ]             " -ForegroundColor Green
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] Informacoes Detalhadas do Hardware e OS" -ForegroundColor White
        Write-Host "  [2] Agendar Desligar ou Reiniciar" -ForegroundColor White
        Write-Host "  [3] Ativar Windows / Office (MAS Script)" -ForegroundColor White
        Write-Host "  [4] Diagnostico / Chave do Windows" -ForegroundColor White
        Write-Host "  [5] Diagnostico / Chave do Office" -ForegroundColor White
        Write-Host "  [6] Chutar Chave do Windows (coringa *)" -ForegroundColor White
        Write-Host ""
        Write-Host "  [0] Voltar ao Menu Principal" -ForegroundColor Red
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " Opcao: " -NoNewline -ForegroundColor Yellow
        $op = Read-KeyChoice
        Write-Host $op
        switch ($op) {
            "1" { Informacoes-Sistema }
            "2" { Agendar-Desligamento }
            "3" { Ativar-Windows-Office }
            "4" { Get-WindowsKey }
            "5" { Get-OfficeKey }
            "6" { Chutar-Chave-Windows }
        }
    } while ($op -ne "0")
}

function Informacoes-Sistema {
    Clear-Host
    Write-Host "--- INFORMACOES DO SISTEMA ---`n" -ForegroundColor Cyan
    $os = Get-CimInstance Win32_OperatingSystem
    $installDate = $os.InstallDate.ToString("dd/MM/yyyy HH:mm:ss")
    $uptime = (Get-Date) - $os.LastBootUpTime
    $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $ramGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
    $mb = Get-CimInstance Win32_BaseBoard
    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    $nets = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True"

    Write-Host "SISTEMA OPERACIONAL" -ForegroundColor Yellow
    Write-Host "  Nome/Edicao    : $($os.Caption)" -ForegroundColor White
    Write-Host "  Versao/Build   : $($os.Version) (Build $($os.BuildNumber))" -ForegroundColor White
    Write-Host "  Arquitetura    : $($os.OSArchitecture)" -ForegroundColor White
    Write-Host "  Ultima Formata : $installDate" -ForegroundColor Cyan
    Write-Host "  Uptime         : $uptimeStr" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "HARDWARE PRINCIPAL" -ForegroundColor Yellow
    Write-Host "  Processador    : $($cpu.Name.Trim())" -ForegroundColor White
    Write-Host "  Memoria RAM    : $ramGB GB" -ForegroundColor White
    Write-Host "  Placa-Mae      : $($mb.Manufacturer) - $($mb.Product)" -ForegroundColor White
    Write-Host "  Placa de Video : $($gpu.Name)" -ForegroundColor White
    Write-Host ""
    Write-Host "REDE E CONECTIVIDADE" -ForegroundColor Yellow
    if ($nets) {
        foreach ($net in $nets) {
            $ipAddr = if ($net.IPAddress) { $net.IPAddress[0] } else { "N/A" }
            Write-Host "  Adaptador      : $($net.Description)" -ForegroundColor White
            Write-Host "    IP           : $ipAddr" -ForegroundColor Gray
            Write-Host "    MAC          : $($net.MACAddress)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [Nenhum adaptador ativo encontrado]" -ForegroundColor Gray
    }
    Write-Host "==========================================" -ForegroundColor Cyan
    Read-Host "`nPressione Enter para continuar"
}

function Agendar-Desligamento {
    Clear-Host
    Write-Host "--- AGENDAR DESLIGAMENTO/REINICIO ---`n" -ForegroundColor Cyan
    Write-Host "[1] Desligar  [2] Reiniciar  [3] Cancelar  [0] Voltar" -ForegroundColor White
    Write-Host "`nEscolha: " -NoNewline -ForegroundColor Yellow
    $op = Read-KeyChoice
    Write-Host $op
    if ($op -eq "1" -or $op -eq "2") {
        $unidade = Read-Host "`n[1] Minutos  [2] Horas"
        $qtde = Read-Host "Quantidade (numeros)"
        if ($qtde -match '^\d+$') {
            $seg = if ($unidade -eq "1") { [int]$qtde * 60 } else { [int]$qtde * 3600 }
            if ($op -eq "1") { shutdown -s -t $seg; Write-Host "[OK] Desligamento em $qtde." -ForegroundColor Green }
            else { shutdown -r -t $seg; Write-Host "[OK] Reinicio em $qtde." -ForegroundColor Green }
        } else { Write-Host "Invalido!" -ForegroundColor Red }
    } elseif ($op -eq "3") {
        shutdown -a 2>$null
        Write-Host "[OK] Agendamento cancelado." -ForegroundColor Green
    }
    Read-Host "`nPressione Enter para continuar"
}

function Ativar-Windows-Office {
    Clear-Host
    Write-Host "--- ATIVACAO VIA MAS SCRIPT ---`n" -ForegroundColor Cyan
    Write-Host "Executa o Microsoft Activation Scripts oficial." -ForegroundColor Yellow
    Write-Host "Requer internet." -ForegroundColor Yellow
    $c = Read-Host "`nExecutar agora? (S/N)"
    if ($c -match "^[Ss]$") {
        try {
            irm https://get.activated.win | iex
        } catch {
            Write-Host "[ERRO] Falha ao executar MAS: $_" -ForegroundColor Red
        }
    }
    Read-Host "`nPressione Enter para continuar"
}

function Get-WindowsKey {
    Clear-Host
    Write-Host "--- DIAGNOSTICO DE LICENCA DO WINDOWS ---`n" -ForegroundColor Cyan

    $osInfo = Get-CimInstance Win32_OperatingSystem
    Write-Host "Edicao : $($osInfo.Caption)" -ForegroundColor White
    Write-Host "Build  : $($osInfo.Version) ($($osInfo.BuildNumber))" -ForegroundColor Gray
    Write-Host "-----------------------------------------------------------------" -ForegroundColor Gray

    $foundAny = $false

    # [1] Chave OEM na BIOS
    try {
        $biosKey = (Get-CimInstance -Query 'select OA3xOriginalProductKey from SoftwareLicensingService').OA3xOriginalProductKey
        if ($biosKey -and $biosKey.Trim() -ne "") {
            $foundAny = $true
            Write-Host "`n[1] CHAVE OEM (BIOS/UEFI)" -ForegroundColor Green
            Write-Host "    Chave Completa : $biosKey" -ForegroundColor Yellow
            Write-Host "    Tipo           : OEM (vinculada a placa-mae, nao transferivel)" -ForegroundColor Gray
        }
    } catch {}

    # [2] Licenca instalada
    try {
        $digitalLic = Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND Name LIKE 'Windows%'" |
                      Where-Object { $_.ApplicationId -eq '55c9273a-2b2c-4032-9916-e0625a639257' } |
                      Select-Object -First 1
        if ($digitalLic) {
            $foundAny = $true
            $licFamily = $digitalLic.LicenseFamily
            $licStatus = if ($digitalLic.LicenseStatus -eq 1) { "Ativado" } else { "Nao Ativado" }
            Write-Host "`n[2] LICENCA INSTALADA" -ForegroundColor Green
            Write-Host "    Ultimos 5 digitos : .....-.....-.....-.....-$($digitalLic.PartialProductKey)" -ForegroundColor Yellow
            Write-Host "    Familia           : $licFamily" -ForegroundColor White
            Write-Host "    Status            : $licStatus" -ForegroundColor $(if ($digitalLic.LicenseStatus -eq 1) { "Green" } else { "Red" })
            Write-Host "    Descricao         : $($digitalLic.Description)" -ForegroundColor Gray

            if ($licFamily -match "Digital") {
                Write-Host "    Tipo              : LICENCA DIGITAL (hardware + conta Microsoft)" -ForegroundColor Cyan
            } elseif ($licFamily -match "Retail") {
                Write-Host "    Tipo              : RETAIL (transferivel)" -ForegroundColor Cyan
            } elseif ($licFamily -match "Volume:GVLK") {
                Write-Host "    Tipo              : VOLUME KMS (ativacao corporativa)" -ForegroundColor Cyan
            } elseif ($licFamily -match "Volume:MAK") {
                Write-Host "    Tipo              : VOLUME MAK (lote)" -ForegroundColor Cyan
            } elseif ($licFamily -match "OEM") {
                Write-Host "    Tipo              : OEM (via registro)" -ForegroundColor Cyan
            }
        }
    } catch {}

    # [3] Canal via slmgr /dli (PT-BR + EN)
    try {
        $dli = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /dli 2>&1 | Out-String
        if ($dli -match "RETAIL|OEM|VOLUME|MAK|KMS|Varejo|Corporativ") {
            $foundAny = $true
            $channel = if ($dli -match "RETAIL|Varejo") { "RETAIL" }
                       elseif ($dli -match "OEM") { "OEM" }
                       elseif ($dli -match "KMS") { "VOLUME: KMS" }
                       elseif ($dli -match "MAK") { "VOLUME: MAK" }
                       else { "Desconhecido" }
            Write-Host "`n[3] CANAL DE ATIVACAO" -ForegroundColor Green
            Write-Host "    Canal : $channel" -ForegroundColor Yellow
        }
    } catch {}

    # [4] Status geral via /xpr (PT-BR + EN)
    try {
        $xpr = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /xpr 2>&1 | Out-String
        if ($xpr -match "permanently activated|ativado permanentemente|permanentemente ativado") {
            Write-Host "`n[4] STATUS GERAL" -ForegroundColor Green
            Write-Host "    Windows PERMANENTEMENTE ATIVADO." -ForegroundColor Green
        } elseif ($xpr -match "Notification mode|modo de notifica|notificacao") {
            Write-Host "`n[4] STATUS GERAL" -ForegroundColor Yellow
            Write-Host "    Windows em MODO DE NOTIFICACAO (nao ativado)." -ForegroundColor Yellow
        }
    } catch {}

    if (-not $foundAny) {
        Write-Host "`n[AVISO] Nenhuma chave ou licenca valida encontrada." -ForegroundColor Yellow
    }
    Read-Host "`nPressione Enter para continuar"
}

function Get-OfficeKey {
    Clear-Host
    Write-Host "--- DIAGNOSTICO DE LICENCA DO OFFICE ---`n" -ForegroundColor Cyan

    # Detecta Click-to-Run (Office 365/2016+ via Store)
    $c2rFound = $false
    try {
        $c2r = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -ErrorAction Stop
        if ($c2r) {
            $c2rFound = $true
            Write-Host "[INFO] Office Click-to-Run detectado" -ForegroundColor Cyan
            Write-Host "  ProductReleaseIds : $($c2r.ProductReleaseIds)" -ForegroundColor White
            Write-Host "  Versao            : $($c2r.VersionToReport)" -ForegroundColor White
            Write-Host ""
        }
    } catch {}

    $officePaths = @(
        "${env:ProgramFiles}\Microsoft Office\Office16",
        "${env:ProgramFiles(x86)}\Microsoft Office\Office16",
        "${env:ProgramFiles}\Microsoft Office\Office15",
        "${env:ProgramFiles(x86)}\Microsoft Office\Office15",
        "${env:ProgramFiles}\Microsoft Office\root\Office16",
        "${env:ProgramFiles(x86)}\Microsoft Office\root\Office16"
    )

    $officeFound = $false
    foreach ($path in $officePaths) {
        $osppScript = Join-Path $path "OSPP.VBS"
        if (Test-Path $osppScript) {
            $officeFound = $true
            Write-Host "Consultando OSPP..." -ForegroundColor Yellow
            $output = cscript //nologo "$osppScript" /dstatus 2>&1 | Out-String
            $products = $output -split "LICENSE NAME:" | Where-Object { $_ -match "LICENSE STATUS:|STATUS:" }

            if ($products.Count -gt 0) {
                $count = 1
                foreach ($prod in $products) {
                    $lines = $prod -split "`n"
                    $name = ($lines | Where-Object { $_ -match "^\s*\S" } | Select-Object -First 1).Trim()
                    $key = if ($prod -match "(?:Last 5 characters|Ultimos 5 caracteres)[^:]*:\s*(\S+)") { $matches[1] } else { "N/A" }
                    $status = if ($prod -match "LICENSED|ATIVADO") { "Ativado" } else { "Nao Ativado" }
                    $color = if ($prod -match "LICENSED|ATIVADO") { "Green" } else { "Red" }

                    Write-Host "`n------------------------------------------" -ForegroundColor Gray
                    Write-Host " LICENCA #$count" -ForegroundColor Green
                    Write-Host " Produto : $name" -ForegroundColor White
                    Write-Host " Chave   : $key" -ForegroundColor Green
                    Write-Host " Status  : $status" -ForegroundColor $color
                    $count++
                }
            } else {
                Write-Host "[AVISO] Nenhuma licenca OSPP encontrada." -ForegroundColor Yellow
            }
            break
        }
    }

    if (-not $officeFound) {
        if ($c2rFound) {
            Write-Host "[INFO] Office Click-to-Run nao usa OSPP.VBS." -ForegroundColor Yellow
            Write-Host "       Use 'Ativar Windows/Office (MAS)' ou verifique no Office." -ForegroundColor Yellow
        } else {
            Write-Host "[ERRO] Office nao localizado." -ForegroundColor Red
        }
    }
    Read-Host "`nPressione Enter para continuar"
}

function Chutar-Chave-Windows {
    Clear-Host
    Write-Host "--- CHUTADOR DE CHAVE DO WINDOWS ---`n" -ForegroundColor Cyan

    $osAlvos = @(
        "Windows 7 Starter","Windows 7 Home Basic","Windows 7 Home Premium",
        "Windows 7 Professional","Windows 7 Ultimate","Windows 7 Enterprise",
        "Windows 8.1","Windows 8.1 Pro","Windows 8.1 Enterprise",
        "Windows 10 Home","Windows 10 Pro","Windows 10 Pro N",
        "Windows 10 Education","Windows 10 Enterprise","Windows 10 Enterprise LTSC",
        "Windows 11 Home","Windows 11 Pro","Windows 11 Pro N",
        "Windows 11 Education","Windows 11 Enterprise","Windows 11 Enterprise LTSC",
        "Windows Server 2008 Standard","Windows Server 2008 Enterprise",
        "Windows Server 2008 R2 Standard","Windows Server 2008 R2 Enterprise",
        "Windows Server 2012 Standard","Windows Server 2012 Datacenter",
        "Windows Server 2012 R2 Standard","Windows Server 2012 R2 Datacenter",
        "Windows Server 2016 Standard","Windows Server 2016 Datacenter","Windows Server 2016 Essentials",
        "Windows Server 2019 Standard","Windows Server 2019 Datacenter","Windows Server 2019 Essentials",
        "Windows Server 2022 Standard","Windows Server 2022 Datacenter",
        "Windows Server 2025 Standard","Windows Server 2025 Datacenter"
    )

    Write-Host "`n  --- DESKTOP ---" -ForegroundColor DarkCyan
    for ($i = 0; $i -lt 21; $i++) { Write-Host (" [{0,2}] {1}" -f ($i + 1), $osAlvos[$i]) -ForegroundColor White }
    Write-Host "`n  --- SERVER ---" -ForegroundColor DarkCyan
    for ($i = 21; $i -lt 39; $i++) { Write-Host (" [{0,2}] {1}" -f ($i + 1), $osAlvos[$i]) -ForegroundColor White }
    Write-Host "`n [40] Outro" -ForegroundColor Cyan

    $escolha = Read-Host "`n SO alvo (1-40)"
    $escolhaNum = 0
    if (-not [int]::TryParse($escolha, [ref]$escolhaNum)) { Write-Host "Invalido." -ForegroundColor Red; Read-Host; return }

    $soAlvo = if ($escolhaNum -ge 1 -and $escolhaNum -le 39) { $osAlvos[$escolhaNum - 1] }
              elseif ($escolhaNum -eq 40) { Read-Host "Nome exato do SO" }
              else { Write-Host "Invalido." -ForegroundColor Red; Read-Host; return }

    Write-Host "`n SO alvo: $soAlvo" -ForegroundColor Green
    Write-Host "`nFormato: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX  (* para desconhecidos)" -ForegroundColor White
    Write-Host "Exemplo: NPPR9-FWDCX-D2C8J-*****-*****`n" -ForegroundColor Gray

    # Verifica se ha progresso salvo
    $stateFile = Join-Path $env:TEMP "chute_progress.json"
    $resume = $false
    if (Test-Path $stateFile) {
        $state = Get-Content $stateFile -Raw | ConvertFrom-Json
        Write-Host "[INFO] Progresso anterior encontrado:" -ForegroundColor Yellow
        Write-Host "  Padrao   : $($state.pattern)" -ForegroundColor White
        Write-Host "  SO alvo  : $($state.soAlvo)" -ForegroundColor White
        Write-Host "  Tentativa: $($state.indice) de $($state.total)" -ForegroundColor White
        $r = Read-Host "`nRetomar de onde parou? (S/N)"
        if ($r -match "^[Ss]$") { $resume = $true; $pattern = $state.pattern; $soAlvo = $state.soAlvo; $startIndex = [long]$state.indice }
        else { Remove-Item $stateFile -Force }
    }

    if (-not $resume) {
        $pattern = (Read-Host "Chave (com *)").Trim().ToUpper()
        $startIndex = 0
    }

    $raw = $pattern -replace '-', ''
    if ($raw.Length -ne 25) { Write-Host "[ERRO] Precisa ter 25 caracteres." -ForegroundColor Red; Read-Host; return }
    if ($raw -notmatch '^[A-Z0-9\*]+$') { Write-Host "[ERRO] Caractere invalido." -ForegroundColor Red; Read-Host; return }

    $asteriscos = ($raw.ToCharArray() | Where-Object { $_ -eq '*' }).Count
    $validCharsArr = "BCDFGHJKMPQRTVWXY23456789".ToCharArray()
    $total = [long][math]::Pow($validCharsArr.Length, $asteriscos)

    if ($asteriscos -gt 0 -and -not $resume) {
        $segPorTentativa = 1.2
        $tempoTotal = $total * $segPorTentativa
        $tempoFmt = if ($tempoTotal -lt 60) { "{0:N0}s" -f $tempoTotal }
                    elseif ($tempoTotal -lt 3600) { "{0:N1}min" -f ($tempoTotal / 60) }
                    elseif ($tempoTotal -lt 86400) { "{0:N1}h" -f ($tempoTotal / 3600) }
                    elseif ($tempoTotal -lt 31536000) { "{0:N1}d" -f ($tempoTotal / 86400) }
                    else { "{0:N1}anos" -f ($tempoTotal / 31536000) }

        Write-Host "`n=====================================================" -ForegroundColor Cyan
        Write-Host "          ESTIMATIVA                                 " -ForegroundColor Cyan
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " Combinacoes : $('{0:N0}' -f $total)" -ForegroundColor Yellow
        Write-Host " Tempo       : $tempoFmt" -ForegroundColor Yellow
        Write-Host "=====================================================" -ForegroundColor Cyan
        if ($total -gt 100000) { Write-Host "`n[ATENCAO] Pode demorar muito. Recomendado: max 4 asteriscos." -ForegroundColor Red }

        $c = Read-Host "`nIniciar? (S/N)"
        if ($c -notmatch "^[Ss]$") { return }
    }

    # Mapeia edicao alvo
    $alvoLower = $soAlvo.ToLower()
    $expectedEdition = "Professional"
    if ($alvoLower -match "starter")           { $expectedEdition = "Starter" }
    elseif ($alvoLower -match "home basic")    { $expectedEdition = "Home Basic" }
    elseif ($alvoLower -match "home premium")  { $expectedEdition = "Home Premium" }
    elseif ($alvoLower -match "home")          { $expectedEdition = "Core" }
    elseif ($alvoLower -match "ultimate")      { $expectedEdition = "Ultimate" }
    elseif ($alvoLower -match "education")     { $expectedEdition = "Education" }
    elseif ($alvoLower -match "ltsc")          { $expectedEdition = "EnterpriseS" }
    elseif ($alvoLower -match "enterprise")    { $expectedEdition = "Enterprise" }
    elseif ($alvoLower -match "datacenter")    { $expectedEdition = "Datacenter" }
    elseif ($alvoLower -match "essentials")    { $expectedEdition = "Essentials" }
    elseif ($alvoLower -match "standard")      { $expectedEdition = "Standard" }
    elseif ($alvoLower -match "pro n")         { $expectedEdition = "Professional N" }
    elseif ($alvoLower -match "pro")           { $expectedEdition = "Professional" }

    # Indices dos asteriscos
    $astIdx = @()
    for ($i = 0; $i -lt 25; $i++) { if ($raw[$i] -eq '*') { $astIdx += $i } }

    $baseArray = $raw.ToCharArray()
    $tentativa = $startIndex
    $encontrou = $false
    $inicio = Get-Date
    $lastSave = Get-Date

    Write-Host "`nIniciando chute... (Ctrl+C para pausar/sair)`n" -ForegroundColor Yellow

    try {
        for ($i = $startIndex; $i -lt $total; $i++) {
            $tentativa++
            $idx = $i
            $chaveArr = $baseArray.Clone()
            for ($p = $asteriscos - 1; $p -ge 0; $p--) {
                $chaveArr[$astIdx[$p]] = $validCharsArr[$idx % $validCharsArr.Length]
                $idx = [math]::Floor($idx / $validCharsArr.Length)
            }
            $chaveFinal = -join $chaveArr
            $chaveFmt = ($chaveFinal -replace '(.{5})(?=.)', '$1-')

            # Barra de progresso
            $percent = [math]::Round(($tentativa / $total) * 100)
            $barWidth = 25
            $filled = [math]::Round(($tentativa / $total) * $barWidth)
            if ($filled -gt $barWidth) { $filled = $barWidth }
            $bar = ("#" * $filled) + ("-" * ($barWidth - $filled))
            $decorrido = (Get-Date) - $inicio
            $media = if (($tentativa - $startIndex) -gt 0) { $decorrido.TotalSeconds / ($tentativa - $startIndex) } else { 1.2 }
            $restantes = $total - $tentativa
            $eta = [TimeSpan]::FromSeconds([math]::Round($media * $restantes))
            $linha = "[{0}] {1,3}% ({2}/{3}) ETA: {4:hh\:mm\:ss} - {5}" -f $bar, $percent, $tentativa, $total, $eta, $chaveFmt
            if ($linha.Length -gt 110) { $linha = $linha.Substring(0, 110) }
            Write-Host "`r$linha" -NoNewline -ForegroundColor Cyan

            # Salva progresso a cada 30 segundos
            if (((Get-Date) - $lastSave).TotalSeconds -ge 30) {
                @{ pattern = $pattern; soAlvo = $soAlvo; indice = $tentativa; total = $total } |
                    ConvertTo-Json | Out-File $stateFile -Encoding UTF8
                $lastSave = Get-Date
            }

            # Testa a chave
            $res = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /ipk $chaveFmt 2>&1 | Out-String

            if ($res -match "instalada com .xito|installed successfully|product key installed successfully|instalada com sucesso") {
                $dli = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /dli 2>&1 | Out-String
                if ($dli -match $expectedEdition) {
                    $ato = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /ato 2>&1 | Out-String
                    if ($ato -match "activated successfully|ativado com .xito|Product activated|ativado com sucesso") {
                        $xpr = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /xpr 2>&1 | Out-String
                        if ($xpr -match "permanently|permanentemente") {
                            $encontrou = $true
                            Write-Host "`n`n=====================================================" -ForegroundColor Green
                            Write-Host "        CHAVE ENCONTRADA E ATIVADA!                  " -ForegroundColor Green
                            Write-Host "=====================================================" -ForegroundColor Green
                            Write-Host " SO alvo      : $soAlvo" -ForegroundColor White
                            Write-Host " Chave Valida : $chaveFmt" -ForegroundColor Yellow
                            Write-Host " Tentativas   : $tentativa de $total" -ForegroundColor White
                            Write-Host " Tempo total  : $($decorrido.ToString('hh\:mm\:ss'))" -ForegroundColor White
                            Write-Host "=====================================================" -ForegroundColor Green

                            $logPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "chave_encontrada.txt"
                            "Chave: $chaveFmt`nSO: $soAlvo`nTentativas: $tentativa`nData: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" | Out-File $logPath -Encoding UTF8
                            Write-Host "`nSalva em: $logPath" -ForegroundColor Yellow
                            if (Test-Path $stateFile) { Remove-Item $stateFile -Force }
                            break
                        }
                    }
                }
            }
        }
    } catch {
        Write-Host "`n`n[INFO] Interrompido pelo usuario ou erro." -ForegroundColor Yellow
        @{ pattern = $pattern; soAlvo = $soAlvo; indice = $tentativa; total = $total } |
            ConvertTo-Json | Out-File $stateFile -Encoding UTF8
        Write-Host "[INFO] Progresso salvo. Voce pode retomar depois." -ForegroundColor Cyan
    }

    if (-not $encontrou -and $tentativa -ge $total) {
        Write-Host "`n`n=====================================================" -ForegroundColor Red
        Write-Host "        NENHUMA CHAVE VALIDA ENCONTRADA              " -ForegroundColor Red
        Write-Host "=====================================================" -ForegroundColor Red
        Write-Host " SO alvo    : $soAlvo" -ForegroundColor White
        Write-Host " Tentativas : $tentativa de $total" -ForegroundColor White
        if (Test-Path $stateFile) { Remove-Item $stateFile -Force }
    }

    Read-Host "`nPressione Enter para continuar"
}

# =============================================================
# 4. ARQUIVOS
# =============================================================

function Menu-Arquivos {
    do {
        Draw-Header -Art $ArtArquivos
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "              [ 4. GESTAO DE ARQUIVOS ]              " -ForegroundColor Green
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] Backup de Arquivos (Robocopy)" -ForegroundColor White
        Write-Host "  [2] Espaco livre em disco" -ForegroundColor White
        Write-Host ""
        Write-Host "  [0] Voltar ao Menu Principal" -ForegroundColor Red
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " Opcao: " -NoNewline -ForegroundColor Yellow
        $op = Read-KeyChoice
        Write-Host $op
        switch ($op) {
            "1" { Backup-Arquivos }
            "2" {
                Clear-Host
                Write-Host "--- ESPACO EM DISCO ---`n" -ForegroundColor Cyan
                Get-PSDrive -PSProvider FileSystem | Select-Object Name,
                    @{N='Usado (GB)';E={[math]::Round(($_.Used)/1GB, 2)}},
                    @{N='Livre (GB)';E={[math]::Round(($_.Free)/1GB, 2)}},
                    @{N='Total (GB)';E={[math]::Round(($_.Used + $_.Free)/1GB, 2)}} | Format-Table -AutoSize
                Read-Host "`nPressione Enter para continuar"
            }
        }
    } while ($op -ne "0")
}

function Backup-Arquivos {
    Clear-Host
    Write-Host "--- BACKUP VIA ROBOCOPY ---`n" -ForegroundColor Cyan
    $source = Read-Host "Origem (ex: C:\Users\Cliente\Documents)"
    $dest = Read-Host "Destino (ex: E:\BackupCliente)"

    if (-not (Test-Path $source)) { Write-Host "[ERRO] Origem invalida." -ForegroundColor Red; Read-Host; return }

    # Verifica espaco livre
    try {
        $destDrive = (Split-Path $dest -Qualifier).TrimEnd(':')
        $free = (Get-PSDrive -Name $destDrive -ErrorAction Stop).Free
        $srcSize = (Get-ChildItem $source -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        if ($free -lt $srcSize) {
            Write-Host "[AVISO] Espaco em disco insuficiente!" -ForegroundColor Red
            Write-Host "  Necessario: $([math]::Round($srcSize/1GB,2)) GB" -ForegroundColor White
            Write-Host "  Livre     : $([math]::Round($free/1GB,2)) GB" -ForegroundColor White
            $c = Read-Host "`nContinuar mesmo assim? (S/N)"
            if ($c -notmatch "^[Ss]$") { return }
        }
    } catch {}

    Write-Host "`nIniciando copia..." -ForegroundColor Yellow
    $robOut = robocopy $source $dest /E /TEE /R:2 /W:2 /NP 2>&1 | Out-String
    $exitCode = $LASTEXITCODE

    Write-Host "`n--- RESULTADO ROBOCOPY ---" -ForegroundColor Cyan
    if ($exitCode -eq 0) { Write-Host "Nenhum arquivo para copiar (tudo sincronizado)." -ForegroundColor Green }
    elseif ($exitCode -eq 1) { Write-Host "[SUCESSO] Arquivos copiados com sucesso." -ForegroundColor Green }
    elseif ($exitCode -eq 2) { Write-Host "[SUCESSO] Arquivos extras detectados no destino." -ForegroundColor Green }
    elseif ($exitCode -eq 4) { Write-Host "[AVISO] Arquivos incompatíveis detectados." -ForegroundColor Yellow }
    elseif ($exitCode -eq 8) { Write-Host "[AVISO] Alguns arquivos falharam (verificar log)." -ForegroundColor Yellow }
    elseif ($exitCode -ge 16) { Write-Host "[ERRO] Falha critica." -ForegroundColor Red }
    else { Write-Host "[INFO] Codigo: $exitCode" -ForegroundColor Gray }

    Read-Host "`nPressione Enter para continuar"
}

# =============================================================
# 5. IMPRESSORAS
# =============================================================

function Menu-Impressoras {
    do {
        Draw-Header -Art $ArtImpressoras
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "         [ 5. GERENCIADOR DE IMPRESSORAS ]           " -ForegroundColor Green
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "IMPRESSORAS INSTALADAS:" -ForegroundColor Yellow
        $printers = Get-CimInstance Win32_Printer -ErrorAction SilentlyContinue
        if ($printers) {
            for ($i = 0; $i -lt $printers.Count; $i++) {
                $p = $printers[$i]
                $st = if ($p.Default) { "[PADRAO]" } else { "" }
                Write-Host "  [$($i + 1)] $($p.Name) (Porta: $($p.PortName)) $st" -ForegroundColor White
            }
        } else {
            Write-Host "  [Nenhuma impressora instalada]" -ForegroundColor Gray
        }
        Write-Host ""
        Write-Host "-----------------------------------------------------" -ForegroundColor Gray
        Write-Host "  [1] Limpeza Profunda do Spooler + Registro" -ForegroundColor White
        Write-Host "  [2] Remover Impressora Instalada" -ForegroundColor White
        Write-Host "  [0] Voltar" -ForegroundColor Red
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " Opcao: " -NoNewline -ForegroundColor Yellow
        $op = Read-KeyChoice
        Write-Host $op
        switch ($op) {
            "1" { Limpeza-Spooler-Avancada }
            "2" { Remover-Impressora -PrintersList $printers }
        }
    } while ($op -ne "0")
}

function Limpeza-Spooler-Avancada {
    Clear-Host
    Write-Host "--- LIMPEZA PROFUNDA DO SPOOLER ---`n" -ForegroundColor Cyan

    Write-Host "[1/5] Parando Spooler..." -ForegroundColor Yellow
    Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 800

    # Verifica se parou de fato
    $srv = Get-Service -Name "Spooler" -ErrorAction SilentlyContinue
    if ($srv.Status -ne 'Stopped') {
        Write-Host "      [AVISO] Spooler nao parou. Forcando termino do processo..." -ForegroundColor Yellow
        taskkill /F /IM spoolsv.exe 2>$null | Out-Null
        Start-Sleep -Milliseconds 800
    }
    Write-Host "      -> Spooler parado." -ForegroundColor Green

    Write-Host "[2/5] Limpando pasta PRINTERS..." -ForegroundColor Yellow
    $spoolPath = "$env:SystemRoot\System32\spool\PRINTERS"
    $count = 0
    Get-ChildItem $spoolPath -Force -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path $_.FullName)) { $count++ }
    }
    Write-Host "      -> $count arquivos removidos." -ForegroundColor Green

    Write-Host "[3/5] Limpando conexoes em HKCU..." -ForegroundColor Yellow
    $userConnPath = "HKCU:\Printers\Connections"
    if (Test-Path $userConnPath) {
        Get-ChildItem -Path $userConnPath -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item -Path $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Host "      -> Limpo." -ForegroundColor Green
    }

    Write-Host "[4/5] Resetando pendencias em HKLM..." -ForegroundColor Yellow
    $sysPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers"
    if (Test-Path $sysPath) {
        Get-ChildItem -Path $sysPath -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-ItemProperty -Path $_.PSPath -Name "SpoolFile" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $_.PSPath -Name "Attributes" -ErrorAction SilentlyContinue
        }
        Write-Host "      -> Resetado." -ForegroundColor Green
    }

    Write-Host "[5/5] Reiniciando Spooler..." -ForegroundColor Yellow
    Start-Service -Name "Spooler" -ErrorAction SilentlyContinue
    Write-Host "`n[SUCESSO] Limpeza concluida!" -ForegroundColor Green
    Read-Host "`nPressione Enter para continuar"
}

function Remover-Impressora {
    param ($PrintersList)
    if (-not $PrintersList) {
        Write-Host "`n[AVISO] Nenhuma impressora disponivel." -ForegroundColor Yellow
        Read-Host "Pressione Enter"
        return
    }
    $idx = Read-Host "`nNumero do indice (0 para cancelar)"
    if ($idx -match '^\d+$' -and [int]$idx -gt 0 -and [int]$idx -le $PrintersList.Count) {
        $target = $PrintersList[[int]$idx - 1]
        try {
            Remove-CimInstance -InputObject $target -ErrorAction Stop
            Write-Host "[SUCESSO] '$($target.Name)' removida." -ForegroundColor Green
        } catch { Write-Host "[ERRO] $_" -ForegroundColor Red }
    } else {
        Write-Host "Cancelado." -ForegroundColor Yellow
    }
    Read-Host "`nPressione Enter para continuar"
}

# =============================================================
# 6. DRIVERS
# =============================================================

function Menu-Drivers {
    do {
        Draw-Header -Art $ArtDrivers
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "           [ 6. GERENCIADOR DE DRIVERS ]             " -ForegroundColor Green
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] Backup de Drivers" -ForegroundColor White
        Write-Host "  [2] Restauracao de Drivers (rapida)" -ForegroundColor White
        Write-Host "  [3] Buscar Atualizacoes (Windows Update)" -ForegroundColor White
        Write-Host ""
        Write-Host "  [0] Voltar ao Menu Principal" -ForegroundColor Red
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " Opcao: " -NoNewline -ForegroundColor Yellow
        $op = Read-KeyChoice
        Write-Host $op
        switch ($op) {
            "1" { Backup-Drivers }
            "2" { Restore-Drivers }
            "3" { Search-DriverUpdates }
        }
    } while ($op -ne "0")
}

function Backup-Drivers {
    Clear-Host
    Write-Host "--- BACKUP DE DRIVERS ---`n" -ForegroundColor Cyan
    $backupPath = (Read-Host "Pasta de destino (ex: D:\DriversBackup)").Trim('"')
    if (-not $backupPath) { Write-Host "Invalido." -ForegroundColor Red; Read-Host; return }
    if (-not (Test-Path $backupPath)) { New-Item -ItemType Directory -Path $backupPath -Force | Out-Null }

    Write-Host "`nExportando drivers de terceiros..." -ForegroundColor Yellow

    # Executa pnputil em background e mostra spinner
    $proc = Start-Process pnputil -ArgumentList "/export-driver * `"$backupPath`"" -NoNewWindow -PassThru
    while (-not $proc.HasExited) {
        Write-Host "`r$('|/-\'[(Get-Random -Max 4)]) Exportando... (pode demorar)" -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
    }
    $proc.WaitForExit()
    Write-Host "`r$(' ' * 60)`r" -NoNewline

    # DISM como redundancia
    Write-Host "Executando DISM export (redundancia)..." -ForegroundColor Yellow
    dism /online /export-driver /destination:"$backupPath" 2>&1 | Out-Null

    # Conta drivers exportados
    $countInf = (Get-ChildItem $backupPath -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue).Count
    Write-Host "[SUCESSO] $countInf driver(s) exportado(s) para: $backupPath" -ForegroundColor Green
    Read-Host "`nPressione Enter para continuar"
}

function Restore-Drivers {
    Clear-Host
    Write-Host "--- RESTAURACAO DE DRIVERS ---`n" -ForegroundColor Cyan
    $backupPath = (Read-Host "Pasta do backup (ex: D:\DriversBackup)").Trim('"')
    if (-not (Test-Path $backupPath)) { Write-Host "[ERRO] Pasta nao existe." -ForegroundColor Red; Read-Host; return }

    $infFiles = @(Get-ChildItem -Path $backupPath -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue)
    if ($infFiles.Count -eq 0) { Write-Host "[AVISO] Nenhum .inf encontrado." -ForegroundColor Yellow; Read-Host; return }

    Write-Host "`nEncontrados $($infFiles.Count) drivers." -ForegroundColor Cyan
    Write-Host "Instalando em lote (rapido)..." -ForegroundColor Yellow

    $logFile = Join-Path $backupPath "log_erros_drivers.txt"
    if (Test-Path $logFile) { Remove-Item $logFile -Force }

    # Executa pnputil em lote com spinner
    $tmpOut = Join-Path $env:TEMP "pnputil_out.txt"
    $proc = Start-Process cmd -ArgumentList "/c pnputil /add-driver `"$backupPath\*.inf`" /subdirs /install > `"$tmpOut`" 2>&1" -NoNewWindow -PassThru
    while (-not $proc.HasExited) {
        Write-Host "`r$('|/-\'[(Get-Random -Max 4)]) Instalando drivers em lote..." -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
    }
    $proc.WaitForExit()
    Write-Host "`r$(' ' * 60)`r" -NoNewline

    # Parse do output
    $output = if (Test-Path $tmpOut) { Get-Content $tmpOut -Raw } else { "" }
    $sucesso = ([regex]::Matches($output, "successfully added|adicionado com .xito|instalado com sucesso|imported successfully")).Count
    $falha = ([regex]::Matches($output, "failed to add|falha|error", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count

    # Fallback se nao conseguiu parsear
    if ($sucesso -eq 0 -and $falha -eq 0) {
        Write-Host "[INFO] pnputil nao reportou contadores individuais." -ForegroundColor Yellow
        Write-Host "       Total de drivers processados: $($infFiles.Count)" -ForegroundColor White
    } else {
        Write-Host "`n==========================================" -ForegroundColor Cyan
        Write-Host "          RESUMO DA INSTALACAO           " -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host " Total processados : $($infFiles.Count)" -ForegroundColor White
        Write-Host " Com SUCESSO       : $sucesso" -ForegroundColor Green
        if ($falha -gt 0) { Write-Host " Com FALHA         : $falha" -ForegroundColor Red }
    }

    # Salva output bruto como log
    $output | Out-File $logFile -Encoding UTF8
    Write-Host "`nLog completo em: $logFile" -ForegroundColor Yellow
    Write-Host "`nRecomenda-se reiniciar o computador." -ForegroundColor Yellow
    if (Test-Path $tmpOut) { Remove-Item $tmpOut -Force }
    Read-Host "`nPressione Enter para continuar"
}

function Search-DriverUpdates {
    Clear-Host
    Write-Host "--- DRIVERS VIA WINDOWS UPDATE ---`n" -ForegroundColor Cyan
    $c = Read-Host "Buscar atualizacoes? (S/N)"
    if ($c -notmatch "^[Ss]$") { return }

    Write-Host "`nConsultando Microsoft Update..." -ForegroundColor Yellow
    try {
        $session = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        $result = $searcher.Search("IsInstalled=0 and Type='Driver'")

        if ($result.Updates.Count -eq 0) {
            Write-Host "[SUCESSO] Nenhum driver pendente." -ForegroundColor Green
        } else {
            Write-Host "`nEncontrado(s) $($result.Updates.Count):" -ForegroundColor Cyan
            $coll = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($u in $result.Updates) { Write-Host " - $($u.Title)" -ForegroundColor White; $coll.Add($u) | Out-Null }

            Write-Host "`nBaixando..." -ForegroundColor Yellow
            $dl = $session.CreateUpdateDownloader(); $dl.Updates = $coll
            if ($dl.Download().ResultCode -eq 2) {
                Write-Host "Instalando..." -ForegroundColor Yellow
                $inst = $session.CreateUpdateInstaller(); $inst.Updates = $coll
                if ($inst.Install().ResultCode -eq 2) { Write-Host "[SUCESSO] Drivers atualizados!" -ForegroundColor Green }
                else { Write-Host "[AVISO] Falha parcial." -ForegroundColor Yellow }
            } else { Write-Host "[ERRO] Falha no download." -ForegroundColor Red }
        }
    } catch { Write-Host "[ERRO] $_" -ForegroundColor Red }
    Read-Host "`nPressione Enter"
}

# =============================================================
# LOOP PRINCIPAL (com try/catch global)
# =============================================================

try {
    $choice = ""
    do {
        Draw-Header -Art $ArtMain
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "        PAINEL DE FERRAMENTAS DE TI - v4.3           " -ForegroundColor Green
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] REDE        (Ping, IPConfig, Release/Renew, DNS)" -ForegroundColor White
        Write-Host "  [2] REPARO      (SFC, DISM, Processos, Temp, CHKDSK)" -ForegroundColor White
        Write-Host "  [3] SISTEMA     (Info, Agendador, Chaves, MAS, Chute)" -ForegroundColor White
        Write-Host "  [4] ARQUIVOS    (Backup Robocopy, Espaco em disco)" -ForegroundColor White
        Write-Host "  [5] IMPRESSORAS (Listagem, Spooler+Regedit, Desinstalar)" -ForegroundColor White
        Write-Host "  [6] DRIVERS     (Backup, Restauracao, Windows Update)" -ForegroundColor White
        Write-Host ""
        Write-Host "  [0] Sair do Programa (ou pressione ESC)" -ForegroundColor Red
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " Escolha uma categoria (1-6): " -NoNewline -ForegroundColor Yellow

        $choice = Read-KeyChoice
        Write-Host $choice

        switch ($choice) {
            "1" { Menu-Rede }
            "2" { Menu-Reparo }
            "3" { Menu-Sistema }
            "4" { Menu-Arquivos }
            "5" { Menu-Impressoras }
            "6" { Menu-Drivers }
            "0" { Write-Host "`nSaindo..." -ForegroundColor Green }
            default { Write-Host "`nOpcao invalida!" -ForegroundColor Red; Start-Sleep -Milliseconds 800 }
        }
    } while ($choice -ne "0")
}
catch {
    Write-Host "`n`n=====================================================" -ForegroundColor Red
    Write-Host "   [ERRO FATAL] O programa encontrou um erro         " -ForegroundColor Red
    Write-Host "=====================================================" -ForegroundColor Red
    Write-Host "Mensagem : $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "Linha    : $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Gray
    Write-Host "Comando  : $($_.InvocationInfo.Line.Trim())" -ForegroundColor Gray
    Write-Host "=====================================================" -ForegroundColor Red

    $logPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "erro_ferramenta_ti.txt"
    "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')`nErro: $($_.Exception.Message)`nLinha: $($_.InvocationInfo.ScriptLineNumber)`nStack: $($_.ScriptStackTrace)" |
        Out-File $logPath -Encoding UTF8
    Write-Host "`nLog salvo em: $logPath" -ForegroundColor Yellow
    Read-Host "`nPressione Enter para sair"
}