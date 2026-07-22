@echo off
:: =========================================================================
:: LANÇADOR INTEGRADO DE FERRAMENTAS v2.2
:: =========================================================================
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Content '%~f0' | Select-Object -Skip 7 | Out-String | Invoke-Expression"
exit /b

<#
.SYNOPSIS
    Ferramentas de Sistema unificadas.
.DESCRIPTION
    Script utilitário para otimização, correção de sistema e ativação.
.NOTES
    Adaptado para formato híbrido por Gabriel Lopes.
#>

# Força o Bypass apenas para este processo
Set-ExecutionPolicy Bypass -Scope Process -Force | Out-Null

# Verifica se está rodando como administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "=====================================================================" -ForegroundColor Red
    Write-Host "   ESTE SCRIPT PRECISA SER EXECUTADO COMO ADMINISTRADOR!" -ForegroundColor Red
    Write-Host "   Feche e execute novamente clicando com o botao direito e escolhendo" -ForegroundColor Yellow
    Write-Host "   'Executar como administrador'." -ForegroundColor Yellow
    Write-Host "=====================================================================" -ForegroundColor Red
    pause
    exit
}

# --- FUNÇÕES AUXILIARES ---
function Show-Menu {
    Clear-Host
    Write-Host "                                     .:\  " -ForegroundColor Green
    Write-Host "             /\                     /   : " -ForegroundColor Green
    Write-Host " '`.         /;Z                    /    / " -ForegroundColor Green
    Write-Host " \  \      /;Z                    /    /  " -ForegroundColor Green
    Write-Host "  \\ \    /;Z                    /  ///   " -ForegroundColor Green
    Write-Host "   \\ \  /;Z                    /  ///    " -ForegroundColor Green
    Write-Host "    \  \/_/____________________/    /     " -ForegroundColor Green
    Write-Host "     `/                         \  /      " -ForegroundColor Green
    Write-Host "     {  o    [+]       o  }'     Y         " -ForegroundColor Green
    Write-Host "      \_________________________/         " -ForegroundColor Green
    Write-Host ""
    Write-Host "/''''''''''''''''''''''''''''''''''''''\'" -ForegroundColor Green
    Write-Host "-        FERRAMENTAS DE SISTEMA        -" -ForegroundColor Green
    Write-Host "\......................................" -ForegroundColor Green
    Write-Host "            -Por Gabriel Lopes" -ForegroundColor Green
    Write-Host ""
    Write-Host "[1]  Correcao De Sistema" -ForegroundColor Yellow
    Write-Host "[2]  Agendar Desligar/Reiniciar" -ForegroundColor Yellow
    Write-Host "[3]  Informacoes Do Sistema" -ForegroundColor Yellow
    Write-Host "[4]  Ping De Rede" -ForegroundColor Yellow
    Write-Host "[5]  Extensoes" -ForegroundColor Yellow
    Write-Host "[6]  Gerenciador De Tarefas" -ForegroundColor Yellow
    Write-Host "[7]  Verificar Disco" -ForegroundColor Yellow
    Write-Host "[8]  Limpeza De Temporarios" -ForegroundColor Yellow
    Write-Host "[9]  Configuracao De Rede" -ForegroundColor Yellow
    Write-Host "[10] Backup De Arquivos" -ForegroundColor Yellow
    Write-Host "[11] Ativar Windows e Office" -ForegroundColor Yellow
    Write-Host "[12] Mostrar Chave do Windows" -ForegroundColor Cyan
    Write-Host "[13] Mostrar Chave do Office (Ultimos 5 caracteres)" -ForegroundColor Cyan
    Write-Host "[0]  Sair" -ForegroundColor Red
    Write-Host ""
}

# --- FUNÇÕES DO SISTEMA ---

