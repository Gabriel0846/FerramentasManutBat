@echo off
:: ======================================
:: LANÇADOR INTEGRADO DE FERRAMENTAS v4.2
:: ======================================
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Get-Content '%~f0' -Encoding UTF8 | Select-Object -Skip 8 | Out-String | Invoke-Expression"
exit /b

<#
.SYNOPSIS
    Ferramentas Unificadas de TI, Reparo, Rede, Licenciamento, Impressao, Drivers e Chute de Chave.
.DESCRIPTION
    Estrutura hierarquica com 6 categorias (1 a 6) + chutador de chave com coringa.
.NOTES
    Versao: 4.2
    Autor: Gabriel Lopes
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Set-ExecutionPolicy Bypass -Scope Process -Force | Out-Null

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "=====================================================================" -ForegroundColor Red
    Write-Host "   ESTE SCRIPT PRECISA SER EXECUTADO COMO ADMINISTRADOR!" -ForegroundColor Red
    Write-Host "   Feche e execute novamente clicando com o botao direito e escolhendo" -ForegroundColor Yellow
    Write-Host "   'Executar como administrador'." -ForegroundColor Yellow
    Write-Host "=====================================================================" -ForegroundColor Red
    pause
    exit
}

# --- ARTES ASCII (referencia: canivete suico) ---

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

# --- FUNCOES DE NAVEGACAO ---

function Read-KeyChoice {
    $key = [Console]::ReadKey($true)
    return $key.KeyChar
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
    if ($Detail.Length -gt 40) { $Detail = $Detail.Substring(0, 37) + "..." }
    $line = "[{0}] {1,3}% ({2}/{3}) {4} {5}" -f $bar, $percent, $Current, $Total, $Activity, $Detail
    if ($line.Length -gt 100) { $line = $line.Substring(0, 100) }
    Write-Host "`r$line" -NoNewline -ForegroundColor Cyan
}

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

function Draw-Header {
    param([string[]]$Art)
    Clear-Host
    if (-not $Art) { $Art = $ArtMain }

    # Centro visual do canivete suico (referencia)
    $refCenter = Get-ArtCenter -Art $ArtMain

    # Limpa trailing spaces
    $cleanArt = @()
    foreach ($line in $Art) { $cleanArt += $line.TrimEnd() }

    # Remove linhas vazias no final
    while ($cleanArt.Count -gt 0 -and $cleanArt[-1].Trim() -eq "") {
        if ($cleanArt.Count -le 1) { $cleanArt = @(); break }
        $cleanArt = $cleanArt[0..($cleanArt.Count - 2)]
    }

    # Centro visual da arte atual
    $artCenter = Get-ArtCenter -Art $cleanArt

    # Deslocamento para alinhar os dois centros
    $offset = $refCenter - $artCenter

    foreach ($line in $cleanArt) {
        if ($line.Trim() -eq "") {
            Write-Host ""
            continue
        }
        $padded = if ($offset -gt 0) {
            (' ' * $offset) + $line
        } elseif ($offset -lt 0) {
            $lead = $line.Length - $line.TrimStart().Length
            $toCut = [Math]::Min(-$offset, $lead)
            $line.Substring($toCut)
        } else {
            $line
        }
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
                ipconfig /release | Out-Null
                Write-Host "Renovando IP..." -ForegroundColor Yellow
                ipconfig /renew
                Read-Host "`nPressione Enter para continuar"
            }
            "4" {
                ipconfig /flushdns
                Read-Host "`nPressione Enter para continuar"
            }
        }
    } while ($op -ne "0")
}

function Ping-Rede {
    Clear-Host
    Write-Host "--- PING DE REDE ---`n" -ForegroundColor Cyan
    $ip = Read-Host "Digite o IP ou site para testar (ex: google.com ou 192.168.1.1)"
    if ([string]::IsNullOrWhitespace($ip)) { return }
    Write-Host "`nPressione Ctrl+C para encerrar o teste.`n" -ForegroundColor Yellow
    ping $ip -t
}

function Configuracao-Rede {
    Clear-Host
    Write-Host "--- CONFIGURACOES DE REDE DA MAQUINA ---`n" -ForegroundColor Cyan
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
        Write-Host "  [3] Correcao Avancada (DISM + SFC)" -ForegroundColor White
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
                ipconfig /flushdns
                Write-Host "[SUCESSO] Cache de DNS limpo." -ForegroundColor Green
                Read-Host "`nPressione Enter para continuar"
            }
            "2" {
                Write-Host "`nIniciando Verificador de Arquivos do Sistema..." -ForegroundColor Yellow
                sfc /scannow
                Read-Host "`nPressione Enter para continuar"
            }
            "3" {
                Write-Host "`nIniciando reparo de imagem com DISM..." -ForegroundColor Yellow
                dism /online /cleanup-image /restorehealth
                Write-Host "`nExecutando SFC /Scannow..." -ForegroundColor Yellow
                sfc /scannow
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
    Write-Host "[3] Finalizar Processo por Nome (Ex: chrome)" -ForegroundColor White
    Write-Host "[0] Voltar" -ForegroundColor Red
    Write-Host "`nEscolha uma opcao: " -NoNewline -ForegroundColor Yellow
    $op = Read-KeyChoice
    Write-Host $op
    if ($op -eq "1") {
        Get-Process | Sort-Object -Property WorkingSet64 -Descending |
            Select-Object -First 20 -Property Id, ProcessName, @{N='RAM (MB)';E={[math]::Round($_.WorkingSet64 / 1MB, 2)}} | Format-Table -AutoSize
        Read-Host "`nPressione Enter para continuar"
    } elseif ($op -eq "2") {
        $pidNum = Read-Host "Digite o PID do processo"
        if ($pidNum) { Stop-Process -Id $pidNum -Force -ErrorAction SilentlyContinue; Write-Host "Processo finalizado." -ForegroundColor Green }
        Read-Host "`nPressione Enter para continuar"
    } elseif ($op -eq "3") {
        $pName = Read-Host "Digite o nome do processo (sem .exe)"
        if ($pName) { Stop-Process -Name $pName -Force -ErrorAction SilentlyContinue; Write-Host "Processo(s) encerrado(s)." -ForegroundColor Green }
        Read-Host "`nPressione Enter para continuar"
    }
}

