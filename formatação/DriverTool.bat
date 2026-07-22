@echo off
:: =========================================================================
:: LANÇADOR INTEGRADO CORRIGIDO v2.3 (UTF-8 FIX)
:: =========================================================================
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Get-Content '%~f0' -Encoding UTF8 | Select-Object -Skip 8 | Out-String | Invoke-Expression"
exit /b

<#
.SYNOPSIS
    Ferramenta para backup, restauração robusta e atualização de drivers do Windows.
.DESCRIPTION
    Desenvolvido para técnicos de TI garantirem a integridade de drivers de rede
    e periféricos antes e depois da formatação, com logs de erro detalhados.
.NOTES
    Versão: 2.3 (Fix de codificação de texto / ASCII Art)
    Autor: Gabriel Lopes (Aprimorado)
#>

# Configura a sessão do PowerShell para UTF-8 nativo
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Set-ExecutionPolicy Bypass -Scope Process -Force | Out-Null

# Verifica se está rodando como administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Este script precisa ser executado como Administrador!" -ForegroundColor Red
    Write-Host "Feche e execute novamente com 'Executar como administrador'." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Red
    pause
    exit
}

# Função para exibir menu com arte ASCII
function Show-Menu {
    Clear-Host
    Write-Host '88888888888888888888888888888888888888888888888888888' -ForegroundColor Green
    Write-Host '8888"""""""""""""""8888888888888888888888888888888888' -ForegroundColor Green
    Write-Host '8888               8888888888888888888888888888888888' -ForegroundColor Green
    Write-Host '8888               8888888888888888888888888888888888' -ForegroundColor Green
    Write-Host '8888               888888888888888888888888888888888"' -ForegroundColor Green
    Write-Host '8888aaaaaaaaaaaaaaa888888888888888888888888888888888a' -ForegroundColor Green
    Write-Host '88888888888888888888888888888888888888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888888888888888888888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888888888888888888888888888888888888' -ForegroundColor Green
    Write-Host '8888888888888888888888":::::"88888888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888::;gPPRg;::888888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888::dP''   `Yb::88888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888::8)     (8::88888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888;:Yb     dP:;88( )888888888888888' -ForegroundColor Green
    Write-Host '888888888888888888888;:"8ggg8":;888888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888888aa:::aa88888888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888888888888888888888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888888888888888888888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888888888"88888888888888888888888888' -ForegroundColor Green
    Write-Host '8888888888888888888888888:::8888888888888888888888888' -ForegroundColor Green
    Write-Host '8888888888888888888888888:::8888888888888888888888888' -ForegroundColor Green
    Write-Host '8888888888888888888888888:::8888888888888888888888888' -ForegroundColor Green
    Write-Host '8888888888888888888888888:::8888888888888888888888888' -ForegroundColor Green
    Write-Host '8888888888888888888888888:::8888888888888888888888888' -ForegroundColor Green
    Write-Host '88888888888888888888888888a88888888888888888888888888' -ForegroundColor Green
    Write-Host '"""""""""""""""""""'' `"""""""""'' `"""""""""""""""""""' -ForegroundColor Green
    Write-Host '                                   Normand  Veilleux' -ForegroundColor DarkGray
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "       GERENCIADOR AVANCADO DE DRIVERS v2.3          " -ForegroundColor Green
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[1] Backup de Drivers (Antes de Formatar)" -ForegroundColor Yellow
    Write-Host "[2] Restauracao de Drivers + Tratamento de Erros" -ForegroundColor Yellow
    Write-Host "[3] Verificar se Driver de Rede está no Backup" -ForegroundColor Yellow
    Write-Host "[4] Buscar Atualizacoes de Drivers Online (MS Update)" -ForegroundColor Cyan
    Write-Host "[0] Sair" -ForegroundColor Red
    Write-Host ""
}

# Função de Backup
function Backup-Drivers {
    Write-Host "`n--- BACKUP DE DRIVERS ---" -ForegroundColor Cyan
    $backupPath = Read-Host "Digite o caminho completo para salvar o backup (ex: D:\DriversBackup)"
    $backupPath = $backupPath.Trim('"')
    
    if (-not $backupPath) {
        Write-Host "Caminho invalido. Operacao cancelada." -ForegroundColor Red
        pause
        return
    }
    
    if (-not (Test-Path $backupPath)) {
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        Write-Host "Pasta criada: $backupPath" -ForegroundColor Green
    }
    
    Write-Host "Exportando drivers de terceiros instalados no sistema..." -ForegroundColor Yellow
    try {
        pnputil /export-driver * "$backupPath" | Out-Null
        dism /online /export-driver /destination:"$backupPath" 2>&1 | Out-Null
        
        Write-Host "`n[SUCCESS] Backup concluido com sucesso em: $backupPath" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Falha grave ao exportar os drivers: $_" -ForegroundColor Red
    }
    pause
}