function Get-WindowsKey {
    Write-Host "`n==========================================" -ForegroundColor Cyan
    Write-Host "       DIAGNOSTICO DE CHAVE DO WINDOWS    " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan

    # Coleta a versão do Windows
    $osInfo = Get-CimInstance Win32_OperatingSystem
    Write-Host "Edicao do Windows : $($osInfo.Caption)" -ForegroundColor White
    Write-Host "Versao / Build    : $($osInfo.Version) (Build $($osInfo.BuildNumber))" -ForegroundColor Gray
    Write-Host "------------------------------------------" -ForegroundColor Gray

    $keysFound = 0

    # 1. BUSCA CHAVE NA BIOS / UEFI (OEM)
    try {
        $biosKey = (Get-CimInstance -Query 'select OA3xOriginalProductKey from SoftwareLicensingService').OA3xOriginalProductKey
        if ($biosKey -and $biosKey.Trim() -ne "") {
            $keysFound++
            Write-Host "`n[CHAVE 1: OEM / BIOS / PLACA-MAE]" -ForegroundColor Green
            Write-Host " Chave Completa : $biosKey" -ForegroundColor Yellow
            Write-Host " Tipo de Licenca: OEM (Gravada de fabrica no hardware)" -ForegroundColor White
            Write-Host " Descricao     : Licenca permanente vinculada a esta placa-mae." -ForegroundColor Gray
        }
    } catch {}

    # 2. BUSCA CHAVE INSTALADA / REGISTRO / LICENÇA DIGITAL
    try {
        $sls = Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND Name LIKE 'Windows%'" | 
               Where-Object { $_.PartialProductKey -and $_.ApplicationId -eq '55c9273a-2b2c-4032-9916-e0625a639257' } | 
               Select-Object -First 1

        if ($sls) {
            $keysFound++
            $partialKey = $sls.PartialProductKey
            $licenseStatus = switch ($sls.LicenseStatus) {
                1 { "Ativado (Licensed)" }
                2 { "OOB Grace" }
                3 { "OOT Grace" }
                4 { "Non-Genuine Grace" }
                5 { "Not Activated" }
                6 { "Extended Grace" }
                default { "Desconhecido ($($sls.LicenseStatus))" }
            }

            Write-Host "`n[CHAVE 2: LICENCA INSTALADA NO SISTEMA]" -ForegroundColor Green
            Write-Host " Status Ativacao: $licenseStatus" -ForegroundColor Yellow
            Write-Host " Ultimos 5 : .....-.....-.....-.....-$partialKey" -ForegroundColor Yellow
            Write-Host " Descricao     : $($sls.Description)" -ForegroundColor White

            # Classificação do tipo de chave
            if ($sls.Description -like "*Retail*") {
                Write-Host " Origem/Tipo   : RETAIL (Chave de Varejo / Adquirida separadamente)" -ForegroundColor Cyan
            } elseif ($sls.Description -like "*OEM*") {
                Write-Host " Origem/Tipo   : OEM (Licenca de Fabricante)" -ForegroundColor Cyan
            } elseif ($sls.Description -like "*VOLUME*" -or $sls.Description -like "*KMS*") {
                Write-Host " Origem/Tipo   : VOLUME / KMS (Licenca Corporativa/Empresarial)" -ForegroundColor Cyan
            } elseif ($sls.Description -like "*TIMEBASED*" -or $sls.Description -like "*eval*") {
                Write-Host " Origem/Tipo   : AVALIACAO (Licenca Temporaria)" -ForegroundColor Red
            } else {
                Write-Host " Origem/Tipo   : LICENCA DIGITAL / GENERICA" -ForegroundColor Cyan
            }
        }
    } catch {}

    if ($keysFound -eq 0) {
        Write-Host "`n[AVISO] Nenhuma chave ou licenca ativa foi encontrada no sistema." -ForegroundColor Yellow
    }

    Write-Host "`n==========================================" -ForegroundColor Cyan
    Read-Host "Pressione Enter para continuar"
}

