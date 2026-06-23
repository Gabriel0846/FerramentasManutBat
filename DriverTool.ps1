<#
.SYNOPSIS
    Ferramenta para backup e restauração de drivers do Windows.
.DESCRIPTION
    Permite exportar todos os drivers atuais para uma pasta e restaurá-los
    após uma nova instalação do Windows. Útil para evitar problemas com
    driver de rede offline.
.NOTES
    Autor: Adaptado para você
    Requer execução como Administrador.
#>

# Verifica se está rodando como administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script precisa ser executado como Administrador!" -ForegroundColor Red
    Write-Host "Feche e execute novamente com 'Executar como administrador'." -ForegroundColor Yellow
    pause
    exit
}

# Função para exibir menu
function Show-Menu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "      FERRAMENTA DE DRIVERS v1.0        " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Backup de Drivers (antes de formatar)" -ForegroundColor Yellow
    Write-Host "2. Restauracao de Drivers (apos instalar Windows)" -ForegroundColor Yellow
    Write-Host "3. Verificar se driver de rede esta no backup" -ForegroundColor Yellow
    Write-Host "0. Sair" -ForegroundColor Red
    Write-Host ""
}

# Função de Backup
function Backup-Drivers {
    Write-Host "`n--- BACKUP DE DRIVERS ---" -ForegroundColor Cyan
    $backupPath = Read-Host "Digite o caminho completo para salvar o backup (ex: D:\DriversBackup)"
    
    # Remove aspas se houver
    $backupPath = $backupPath.Trim('"')
    
    if (-not $backupPath) {
        Write-Host "Caminho invalido. Operacao cancelada." -ForegroundColor Red
        pause
        return
    }
    
    # Cria a pasta se não existir
    if (-not (Test-Path $backupPath)) {
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        Write-Host "Pasta criada: $backupPath" -ForegroundColor Green
    }
    
    Write-Host "Exportando drivers. Isso pode levar alguns minutos..." -ForegroundColor Yellow
    try {
        dism /online /export-driver /destination:"$backupPath" 2>&1 | Out-Host
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Backup concluido com sucesso em: $backupPath" -ForegroundColor Green
        } else {
            Write-Host "Erro durante o backup. Verifique o caminho e tente novamente." -ForegroundColor Red
        }
    } catch {
        Write-Host "Falha ao executar DISM: $_" -ForegroundColor Red
    }
    pause
}

# Função de Restauração
function Restore-Drivers {
    Write-Host "`n--- RESTAURACAO DE DRIVERS ---" -ForegroundColor Cyan
    $backupPath = Read-Host "Digite o caminho onde esta o backup (ex: D:\DriversBackup)"
    $backupPath = $backupPath.Trim('"')
    
    if (-not (Test-Path $backupPath)) {
        Write-Host "Pasta de backup nao encontrada: $backupPath" -ForegroundColor Red
        pause
        return
    }
    
    Write-Host "Instalando drivers a partir de: $backupPath" -ForegroundColor Yellow
    try {
        pnputil /add-driver "$backupPath\*.inf" /subdirs /install 2>&1 | Out-Host
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Drivers restaurados com sucesso!" -ForegroundColor Green
            Write-Host "Recomenda-se reiniciar o computador." -ForegroundColor Yellow
        } else {
            Write-Host "Alguns drivers podem nao ter sido instalados. Verifique os logs." -ForegroundColor Red
        }
    } catch {
        Write-Host "Falha na restauracao: $_" -ForegroundColor Red
    }
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
        Write-Host "`nTotal: $($netDrivers.Count) driver(s) de rede." -ForegroundColor Green
    } else {
        Write-Host "Nenhum driver de rede encontrado no backup!" -ForegroundColor Red
        Write-Host "Antes de formatar, certifique-se de que o driver de rede esta instalado e faca o backup novamente." -ForegroundColor Yellow
    }
    pause
}

# --- LOOP PRINCIPAL ---
do {
    Show-Menu
    $choice = Read-Host "Escolha uma opcao"
    switch ($choice) {
        "1" { Backup-Drivers }
        "2" { Restore-Drivers }
        "3" { Check-NetworkDriver }
        "0" { Write-Host "Saindo..."; break }
        default { Write-Host "Opcao invalida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")