# Função de Restauração Individual com Tratamento de Erro e LOG
function Restore-Drivers {
    Write-Host "`n--- RESTAURACAO DE DRIVERS INDIVIDUALIZADA ---" -ForegroundColor Cyan
    $backupPath = Read-Host "Digite o caminho onde esta o backup (ex: D:\DriversBackup)"
    $backupPath = $backupPath.Trim('"')
    
    if (-not (Test-Path $backupPath)) {
        Write-Host "Pasta de backup nao encontrada: $backupPath" -ForegroundColor Red
        pause
        return
    }
    
    $infFiles = Get-ChildItem -Path $backupPath -Filter "*.inf" -Recurse
    if ($infFiles.Count -eq 0) {
        Write-Host "[WARNING] Nenhum arquivo .inf encontrado na pasta informada." -ForegroundColor Yellow
        pause
        return
    }
    
    Write-Host "`nLocalizados $($infFiles.Count) drivers para instalacao." -ForegroundColor Cyan
    $logFile = Join-Path $backupPath "log_erros_drivers.txt"
    if (Test-Path $logFile) { Remove-Item $logFile -Force }
    
    $sucessoCount = 0
    $falhaCount = 0
    $total = $infFiles.Count
    $index = 1
    
    Write-Host "Iniciando instalacao agressiva. Aguarde..." -ForegroundColor Yellow
    
    foreach ($file in $infFiles) {
        $percent = [math]::Round(($index / $total) * 100)
        Write-Host -NoNewline "`r[$percent%] Processando driver ($index/$total): $($file.Name) ... " -ForegroundColor Gray
        
        $process = Start-Process pnputil -ArgumentList "/add-driver `"$($file.FullName)`" /install" -NoNewWindow -PassThru -Wait
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            $sucessoCount++
        } else {
            $falhaCount++
            $errorMessage = "Erro codigo $($process.ExitCode) ao tentar instalar o driver: $($file.FullName)"
            Add-Content -Path $logFile -Value $errorMessage
        }
        $index++
    }
    
    Write-Host "`n`n==========================================" -ForegroundColor Cyan
    Write-Host "          RESUMO DA INSTALACAO           " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "Drivers instalados com SUCESSO: $sucessoCount" -ForegroundColor Green
    
    if ($falhaCount -gt 0) {
        Write-Host "Drivers que FALHARAM: $falhaCount" -ForegroundColor Red
        Write-Host "Verifique os detalhes das falhas em: $logFile" -ForegroundColor Yellow
    } else {
        Write-Host "Todos os drivers foram reinstalados sem nenhum erro!" -ForegroundColor Green
    }
    
    Write-Host "`nRecomenda-se reiniciar o computador para aplicar todas as alteracoes." -ForegroundColor Yellow
    pause
}

# Função para verificar driver de rede no backup
function Check-NetworkDriver {
    Write-Host "`n--- VERIFICAR DRIVER DE REDE NO BACKUP ---" -ForegroundColor Cyan
    $backupPath = Read-Host "Digite o caminho do backup (ex: D:\DriversBackup)"
    $backupPath = $backupPath.Trim('"')
    
    if (-not (Test-Path $backupPath)) {
        Write-Host "Pasta nao encontrada." -ForegroundColor Red
        pause
        return
    }
    
    Write-Host "Procurando drivers de rede (Ethernet/Wi-Fi)..." -ForegroundColor Yellow
    $netDrivers = Get-ChildItem -Path $backupPath -Recurse -Filter "*.inf" | Where-Object {
        (Get-Content $_.FullName -Raw) -match "Class\s*=\s*Net"
    }
    
    if ($netDrivers) {
        Write-Host "Drivers de rede encontrados:" -ForegroundColor Green
        $netDrivers | ForEach-Object { Write-Host " - $($_.FullName)" -ForegroundColor White }
        Write-Host "`nTotal: $($netDrivers.Count) driver(s) de rede prontos para recuperacao." -ForegroundColor Green
    } else {
        Write-Host "Nenhum driver de rede encontrado no backup!" -ForegroundColor Red
        Write-Host "Antes de formatar, certifique-se de que o driver de rede esta instalado e faca o backup novamente." -ForegroundColor Yellow
    }
    pause
}

# Função para buscar atualizações de drivers pelo Windows Update
function Search-DriverUpdates {
    Write-Host "`n--- BUSCAR E ATUALIZAR DRIVERS VIA WINDOWS UPDATE ---" -ForegroundColor Cyan
    Write-Host "[INFO] Requer conexao ativa com a internet." -ForegroundColor Yellow
    
    $confirm = Read-Host "Deseja iniciar a busca por atualizações de drivers de hardware agora? (S/N)"
    if ($confirm -ne "S" -and $confirm -ne "s") { return }
    
    Write-Host "`nConectando aos servidores do Windows Update (isso pode demorar)..." -ForegroundColor Yellow
    
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Driver'")
        
        if ($searchResult.Updates.Count -eq 0) {
            Write-Host "[SUCCESS] Todos os drivers da máquina ja estao atualizados conforme a Microsoft." -ForegroundColor Green
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
                    Write-Host "[SUCCESS] Todos os drivers foram atualizados com sucesso!" -ForegroundColor Green
                } else {
                    Write-Host "[WARNING] Ocorreu um problema ao instalar alguns drivers. Codigo do erro: $($installationResult.ResultCode)" -ForegroundColor Yellow
                }
            } else {
                Write-Host "[ERROR] Falha ao baixar os drivers dos servidores da Microsoft." -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "[ERROR] Nao foi possivel consultar o Windows Update: $_" -ForegroundColor Red
    }
    
    Read-Host "`nPressione Enter para voltar ao menu"
}

# --- LOOP PRINCIPAL ---
do {
    Show-Menu
    $choice = Read-Host "Escolha uma opcao"
    switch ($choice) {
        "1" { Backup-Drivers }
        "2" { Restore-Drivers }
        "3" { Check-NetworkDriver }
        "4" { Search-DriverUpdates }
        "0" { Write-Host "Saindo..."; break }
        default { Write-Host "Opcao invalida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")