function Limpeza-Temporarios {
    Clear-Host
    Write-Host "--- LIMPEZA DE ARQUIVOS TEMPORARIOS ---`n" -ForegroundColor Cyan
    Write-Host "[1/2] Limpando pasta TEMP do usuario..." -ForegroundColor Yellow
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[2/2] Limpando pasta TEMP do sistema..." -ForegroundColor Yellow
    Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "`n[SUCESSO] Limpeza de temporarios concluida!" -ForegroundColor Green
    Read-Host "Pressione Enter para continuar"
}

function Verificar-Disco {
    Clear-Host
    Write-Host "--- VERIFICACAO E DIAGNOSTICO DE DISCO (CHKDSK) ---`n" -ForegroundColor Cyan
    Write-Host "Executando varredura em modo de leitura na unidade C:..." -ForegroundColor Yellow
    $chkdskOutput = chkdsk C:
    $chkdskOutput | Out-String | Write-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "          RESUMO DO DIAGNOSTICO           " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    $rawText = $chkdskOutput -join " "
    if ($rawText -like "*found no problems*" -or $rawText -like "*nao encontrou problemas*") {
        Write-Host "STATUS: O disco esta SAUDAVEL. Nenhum erro foi encontrado." -ForegroundColor Green
    } elseif ($rawText -like "*found errors*" -or $rawText -like "*encontrou erros*") {
        Write-Host "STATUS: ATENCAO! Foram encontrados erros no sistema de arquivos." -ForegroundColor Red
        Write-Host "RECOMENDACAO: Agende uma correcao profunda ao reiniciar." -ForegroundColor Yellow
        $agendar = Read-Host "`nDeseja agendar o CHKDSK /F para a proxima reinicializacao? (S/N)"
        if ($agendar -eq "S" -or $agendar -eq "s") {
            chkdsk C: /f
            Write-Host "Verificacao agendada com sucesso para o proximo reboot." -ForegroundColor Green
        }
    } else {
        Write-Host "STATUS: Varredura concluida sem alertas criticos aparentes." -ForegroundColor Yellow
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
    Write-Host "--- COMPILACAO DE INFORMACOES DO SISTEMA ---`n" -ForegroundColor Cyan
    $os = Get-CimInstance Win32_OperatingSystem
    $installDate = $os.InstallDate.ToString("dd/MM/yyyy HH:mm:ss")
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $ramGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
    $mb = Get-CimInstance Win32_BaseBoard
    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    $net = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True" | Select-Object -First 1
    Write-Host "SISTEMA OPERACIONAL" -ForegroundColor Yellow
    Write-Host "  Nome/Edicao    : $($os.Caption)" -ForegroundColor White
    Write-Host "  Versao/Build   : $($os.Version) (Build $($os.BuildNumber))" -ForegroundColor White
    Write-Host "  Arquitetura    : $($os.OSArchitecture)" -ForegroundColor White
    Write-Host "  Ultima Formata : $installDate" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "HARDWARE PRINCIPAL" -ForegroundColor Yellow
    Write-Host "  Processador    : $($cpu.Name.Trim())" -ForegroundColor White
    Write-Host "  Memoria RAM    : $ramGB GB" -ForegroundColor White
    Write-Host "  Placa-Mae      : $($mb.Manufacturer) - Modelo: $($mb.Product)" -ForegroundColor White
    Write-Host "  Placa de Video : $($gpu.Name)" -ForegroundColor White
    Write-Host ""
    Write-Host "REDE E CONECTIVIDADE" -ForegroundColor Yellow
    Write-Host "  Adaptador      : $($net.Description)" -ForegroundColor White
    Write-Host "  Endereco IP    : $($net.IPAddress[0])" -ForegroundColor White
    Write-Host "  MAC Address    : $($net.MACAddress)" -ForegroundColor White
    Write-Host "==========================================" -ForegroundColor Cyan
    Read-Host "`nPressione Enter para continuar"
}

function Agendar-Desligamento {
    Clear-Host
    Write-Host "--- AGENDAR DESLIGAMENTO OU REINICIALIZACAO ---`n" -ForegroundColor Cyan
    Write-Host "[1] Agendar Desligamento" -ForegroundColor White
    Write-Host "[2] Agendar Reinicializacao" -ForegroundColor White
    Write-Host "[3] Cancelar Agendamento Ativo" -ForegroundColor Yellow
    Write-Host "[0] Voltar" -ForegroundColor Red
    Write-Host "`nEscolha a acao: " -NoNewline -ForegroundColor Yellow
    $op = Read-KeyChoice
    Write-Host $op
    if ($op -eq "1" -or $op -eq "2") {
        $unidade = Read-Host "`nDigite 1 para Minutos ou 2 para Horas"
        $qtde = Read-Host "Digite a quantidade de tempo (apenas numeros)"
        if ($qtde -match '^\d+$') {
            $segundos = if ($unidade -eq "1") { [int]$qtde * 60 } else { [int]$qtde * 3600 }
            if ($op -eq "1") {
                shutdown -s -t $segundos
                Write-Host "Desligamento agendado para daqui a $qtde unidade(s)." -ForegroundColor Green
            } else {
                shutdown -r -t $segundos
                Write-Host "Reinicializacao agendada para daqui a $qtde unidade(s)." -ForegroundColor Green
            }
        } else {
            Write-Host "Quantidade invalida!" -ForegroundColor Red
        }
    } elseif ($op -eq "3") {
        shutdown -a 2>$null
        Write-Host "Agendamento cancelado com sucesso." -ForegroundColor Green
    }
    Read-Host "`nPressione Enter para continuar"
}

function Ativar-Windows-Office {
    Clear-Host
    Write-Host "--- ATIVACAO DE WINDOWS E OFFICE (MAS Script) ---`n" -ForegroundColor Cyan
    Write-Host "Esta operacao executa o Microsoft Activation Scripts oficial." -ForegroundColor Yellow
    Write-Host "Requer conexao ativa com a internet." -ForegroundColor Yellow
    $confirm = Read-Host "`nDeseja abrir o ativador agora? (S/N)"
    if ($confirm -eq "S" -or $confirm -eq "s") {
        irm https://get.activated.win | iex
    }
    Read-Host "`nPressione Enter para continuar"
}

function Get-WindowsKey {
    Clear-Host
    Write-Host "--- DIAGNOSTICO COMPLETO DE LICENCA DO WINDOWS ---`n" -ForegroundColor Cyan

    $osInfo = Get-CimInstance Win32_OperatingSystem
    Write-Host "Edicao do Windows : $($osInfo.Caption)" -ForegroundColor White
    Write-Host "Versao / Build    : $($osInfo.Version) (Build $($osInfo.BuildNumber))" -ForegroundColor Gray
    Write-Host "-----------------------------------------------------------------" -ForegroundColor Gray

    $foundAny = $false

    # [1] Chave OEM na BIOS/UEFI
    try {
        $biosKey = (Get-CimInstance -Query 'select OA3xOriginalProductKey from SoftwareLicensingService').OA3xOriginalProductKey
        if ($biosKey -and $biosKey.Trim() -ne "") {
            $foundAny = $true
            Write-Host "`n[1] CHAVE OEM (EMBUTIDA NA BIOS/UEFI)" -ForegroundColor Green
            Write-Host "    Chave Completa : $biosKey" -ForegroundColor Yellow
            Write-Host "    Tipo           : OEM (OEM:DM / OEM:SLP)" -ForegroundColor White
            Write-Host "    Descricao      : Vinculada permanentemente a placa-mae." -ForegroundColor Gray
            Write-Host "                     Nao pode ser transferida para outro PC." -ForegroundColor Gray
            Write-Host "                     Reinstala automaticamente na mesma maquina." -ForegroundColor Gray
        }
    } catch {}

    # [2] Licenca instalada no sistema
    try {
        $digitalLic = Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND Name LIKE 'Windows%'" |
                      Where-Object { $_.ApplicationId -eq '55c9273a-2b2c-4032-9916-e0625a639257' } |
                      Select-Object -First 1

        if ($digitalLic) {
            $foundAny = $true
            $licFamily = $digitalLic.LicenseFamily
            $licStatus = if ($digitalLic.LicenseStatus -eq 1) { "Ativado" } else { "Nao Ativado" }

            Write-Host "`n[2] LICENCA INSTALADA NO SISTEMA" -ForegroundColor Green
            Write-Host "    Ultimos 5 digitos : .....-.....-.....-.....-$($digitalLic.PartialProductKey)" -ForegroundColor Yellow
            Write-Host "    Familia da Licenca: $licFamily" -ForegroundColor White
            Write-Host "    Status            : $licStatus" -ForegroundColor $(if ($digitalLic.LicenseStatus -eq 1) { "Green" } else { "Red" })
            Write-Host "    Descricao         : $($digitalLic.Description)" -ForegroundColor Gray

            if ($licFamily -match "Digital") {
                Write-Host "    Tipo              : LICENCA DIGITAL (Digital License)" -ForegroundColor Cyan
                Write-Host "                        Vinculada ao hardware + conta Microsoft." -ForegroundColor Gray
                Write-Host "                        Nao existe chave de 25 caracteres." -ForegroundColor Gray
                Write-Host "                        Reinstala e ativa sozinha apos login." -ForegroundColor Gray
            } elseif ($licFamily -match "Retail") {
                Write-Host "    Tipo              : RETAIL (Comprada separadamente)" -ForegroundColor Cyan
                Write-Host "                        Transferivel entre PCs (1 ativo por vez)." -ForegroundColor Gray
            } elseif ($licFamily -match "Volume:GVLK") {
                Write-Host "    Tipo              : VOLUME (KMS / GVLK)" -ForegroundColor Cyan
                Write-Host "                        Ativacao corporativa via servidor KMS." -ForegroundColor Gray
            } elseif ($licFamily -match "Volume:MAK") {
                Write-Host "    Tipo              : VOLUME (MAK)" -ForegroundColor Cyan
                Write-Host "                        Ativacao em lote para empresas." -ForegroundColor Gray
            } elseif ($licFamily -match "OEM") {
                Write-Host "    Tipo              : OEM (Confirmado via Registro)" -ForegroundColor Cyan
            }
        }
    } catch {}

    # [3] Canal de ativacao via slmgr /dli
    try {
        $slmgrOutput = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /dli 2>&1 | Out-String
        if ($slmgrOutput -match "RETAIL|OEM|VOLUME|MAK|KMS") {
            $foundAny = $true
            Write-Host "`n[3] CANAL DE ATIVACAO (slmgr /dli)" -ForegroundColor Green
            $channel = if ($slmgrOutput -match "RETAIL") { "RETAIL" }
                       elseif ($slmgrOutput -match "OEM") { "OEM" }
                       elseif ($slmgrOutput -match "KMS") { "VOLUME: KMS" }
                       elseif ($slmgrOutput -match "MAK") { "VOLUME: MAK" }
                       else { "Desconhecido" }
            Write-Host "    Canal de Ativacao : $channel" -ForegroundColor Yellow
        }
    } catch {}

    # [4] Status geral
    try {
        $slmgrStatus = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /xpr 2>&1 | Out-String
        if ($slmgrStatus -match "permanently activated") {
            Write-Host "`n[4] STATUS GERAL DE ATIVACAO" -ForegroundColor Green
            Write-Host "    Windows esta PERMANENTEMENTE ATIVADO." -ForegroundColor Green
        } elseif ($slmgrStatus -match "Notification mode") {
            Write-Host "`n[4] STATUS GERAL DE ATIVACAO" -ForegroundColor Yellow
            Write-Host "    Windows esta em MODO DE NOTIFICACAO (nao ativado)." -ForegroundColor Yellow
        }
    } catch {}

    if (-not $foundAny) {
        Write-Host "`n[AVISO] Nenhuma licenca ou chave valida encontrada no sistema." -ForegroundColor Yellow
    }

    Read-Host "`nPressione Enter para continuar"
}

function Get-OfficeKey {
    Clear-Host
    Write-Host "--- DIAGNOSTICO DE CHAVE DO OFFICE ---`n" -ForegroundColor Cyan

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
            Write-Host "Consultando status de ativacao do Office via OSPP..." -ForegroundColor Yellow

            $output = cscript //nologo "$osppScript" /dstatus 2>&1 | Out-String
            $products = $output -split "LICENSE NAME:" | Where-Object { $_ -match "LICENSE STATUS:" }

            if ($products.Count -gt 0) {
                $count = 1
                foreach ($prod in $products) {
                    $name = if ($prod -match "(.*)") { $matches[1].Trim() } else { "Desconhecido" }
                    $key = if ($prod -match "Last 5 characters of installed product key:\s*(.*)") { $matches[1].Trim() } else { "N/A" }
                    $statusLine = ($prod -split "`n" | Where-Object { $_ -match "LICENSE STATUS:" }) -join ""
                    $isLicensed = $statusLine -match "LICENSED"
                    $statusText = if ($isLicensed) { "Ativado" } else { "Nao Ativado" }
                    $statusColor = if ($isLicensed) { "Green" } else { "Red" }

                    Write-Host "`n------------------------------------------" -ForegroundColor Gray
                    Write-Host " LICENCA #$count" -ForegroundColor Green
                    Write-Host " Produto : $name" -ForegroundColor White
                    Write-Host " Chave   : Ultimos 5 digitos: $key" -ForegroundColor Green
                    Write-Host " Status  : $statusText" -ForegroundColor $statusColor
                    $count++
                }
            } else {
                Write-Host "`n[AVISO] Office localizado, mas nenhuma licenca ativa encontrada." -ForegroundColor Yellow
            }
            break
        }
    }

    if (-not $officeFound) {
        Write-Host "`n[ERRO] A ferramenta OSPP.VBS nao foi localizada no sistema." -ForegroundColor Red
    }

    Read-Host "`nPressione Enter para continuar"
}