function Get-OfficeKey {
    Write-Host "`n==========================================" -ForegroundColor Cyan
    Write-Host "       DIAGNOSTICO DE CHAVE DO OFFICE     " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan

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
            Write-Host "[INFO] Script de Licenciamento localizado em:" -ForegroundColor Gray
            Write-Host "       $path" -ForegroundColor Gray
            Write-Host "`nConsultando status de ativacao..." -ForegroundColor Yellow

            $output = cscript //nologo "$osppScript" /dstatus 2>&1 | Out-String
            
            # Divide as licenças encontradas por blocos de produto
            $products = $output -split "LICENSE NAME:" | Where-Object { $_ -match "LICENSE STATUS:" }

            if ($products.Count -gt 0) {
                $count = 1
                foreach ($prod in $products) {
                    # Extrai Name, Status e 5 Dígitos via Regex
                    $name = if ($prod -match "(.*)") { $matches[1].Trim() } else { "Desconhecido" }
                    
                    $status = "Desconhecido"
                    if ($prod -match "LICENSE STATUS:\s*---(.*)---") { 
                        $status = $matches[1].Trim() 
                    } elseif ($prod -match "LICENSE STATUS:\s*(.*)") { 
                        $status = $matches[1].Trim() 
                    }

                    $key = if ($prod -match "Last 5 characters of installed product key:\s*(.*)") { $matches[1].Trim() } else { "N/A" }

                    Write-Host "`n------------------------------------------" -ForegroundColor Gray
                    Write-Host " LICENCA #$count" -ForegroundColor Green
                    Write-Host " Produto : $name" -ForegroundColor White
                    Write-Host " Status  : $status" -ForegroundColor Yellow
                    Write-Host " Chave   : Ultimos 5 digitos: $key" -ForegroundColor Green
                    
                    if ($key -eq "N/A") {
                        Write-Host " Nota    : Licenca associada a Conta/Subscription (sem chave local)." -ForegroundColor Gray
                    }
                    $count++
                }
            } else {
                Write-Host "`n[AVISO] Office instalado, mas nenhuma licenca valida foi encontrada no OSPP." -ForegroundColor Yellow
            }
            break
        }
    }

    if (-not $officeFound) {
        Write-Host "`n[ERRO] O script OSPP.VBS nao foi localizado." -ForegroundColor Red
        Write-Host "Verifique se o Microsoft Office esta instalado nesta maquina." -ForegroundColor Yellow
    }

    Write-Host "`n==========================================" -ForegroundColor Cyan
    Read-Host "Pressione Enter para continuar"
}

function Correcao-Leve {
    Clear-Host
    Write-Host "[EXEC] Correcao Leve" -ForegroundColor Cyan
    ipconfig /flushdns
    cd \
    tree
    Read-Host "`nPressione Enter para continuar"
}

function Correcao-Media {
    Clear-Host
    Write-Host "[EXEC] Correcao Media (SFC)" -ForegroundColor Cyan
    sfc /scannow
    Read-Host "`nPressione Enter para continuar"
}

function Correcao-Pesada {
    Clear-Host
    Write-Host "[ALERTA] OPCAO PESADA" -ForegroundColor Red
    Write-Host "===================================================" -ForegroundColor Red
    Write-Host "  __    _____  _____   _   _    ___    ~~      __" -ForegroundColor Red
    Write-Host "  /\      I    I       I\  I   /       /\     /  \" -ForegroundColor Red
    Write-Host " /==\     I    ====    I \ I  (       /==\   (    )" -ForegroundColor Red
    Write-Host "/    \    I    I____   I  \I   \___  /    \   \__/" -ForegroundColor Red
    Write-Host "                                 )" -ForegroundColor Red
    Write-Host "===================================================" -ForegroundColor Red
    Write-Host "ESTA OPCAO ACARRETARA EM REINICIAR O COMPUTADOR!" -ForegroundColor Red
    Write-Host "CERTIFIQUE-SE DE FECHAR TODOS OS APLICATIVOS ANTES" -ForegroundColor Yellow
    $confirm = Read-Host "Digite 1 para Continuar ou 2 para Voltar"
    if ($confirm -eq "1") {
        Write-Host "[EXEC] Agendando CHKDSK na proxima reinicializacao..." -ForegroundColor Cyan
        chkdsk /f
        shutdown -r -t 0
    }
}

function Agendar-Desligamento {
    $tipo = Read-Host "Digite 1 para Desligar ou 2 para Reiniciar"
    $unidade = Read-Host "Digite 1 para Minutos ou 2 para Horas"
    $qtde = Read-Host "Digite a quantidade (apenas numeros)"
    $segundos = if ($unidade -eq "1") { $qtde * 60 } else { $qtde * 3600 }
    if ($tipo -eq "1") { shutdown -s -t $segundos; Write-Host "Desligamento agendado em $qtde minutos/horas." }
    else { shutdown -r -t $segundos; Write-Host "Reinicializacao agendada em $qtde minutos/horas." }
    Read-Host "Pressione Enter para continuar"
}

