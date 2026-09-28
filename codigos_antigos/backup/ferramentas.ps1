# Solicita o caminho da pasta ao usuário
$folder = Read-Host "Digite o caminho da pasta"

# Verifica se o caminho fornecido existe
if (-not (Test-Path $folder)) {
    Write-Host "O caminho especificado não existe." -ForegroundColor Red
    exit
}

# Solicita o tamanho mínimo dos arquivos em MB
$sizeMB = Read-Host "Digite o tamanho mínimo dos arquivos em MB"

# Verifica se o valor fornecido é um número
if (-not ([int]::TryParse($sizeMB, [ref]$null))) {
    Write-Host "Valor de tamanho inválido. Digite um número válido." -ForegroundColor Red
    exit
}

# Converte o tamanho de MB para bytes
$sizeMB = [int]$sizeMB
$sizeBytes = $sizeMB * 1MB

Write-Host "Buscando arquivos maiores que $sizeMB MB ($sizeBytes bytes) em $folder..."

# Faz a busca e exibe os arquivos encontrados
Get-ChildItem -Path $folder -Recurse -File | Where-Object { $_.Length -gt $sizeBytes } | Select-Object FullName | Format-Table -AutoSize

Write-Host "Busca concluída." -ForegroundColor Green
Read-Host -Prompt "Aperte Enter para continuar"