function Chutar-Chave-Windows {
    Clear-Host
    Write-Host "--- CHUTADOR DE CHAVE DO WINDOWS ---`n" -ForegroundColor Cyan
    Write-Host "[INFO] Antes de comecar, escolha o SO ALVO da chave." -ForegroundColor White
    Write-Host "       O sistema so aceitara chaves desta edicao." -ForegroundColor Gray

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

    Write-Host "`n  --- WINDOWS DESKTOP ---" -ForegroundColor DarkCyan
    for ($i = 0; $i -lt 21; $i++) {
        Write-Host (" [{0,2}] {1}" -f ($i + 1), $osAlvos[$i]) -ForegroundColor White
    }
    Write-Host "`n  --- WINDOWS SERVER ---" -ForegroundColor DarkCyan
    for ($i = 21; $i -lt 39; $i++) {
        Write-Host (" [{0,2}] {1}" -f ($i + 1), $osAlvos[$i]) -ForegroundColor White
    }
    Write-Host "`n [40] Outro (digitar manualmente)" -ForegroundColor Cyan

    $escolha = Read-Host "`n Escolha o SO alvo (1-40)"
    $escolhaNum = 0
    if (-not [int]::TryParse($escolha, [ref]$escolhaNum)) {
        Write-Host "`n[ERRO] Opcao invalida." -ForegroundColor Red
        Read-Host "Pressione Enter para continuar"
        return
    }

    $soAlvo = ""
    if ($escolhaNum -ge 1 -and $escolhaNum -le 39) {
        $soAlvo = $osAlvos[$escolhaNum - 1]
    } elseif ($escolhaNum -eq 40) {
        $soAlvo = Read-Host "`nDigite o nome exato do SO"
    } else {
        Write-Host "`n[ERRO] Opcao invalida." -ForegroundColor Red
        Read-Host "Pressione Enter para continuar"
        return
    }

    Write-Host "`n SO alvo definido: $soAlvo" -ForegroundColor Green
    Write-Host ""
    Write-Host "Use o formato: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" -ForegroundColor White
    Write-Host "Substitua os caracteres desconhecidos por '*'" -ForegroundColor Yellow
    Write-Host "Exemplo: NPPR9-FWDCX-D2C8J-*****-*****" -ForegroundColor Gray
    Write-Host ""

    $pattern = Read-Host "Digite a chave (use * para os digitos faltantes)"
    $pattern = $pattern.Trim().ToUpper()
    $raw = $pattern -replace '-', ''

    if ($raw.Length -ne 25) {
        Write-Host "`n[ERRO] A chave deve ter 25 caracteres (sem hifens)." -ForegroundColor Red
        Write-Host "       Voce digitou: $($raw.Length) caracteres." -ForegroundColor Gray
        Read-Host "`nPressione Enter para continuar"
        return
    }

    if ($raw -notmatch '^[A-Z0-9\*]+$') {
        Write-Host "`n[ERRO] Caractere invalido detectado!" -ForegroundColor Red
        Write-Host "       Use apenas A-Z, 0-9 ou * para coringa." -ForegroundColor Yellow
        Read-Host "`nPressione Enter para continuar"
        return
    }

    $asteriscos = ($raw.ToCharArray() | Where-Object { $_ -eq '*' }).Count

    if ($asteriscos -eq 0) {
        Write-Host "`n[AVISO] Nenhum '*' encontrado. A chave sera testada diretamente." -ForegroundColor Yellow
        $confirm = Read-Host "Deseja continuar? (S/N)"
        if ($confirm -ne "S" -and $confirm -ne "s") { return }
    }

    # Alfabeto oficial das product keys (sem vogais, sem 0/1)
    $validChars = "BCDFGHJKMPQRTVWXY23456789"
    $validCharsArr = $validChars.ToCharArray()
    $totalTentativas = [math]::Pow($validCharsArr.Length, $asteriscos)

    if ($asteriscos -gt 0) {
        $segundosPorTentativa = 1.2
        $tempoTotalSegundos = $totalTentativas * $segundosPorTentativa
        $tempoFormatado = if ($tempoTotalSegundos -lt 60) {
            "{0:N0} segundos" -f $tempoTotalSegundos
        } elseif ($tempoTotalSegundos -lt 3600) {
            "{0:N1} minutos" -f ($tempoTotalSegundos / 60)
        } elseif ($tempoTotalSegundos -lt 86400) {
            "{0:N1} horas" -f ($tempoTotalSegundos / 3600)
        } elseif ($tempoTotalSegundos -lt 31536000) {
            "{0:N1} dias" -f ($tempoTotalSegundos / 86400)
        } else {
            "{0:N1} anos" -f ($tempoTotalSegundos / 31536000)
        }

        Write-Host "`n=====================================================" -ForegroundColor Cyan
        Write-Host "          ESTIMATIVA DO CHUTADOR                     " -ForegroundColor Cyan
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " SO alvo               : $soAlvo" -ForegroundColor White
        Write-Host " Caracteres faltantes  : $asteriscos" -ForegroundColor White
        Write-Host " Combinacoes possiveis : $('{0:N0}' -f $totalTentativas)" -ForegroundColor Yellow
        Write-Host " Tempo estimado        : $tempoFormatado" -ForegroundColor Yellow
        Write-Host " (~1.2s por tentativa via slmgr)" -ForegroundColor Gray
        Write-Host "=====================================================" -ForegroundColor Cyan

        if ($totalTentativas -gt 100000) {
            Write-Host "`n[ATENCAO] Essa quantidade pode demorar MUITO." -ForegroundColor Red
            Write-Host "          Recomendado: no maximo 4 asteriscos." -ForegroundColor Yellow
        }

        $confirm = Read-Host "`nDeseja iniciar o chute? (S/N)"
        if ($confirm -ne "S" -and $confirm -ne "s") { return }
    }

    # Mapeia palavra-chave do alvo para o nome reportado pelo slmgr
    $alvoLower = $soAlvo.ToLower()
    $expectedEdition = "Professional"  # fallback
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
    $asteriscosIdx = @()
    for ($i = 0; $i -lt 25; $i++) {
        if ($raw[$i] -eq '*') { $asteriscosIdx += $i }
    }

    function Gerar-Combinacao {
        param([long]$indice, [char[]]$alfabeto, [int]$posicoes)
        $resultado = New-Object char[] $posicoes
        for ($p = $posicoes - 1; $p -ge 0; $p--) {
            $resultado[$p] = $alfabeto[$indice % $alfabeto.Length]
            $indice = [math]::Floor($indice / $alfabeto.Length)
        }
        return -join $resultado
    }

    $tentativaAtual = 0
    $encontrou = $false
    $inicio = Get-Date

    Write-Host "`nIniciando tentativas... (Ctrl+C para cancelar)`n" -ForegroundColor Yellow

    for ($i = 0; $i -lt $totalTentativas; $i++) {
        $tentativaAtual++

        $combinacao = Gerar-Combinacao -indice $i -alfabeto $validCharsArr -posicoes $asteriscos
        $chaveArray = $raw.ToCharArray()
        for ($j = 0; $j -lt $asteriscosIdx.Count; $j++) {
            $chaveArray[$asteriscosIdx[$j]] = $combinacao[$j]
        }
        $chaveFinal = -join $chaveArray
        $chaveFormatada = ($chaveFinal -replace '(.{5})(?=.)', '$1-')

        # Barra de progresso
        $percent = [math]::Round(($tentativaAtual / $totalTentativas) * 100)
        $barWidth = 25
        $filled = [math]::Round(($tentativaAtual / $totalTentativas) * $barWidth)
        if ($filled -gt $barWidth) { $filled = $barWidth }
        $bar = ("#" * $filled) + ("-" * ($barWidth - $filled))

        $decorrido = (Get-Date) - $inicio
        $media = if ($tentativaAtual -gt 0) { $decorrido.TotalSeconds / $tentativaAtual } else { 1.2 }
        $restantes = $totalTentativas - $tentativaAtual
        $etaSeg = [math]::Round($media * $restantes)
        $etaFormat = "{0:hh\:mm\:ss}" -f [TimeSpan]::FromSeconds($etaSeg)

        $linha = "[{0}] {1,3}% ({2}/{3}) ETA: {4} - {5}" -f $bar, $percent, $tentativaAtual, $totalTentativas, $etaFormat, $chaveFormatada
        if ($linha.Length -gt 110) { $linha = $linha.Substring(0, 110) }
        Write-Host "`r$linha" -NoNewline -ForegroundColor Cyan

        # Testa a chave
        $resultado = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /ipk $chaveFormatada 2>&1 | Out-String

        if ($resultado -match "instalada com .xito|installed successfully|product key installed successfully") {
            # Verifica a edicao reportada
            $dli = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /dli 2>&1 | Out-String

            if ($dli -match $expectedEdition) {
                # Tenta ativar de verdade
                $ato = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /ato 2>&1 | Out-String
                if ($ato -match "activated successfully|ativado com .xito|Product activated") {
                    $xpr = & cscript //nologo "$env:SystemRoot\System32\slmgr.vbs" /xpr 2>&1 | Out-String
                    if ($xpr -match "permanently|permanentemente") {
                        $encontrou = $true
                        Write-Host "`n`n=====================================================" -ForegroundColor Green
                        Write-Host "        CHAVE ENCONTRADA E ATIVADA!                  " -ForegroundColor Green
                        Write-Host "=====================================================" -ForegroundColor Green
                        Write-Host " SO alvo           : $soAlvo" -ForegroundColor White
                        Write-Host " Chave Valida      : $chaveFormatada" -ForegroundColor Yellow
                        Write-Host " Status            : Permanentemente ativado" -ForegroundColor Green
                        Write-Host " Tentativas        : $tentativaAtual de $totalTentativas" -ForegroundColor White
                        Write-Host " Tempo total       : $($decorrido.ToString('hh\:mm\:ss'))" -ForegroundColor White
                        Write-Host "=====================================================" -ForegroundColor Green

                        $logPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "chave_encontrada.txt"
                        "Chave encontrada: $chaveFormatada`nSO alvo: $soAlvo`nTentativas: $tentativaAtual`nData: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" | Out-File -FilePath $logPath -Encoding UTF8
                        Write-Host "`nChave salva em: $logPath" -ForegroundColor Yellow
                        break
                    }
                }
            }
        }
    }

    if (-not $encontrou) {
        Write-Host "`n`n=====================================================" -ForegroundColor Red
        Write-Host "        NENHUMA CHAVE VALIDA ENCONTRADA              " -ForegroundColor Red
        Write-Host "=====================================================" -ForegroundColor Red
        Write-Host " SO alvo           : $soAlvo" -ForegroundColor White
        Write-Host " Tentativas        : $tentativaAtual de $totalTentativas" -ForegroundColor White
        Write-Host " Verifique se os digitos conhecidos estao corretos." -ForegroundColor Yellow
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
        Write-Host "  [1] Backup de Arquivos e Pastas (Robocopy)" -ForegroundColor White
        Write-Host ""
        Write-Host "  [0] Voltar ao Menu Principal" -ForegroundColor Red
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " Opcao: " -NoNewline -ForegroundColor Yellow
        $op = Read-KeyChoice
        Write-Host $op
        switch ($op) {
            "1" { Backup-Arquivos }
        }
    } while ($op -ne "0")
}

