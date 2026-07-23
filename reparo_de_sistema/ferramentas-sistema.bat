@echo off
:: ======================================
:: LANÇADOR INTEGRADO DE FERRAMENTAS v3.1
:: ======================================
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Get-Content '%~f0' -Encoding UTF8 | Select-Object -Skip 8 | Out-String | Invoke-Expression"
exit /b

<#
.SYNOPSIS
    Ferramentas Unificadas de TI, Reparo, Rede e Licenciamento.
.DESCRIPTION
    Estrutura hierárquica dividida em 4 categorias principais (1 a 4) 
    e submenus numéricos de 1 a 9, otimizada para Teclado Numérico (Numpad).
.NOTES
    Versão: 3.1
    Autor: Gabriel Lopes
#>

# Configura a sessão do PowerShell para UTF-8 nativo
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
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

# --- FUNÇÕES DE NAVEGAÇÃO INSTANTÂNEA ---

function Read-KeyChoice {
    $key = [Console]::ReadKey($true)
    return $key.KeyChar
}

# --- CABEÇALHO PADRÃO ---

function Draw-Header {
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
}

# --- 1. SUBMENU REDE ---

function Menu-Rede {
    do {
        Draw-Header
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
    Write-Host "--- CONFIGURAÇÕES DE REDE DA MÁQUINA ---`n" -ForegroundColor Cyan
    ipconfig /all
    Read-Host "`nPressione Enter para continuar"
}

# --- 2. SUBMENU REPARO ---

function Menu-Reparo {
    do {
        Draw-Header
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "             [ 2. FERRAMENTAS DE REPARO ]            " -ForegroundColor Green
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] Correcao de Sistema Leve (FlushDNS/Temp)" -ForegroundColor White
        Write-Host "  [2] Correcao de Sistema Media (SFC /Scannow)" -ForegroundColor White
        Write-Host "  [3] Correcao Avançada (DISM + SFC)" -ForegroundColor White
        Write-Host "  [4] Gerenciador de Tarefas / Processos" -ForegroundColor White
        Write-Host "  [5] Limpeza de Temporarios e Spooler de Impressao" -ForegroundColor White
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
    Write-Host "--- LIMPEZA DE ARQUIVOS TEMPORÁRIOS E SPOOLER ---`n" -ForegroundColor Cyan
    
    Write-Host "[1/3] Limpando pasta TEMP do usuario..." -ForegroundColor Yellow
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "[2/3] Limpando pasta TEMP do sistema..." -ForegroundColor Yellow
    Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "[3/3] Reiniciando e limpando Spooler de Impressao..." -ForegroundColor Yellow
    Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name "Spooler" -ErrorAction SilentlyContinue
    
    Write-Host "`n[SUCESSO] Limpeza concluida com sucesso!" -ForegroundColor Green
    Read-Host "Pressione Enter para continuar"
}

function Verificar-Disco {
    Clear-Host
    Write-Host "--- VERIFICAÇÃO E DIAGNÓSTICO DE DISCO (CHKDSK) ---`n" -ForegroundColor Cyan
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

# --- 3. SUBMENU SISTEMA ---

function Menu-Sistema {
    do {
        Draw-Header
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "            [ 3. INFORMAÇÕES E SISTEMA ]             " -ForegroundColor Green
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  [1] Informacoes Detalhadas do Hardware e OS" -ForegroundColor White
        Write-Host "  [2] Agendar Desligar ou Reiniciar" -ForegroundColor White
        Write-Host "  [3] Ativar Windows / Office (MAS Script)" -ForegroundColor White
        Write-Host "  [4] Diagnóstico / Chave do Windows" -ForegroundColor White
        Write-Host "  [5] Diagnóstico / Chave do Office" -ForegroundColor White
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
        }
    } while ($op -ne "0")
}

function Informacoes-Sistema {
    Clear-Host
    Write-Host "--- COMPILAÇÃO DE INFORMAÇÕES DO SISTEMA ---`n" -ForegroundColor Cyan
    
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
    Write-Host "--- AGENDAR DESLIGAMENTO OU REINICIALIZAÇÃO ---`n" -ForegroundColor Cyan
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

function Get-WindowsKey {
    Clear-Host
    Write-Host "--- DIAGNÓSTICO DE CHAVE DO WINDOWS ---`n" -ForegroundColor Cyan

    $osInfo = Get-CimInstance Win32_OperatingSystem
    Write-Host "Edicao do Windows : $($osInfo.Caption)" -ForegroundColor White
    Write-Host "Versao / Build    : $($osInfo.Version) (Build $($osInfo.BuildNumber))" -ForegroundColor Gray
    Write-Host "------------------------------------------" -ForegroundColor Gray

    $keysFound = 0

    try {
        $biosKey = (Get-CimInstance -Query 'select OA3xOriginalProductKey from SoftwareLicensingService').OA3xOriginalProductKey
        if ($biosKey -and $biosKey.Trim() -ne "") {
            $keysFound++
            Write-Host "`n[CHAVE 1: OEM / BIOS / PLACA-MÃE]" -ForegroundColor Green
            Write-Host " Chave Completa : $biosKey" -ForegroundColor Yellow
            Write-Host " Tipo de Licenca: OEM (Hardware de fabrica)" -ForegroundColor White
        }
    } catch {}

    try {
        $sls = Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL AND Name LIKE 'Windows%'" | 
               Where-Object { $_.PartialProductKey -and $_.ApplicationId -eq '55c9273a-2b2c-4032-9916-e0625a639257' } | 
               Select-Object -First 1

        if ($sls) {
            $keysFound++
            Write-Host "`n[CHAVE 2: LICENÇA INSTALADA NO SISTEMA]" -ForegroundColor Green
            Write-Host " Ultimos 5 digitos: .....-.....-.....-.....-$($sls.PartialProductKey)" -ForegroundColor Yellow
            Write-Host " Descricao        : $($sls.Description)" -ForegroundColor White
        }
    } catch {}

    if ($keysFound -eq 0) {
        Write-Host "`n[AVISO] Nenhuma chave valida encontrada no registro ou BIOS." -ForegroundColor Yellow
    }

    Read-Host "`nPressione Enter para continuar"
}

function Get-OfficeKey {
    Clear-Host
    Write-Host "--- DIAGNÓSTICO DE CHAVE DO OFFICE ---`n" -ForegroundColor Cyan

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

                    Write-Host "`n------------------------------------------" -ForegroundColor Gray
                    Write-Host " LICENCA #$count" -ForegroundColor Green
                    Write-Host " Produto : $name" -ForegroundColor White
                    Write-Host " Chave   : Ultimos 5 digitos: $key" -ForegroundColor Green
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

function Ativar-Windows-Office {
    Clear-Host
    Write-Host "--- ATIVAÇÃO DE WINDOWS E OFFICE (MAS Script) ---`n" -ForegroundColor Cyan
    Write-Host "Esta operacao executa o Microsoft Activation Scripts oficial." -ForegroundColor Yellow
    Write-Host "Requer conexao ativa com a internet." -ForegroundColor Yellow
    
    $confirm = Read-Host "`nDeseja abrir o ativador agora? (S/N)"
    if ($confirm -eq "S" -or $confirm -eq "s") {
        irm https://massgrave.dev/get | iex
    }
    Read-Host "`nPressione Enter para continuar"
}

# --- 4. SUBMENU ARQUIVOS ---

function Menu-Arquivos {
    do {
        Draw-Header
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "              [ 4. GESTÃO DE ARQUIVOS ]              " -ForegroundColor Green
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

# --- LOOP PRINCIPAL DO PROGRAMA ---

do {
    Draw-Header
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "        PAINEL DE FERRAMENTAS DE TI - v3.1           " -ForegroundColor Green
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] REDE        (Ping, IPConfig, Release/Renew, DNS)" -ForegroundColor White
    Write-Host "  [2] REPARO      (SFC, DISM, Processos, Temp, CHKDSK)" -ForegroundColor White
    Write-Host "  [3] SISTEMA     (Info Hardware, Agendador, Chaves, MAS)" -ForegroundColor White
    Write-Host "  [4] ARQUIVOS    (Backup Robocopy)" -ForegroundColor White
    Write-Host ""
    Write-Host "  [0] Sair do Programa" -ForegroundColor Red
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host " Escolha uma categoria (1-4): " -NoNewline -ForegroundColor Yellow

    $choice = Read-KeyChoice
    Write-Host $choice

    switch ($choice) {
        "1" { Menu-Rede }
        "2" { Menu-Reparo }
        "3" { Menu-Sistema }
        "4" { Menu-Arquivos }
        "0" { Write-Host "`nSaindo do programa..." -ForegroundColor Green; break }
        default { Write-Host "`nOpcao invalida!" -ForegroundColor Red; Start-Sleep -Milliseconds 800 }
    }
} while ($choice -ne "0")