function Cancelar-Agendamento {
    shutdown -a
    Write-Host "Agendamento cancelado." -ForegroundColor Green
    Read-Host "Pressione Enter para continuar"
}

function Informacoes-Sistema {
    Clear-Host
    Write-Host "[EXEC] Coletando informacoes do sistema..." -ForegroundColor Cyan
    systeminfo
    ipconfig
    Read-Host "`nPressione Enter para continuar"
}

function Ping-Rede {
    Clear-Host
    $ip = Read-Host "Digite o IP ou URL para ping"
    Write-Host "Pressione Ctrl+C para parar o ping." -ForegroundColor Yellow
    ping $ip -t
}

function Extensoes {
    assoc
    Read-Host "`nPressione Enter para continuar"
}

function Gerenciador-Tarefas {
    Clear-Host
    Write-Host "1-Listar processos" -ForegroundColor Cyan
    Write-Host "2-Finalizar processo" -ForegroundColor Cyan
    $op = Read-Host "Escolha"
    if ($op -eq "1") { tasklist }
    elseif ($op -eq "2") { $pid = Read-Host "Digite o PID"; taskkill /PID $pid /F }
    Read-Host "Pressione Enter para continuar"
}

function Verificar-Disco {
    chkdsk
    Read-Host "`nPressione Enter para continuar"
}

function Limpeza-Temporarios {
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Arquivos temporarios removidos." -ForegroundColor Green
    Read-Host "Pressione Enter para continuar"
}

function Configuracao-Rede {
    $op = Read-Host "Digite 1 para Liberar IP ou 2 para Renovar IP"
    if ($op -eq "1") { ipconfig /release }
    elseif ($op -eq "2") { ipconfig /renew }
    else { Write-Host "Opcao invalida." -ForegroundColor Red }
    Read-Host "Pressione Enter para continuar"
}

function Backup-Arquivos {
    $source = Read-Host "Digite o caminho de origem"
    $dest = Read-Host "Digite o caminho de destino"
    $log = Read-Host "Digite o caminho do log"
    if (-not (Test-Path $log)) { New-Item -ItemType Directory -Path $log -Force | Out-Null }
    robocopy $source $dest /E /LOG:"$log\backup_log.txt" /TEE /V
    Write-Host "Backup concluido. Log em $log\backup_log.txt" -ForegroundColor Green
    Read-Host "Pressione Enter para continuar"
}

function Ativar-Windows-Office {
    Write-Host "Ativador do Massgrave (Microsoft Activation Scripts)" -ForegroundColor Cyan
    Write-Host "Requer conexao com a internet." -ForegroundColor Yellow
    $confirm = Read-Host "Deseja continuar? (S/N)"
    if ($confirm -eq "S" -or $confirm -eq "s") {
        irm https://massgrave.dev/get | iex
    }
    Read-Host "Pressione Enter para continuar"
}

# --- LOOP PRINCIPAL ---
do {
    Show-Menu
    $choice = Read-Host "Escolha uma opcao"
    switch ($choice) {
        "0" { Write-Host "Saindo..." -ForegroundColor Green; break }
        "1" { 
            $sub = Read-Host "1-Leve 2-Media 3-Pesada 4-Voltar"
            if ($sub -eq "1") { Correcao-Leve }
            elseif ($sub -eq "2") { Correcao-Media }
            elseif ($sub -eq "3") { Correcao-Pesada }
        }
        "2" { Agendar-Desligamento }
        "3" { Informacoes-Sistema }
        "4" { Ping-Rede }
        "5" { Extensoes }
        "6" { Gerenciador-Tarefas }
        "7" { Verificar-Disco }
        "8" { Limpeza-Temporarios }
        "9" { Configuracao-Rede }
        "10" { Backup-Arquivos }
        "11" { Ativar-Windows-Office }
        "12" { Get-WindowsKey }
        "13" { Get-OfficeKey }
        default { Write-Host "Opcao invalida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")