function Backup-Arquivos {
    Clear-Host
    Write-Host "--- BACKUP DE ARQUIVOS (ROBOCOPY) ---`n" -ForegroundColor Cyan
    $source = Read-Host "Digite a pasta de Origem (ex: C:\Users\Cliente\Documents)"
    $dest = Read-Host "Digite a pasta de Destino (ex: E:\BackupCliente)"
    if (-not (Test-Path $source)) {
        Write-Host "Origem invalida!" -ForegroundColor Red
        Read-Host "Pressione Enter para continuar"
        return
    }
    Write-Host "`nIniciando copia de arquivos..." -ForegroundColor Yellow
    robocopy $source $dest /E /TEE /CR /R:2 /W:2
    Write-Host "`n[SUCESSO] Backup concluido!" -ForegroundColor Green
    Read-Host "Pressione Enter para continuar"
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
        Write-Host "IMPRESSORAS INSTALADAS ENCONTRADAS:" -ForegroundColor Yellow
        $printers = Get-CimInstance Win32_Printer -ErrorAction SilentlyContinue
        if ($printers) {
            for ($i = 0; $i -lt $printers.Count; $i++) {
                $pName = $printers[$i].Name
                $pPort = $printers[$i].PortName
                $pStatus = if ($printers[$i].Default) { "[PADRAO]" } else { "" }
                Write-Host "  [$($i + 1)] $pName (Porta: $pPort) $pStatus" -ForegroundColor White
            }
        } else {
            Write-Host "  [Nenhuma impressora instalada foi encontrada]" -ForegroundColor Gray
        }
        Write-Host ""
        Write-Host "-----------------------------------------------------" -ForegroundColor Gray
        Write-Host "  [1] Limpeza Profunda do Spooler + Registro" -ForegroundColor White
        Write-Host "  [2] Remover Impressora Instalada" -ForegroundColor White
        Write-Host ""
        Write-Host "  [0] Voltar ao Menu Principal" -ForegroundColor Red
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
    Write-Host "--- LIMPEZA PROFUNDA DO SPOOLER E REGISTRO ---`n" -ForegroundColor Cyan
    Write-Host "[1/4] Parando servico de Spooler de Impressao..." -ForegroundColor Yellow
    Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
    Get-Process -Name "spoolsv" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1

    Write-Host "[2/4] Limpando arquivos na pasta PRINTERS..." -ForegroundColor Yellow
    $spoolPath = "$env:SystemRoot\System32\spool\PRINTERS\*"
    Remove-Item -Path $spoolPath -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "      -> Cache do disco esvaziado." -ForegroundColor Green

    Write-Host "[3/4] Limpando chaves travadas no Registro..." -ForegroundColor Yellow
    $userConnPath = "HKCU:\Printers\Connections"
    if (Test-Path $userConnPath) {
        Get-ChildItem -Path $userConnPath -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item -Path $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Host "      -> Conexoes em HKCU limpas." -ForegroundColor Green
    }
    $systemPrintPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers"
    if (Test-Path $systemPrintPath) {
        Get-ChildItem -Path $systemPrintPath -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-ItemProperty -Path $_.PSPath -Name "SpoolFile" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $_.PSPath -Name "Attributes" -ErrorAction SilentlyContinue
        }
        Write-Host "      -> Pendencias em HKLM resetadas." -ForegroundColor Green
    }

    Write-Host "[4/4] Reiniciando servico de Spooler..." -ForegroundColor Yellow
    Start-Service -Name "Spooler" -ErrorAction SilentlyContinue
    Write-Host "`n[SUCESSO] Spooler e registro limpos com sucesso!" -ForegroundColor Green
    Read-Host "Pressione Enter para continuar"
}

function Remover-Impressora {
    param ($PrintersList)
    if (-not $PrintersList) {
        Write-Host "`n[AVISO] Nenhuma impressora disponivel para remocao." -ForegroundColor Yellow
        Read-Host "Pressione Enter para continuar"
        return
    }
    Write-Host ""
    $indexChoice = Read-Host "Digite o numero do indice da impressora para REMOVER (ou 0 para cancelar)"
    if ($indexChoice -match '^\d+$' -and [int]$indexChoice -gt 0 -and [int]$indexChoice -le $PrintersList.Count) {
        $targetPrinter = $PrintersList[[int]$indexChoice - 1]
        Write-Host "`nRemovendo '$($targetPrinter.Name)'..." -ForegroundColor Yellow
        Remove-CimInstance -InputObject $targetPrinter -ErrorAction SilentlyContinue
        Write-Host "[SUCESSO] Impressora removida do sistema!" -ForegroundColor Green
    } else {
        Write-Host "Operacao cancelada." -ForegroundColor Yellow
    }
    Read-Host "Pressione Enter para continuar"
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
        Write-Host "  [1] Backup de Drivers (Antes de Formatar)" -ForegroundColor White
        Write-Host "  [2] Restauracao de Drivers + Tratamento de Erros" -ForegroundColor White
        Write-Host "  [3] Buscar Atualizacoes de Drivers (Windows Update)" -ForegroundColor White
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
    $backupPath = Read-Host "Digite o caminho para salvar o backup (ex: D:\DriversBackup)"
    $backupPath = $backupPath.Trim('"')

    if (-not $backupPath) {
        Write-Host "Caminho invalido. Operacao cancelada." -ForegroundColor Red
        Read-Host "Pressione Enter para continuar"
        return
    }
    if (-not (Test-Path $backupPath)) {
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        Write-Host "Pasta criada: $backupPath" -ForegroundColor Green
    }

    Write-Host "`nEnumerando drivers de terceiros instalados..." -ForegroundColor Yellow
    $driverList = @()
    try {
        $driverList = & pnputil /enum-drivers 2>&1 | Select-String "Published Name" | ForEach-Object { $_.Line.Trim() }
    } catch {}

    $total = $driverList.Count
    if ($total -eq 0) { $total = 1 }

    Write-Host "Exportando $total driver(s) de terceiros...`n" -ForegroundColor Yellow
    Show-ProgressBar -Current 0 -Total $total -Activity "Exportando" -Detail "iniciando..."

    try {
        pnputil /export-driver * "$backupPath" | Out-Null
        dism /online /export-driver /destination:"$backupPath" 2>&1 | Out-Null
    } catch {
        Write-Host "`n[ERROR] Falha ao exportar drivers: $_" -ForegroundColor Red
        Read-Host "Pressione Enter para continuar"
        return
    }

    for ($i = 1; $i -le $total; $i++) {
        Show-ProgressBar -Current $i -Total $total -Activity "Exportando" -Detail "driver $i de $total"
        Start-Sleep -Milliseconds 15
    }

    Write-Host "`n`n[SUCCESS] Backup concluido em: $backupPath" -ForegroundColor Green
    Read-Host "Pressione Enter para continuar"
}

function Restore-Drivers {
    Clear-Host
    Write-Host "--- RESTAURACAO DE DRIVERS INDIVIDUALIZADA ---`n" -ForegroundColor Cyan
    $backupPath = Read-Host "Digite o caminho do backup (ex: D:\DriversBackup)"
    $backupPath = $backupPath.Trim('"')

    if (-not (Test-Path $backupPath)) {
        Write-Host "Pasta nao encontrada: $backupPath" -ForegroundColor Red
        Read-Host "Pressione Enter para continuar"
        return
    }

    $infFiles = @(Get-ChildItem -Path $backupPath -Filter "*.inf" -Recurse)
    if ($infFiles.Count -eq 0) {
        Write-Host "[WARNING] Nenhum arquivo .inf encontrado." -ForegroundColor Yellow
        Read-Host "Pressione Enter para continuar"
        return
    }

    $total = $infFiles.Count
    Write-Host "`nLocalizados $total drivers para instalacao." -ForegroundColor Cyan

    $logFile = Join-Path $backupPath "log_erros_drivers.txt"
    if (Test-Path $logFile) { Remove-Item $logFile -Force }

    $sucessoCount = 0
    $falhaCount = 0
    $index = 0

    Write-Host "Iniciando instalacao. Aguarde...`n" -ForegroundColor Yellow
    Show-ProgressBar -Current 0 -Total $total -Activity "Instalando" -Detail "iniciando..."

    foreach ($file in $infFiles) {
        $index++
        $process = Start-Process pnputil -ArgumentList "/add-driver `"$($file.FullName)`" /install" -NoNewWindow -PassThru -Wait

        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            $sucessoCount++
        } else {
            $falhaCount++
            $errorMessage = "Erro codigo $($process.ExitCode) ao instalar: $($file.FullName)"
            Add-Content -Path $logFile -Value $errorMessage
        }

        $detail = "OK:$sucessoCount Falha:$falhaCount - $($file.Name)"
        Show-ProgressBar -Current $index -Total $total -Activity "Instalando" -Detail $detail
    }

    Write-Host "`n`n==========================================" -ForegroundColor Cyan
    Write-Host "          RESUMO DA INSTALACAO           " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Total de drivers processados  : $total" -ForegroundColor White
    Write-Host "Drivers instalados com SUCESSO: $sucessoCount" -ForegroundColor Green

    if ($falhaCount -gt 0) {
        Write-Host "Drivers que FALHARAM          : $falhaCount" -ForegroundColor Red
        Write-Host "Verifique os detalhes das falhas em: $logFile" -ForegroundColor Yellow
    } else {
        Write-Host "Todos os drivers foram reinstalados sem erro!" -ForegroundColor Green
    }

    Write-Host "`nRecomenda-se reiniciar o computador." -ForegroundColor Yellow
    Read-Host "`nPressione Enter para continuar"
}

function Search-DriverUpdates {
    Clear-Host
    Write-Host "--- BUSCAR E ATUALIZAR DRIVERS VIA WINDOWS UPDATE ---`n" -ForegroundColor Cyan
    Write-Host "[INFO] Requer conexao ativa com a internet." -ForegroundColor Yellow

    $confirm = Read-Host "Deseja iniciar a busca agora? (S/N)"
    if ($confirm -ne "S" -and $confirm -ne "s") { return }

    Write-Host "`nConectando aos servidores da Microsoft..." -ForegroundColor Yellow

    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Driver'")

        if ($searchResult.Updates.Count -eq 0) {
            Write-Host "[SUCCESS] Todos os drivers ja estao atualizados." -ForegroundColor Green
        } else {
            Write-Host "`n[INFO] Encontrado(s) $($searchResult.Updates.Count) driver(s) pendente(s):" -ForegroundColor Cyan

            $updatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($update in $searchResult.Updates) {
                Write-Host " - $($update.Title)" -ForegroundColor White
                $updatesToDownload.Add($update) | Out-Null
            }

            Write-Host "`nBaixando atualizacoes..." -ForegroundColor Yellow
            $downloader = $updateSession.CreateUpdateDownloader()
            $downloader.Updates = $updatesToDownload
            $downloadResult = $downloader.Download()

            if ($downloadResult.ResultCode -eq 2) {
                Write-Host "Download concluido. Instalando drivers..." -ForegroundColor Yellow
                $installer = $updateSession.CreateUpdateInstaller()
                $installer.Updates = $updatesToDownload
                $installationResult = $installer.Install()

                if ($installationResult.ResultCode -eq 2) {
                    Write-Host "[SUCCESS] Todos os drivers foram atualizados!" -ForegroundColor Green
                } else {
                    Write-Host "[WARNING] Falha ao instalar alguns drivers. Codigo: $($installationResult.ResultCode)" -ForegroundColor Yellow
                }
            } else {
                Write-Host "[ERROR] Falha ao baixar os drivers." -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "[ERROR] Nao foi possivel consultar o Windows Update: $_" -ForegroundColor Red
    }

    Read-Host "`nPressione Enter para voltar ao menu"
}

# =============================================================
# LOOP PRINCIPAL
# =============================================================

do {
    Draw-Header -Art $ArtMain
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "        PAINEL DE FERRAMENTAS DE TI - v4.2           " -ForegroundColor Green
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] REDE        (Ping, IPConfig, Release/Renew, DNS)" -ForegroundColor White
    Write-Host "  [2] REPARO      (SFC, DISM, Processos, Temp, CHKDSK)" -ForegroundColor White
    Write-Host "  [3] SISTEMA     (Info, Agendador, Chaves, MAS, Chute)" -ForegroundColor White
    Write-Host "  [4] ARQUIVOS    (Backup Robocopy)" -ForegroundColor White
    Write-Host "  [5] IMPRESSORAS (Listagem, Spooler+Regedit, Desinstalar)" -ForegroundColor White
    Write-Host "  [6] DRIVERS     (Backup, Restauracao, Windows Update)" -ForegroundColor White
    Write-Host ""
    Write-Host "  [0] Sair do Programa" -ForegroundColor Red
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
        "0" { Write-Host "`nSaindo do programa..." -ForegroundColor Green; break }
        default { Write-Host "`nOpcao invalida!" -ForegroundColor Red; Start-Sleep -Milliseconds 800 }
    }
} while ($choice -ne "0")