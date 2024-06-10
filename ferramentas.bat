@echo off
:inicio
cls

color 02
echo.
echo                                     .:\  
echo             /\                     /   : 
echo '`.        /;Z                    /    / 
echo \  \      /;Z                    /    /  
echo  \\ \    /;Z                    /  ///   
echo   \\ \  /;Z                    /  ///    
echo    \  \/_/____________________/    /     
echo     `/                         \  /      
echo     {  o    [+]       o  }'     Y         
echo      \_________________________/         
echo.
echo /''''''''''''''''''''''''''''''''''''''\   
echo -        FERRAMENTAS DE SISTEMA        -   
echo \....................................../
echo            -Por Gabriel Lopes
echo.
echo [1] Correcao De Sistema.
echo [2] Agendar Desligar/Reiniciar.
echo [3] Informacoes Do Sistema.
echo [4] Ping De Rede.
echo [5] Extensoes.
echo [6] Gerenciador De Tarefas.
echo [7] Verificar Disco.
echo [8] Limpeza De Temporarios.
echo [9] Configuracao De Rede.
echo [10] Backup De Arquivos.
echo [0] Sair.
set /p opcao= Escolha uma opcao: 
echo ------------------------------
if %opcao% equ 0 goto sair
if %opcao% equ 1 goto A
if %opcao% equ 2 goto B
if %opcao% equ 3 goto C
if %opcao% equ 4 goto D
if %opcao% equ 5 goto E
if %opcao% equ 6 goto F
if %opcao% equ 7 goto G
if %opcao% equ 8 goto H
if %opcao% equ 9 goto I
if %opcao% equ 10 goto J

:sair
exit

:A
cls
color 02 
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -       CORRECAO DE SISTEMA       -
echo \................................./
echo.
echo qual tipo de correcao gostaria de realizar?
echo 1-Leve.
echo 2-Media.
echo 3-Pesada.
echo 4-Voltar
set /p opcao= Escolha uma opcao: 
echo ------------------------------
if %opcao% equ 1 goto A1
if %opcao% equ 2 goto A2
if %opcao% equ 3 goto A3
if %opcao% equ 4 goto inicio

:A1
cls
color 02 
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -   CORRECAO DE SISTEMA - LEVE    -
echo \................................./
echo.
ipconfig/flushdns
cd/
tree
pause
goto inicio

:A2
cls
color 02 
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -   CORRECAO DE SISTEMA - MEDIA   -
echo \................................./
echo.
sfc/scannow
pause
goto inicio

:A3
cls
color 02 
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -  CORRECAO DE SISTEMA - PESADA   -
echo \................................./
echo.
color 04
echo ===================================================
echo   __    _____  _____   _   _    ___    ~~      __
echo   /\      I    I       I\  I   /       /\     /  \
echo  /==\     I    ====    I \ I  (       /==\   (    )
echo /    \    I    I____   I  \I   \___  /    \   \__/
echo                                  )
echo ===================================================
echo ESTA OPCAO ACARETARA EM REINICIAR O COMPUTADOR!
echo CERTIFIQUE DE FECHAR TODOS OS APLICATIVOS ANTES
echo DE APERTAR PARA CONTINUAR!!!
echo 1-Continuar.
echo 2-Voltar.
set /p opcao= Deseja continuar?: 
echo ------------------------------
if %opcao% equ 1 goto A21
if %opcao% equ 2 goto A
goto inicio

:A21
cls
color 02
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -  CORRECAO DE SISTEMA - PESADA   -
echo \................................./
echo.
echo Por gentileza, quando for solicitado
echo para executar a correcao na proxima 
echo reinicializacao, apertar "S" depois
echo "ENTER".
pause
chkdsk /f
shutdown -r -t 0
pause
goto inicio

:B
cls
color 02
echo.
echo /''''''''''''''''''''''''''''''''''''''''\
echo -       AGENDAR DESLIGAR/REINICIAR       -
echo \......................................../
echo.
echo o que gostaria de fazer?
echo 1-Desligar.
echo 2-Reiniciar.
echo 3-Cancelar Desligar/Reiniciar.
echo 4-Voltar.
set /p opcao= Escolha uma opcao: 
echo ------------------------------
if %opcao% equ 1 goto B1
if %opcao% equ 2 goto B2
if %opcao% equ 3 goto B3
if %opcao% equ 4 goto inicio

:B1
cls
echo.
echo /''''''''''''''''''''''''''''''''''\
echo -       AGENDAR DESLIGAMENTO       -
echo \................................../
echo.
echo Qual medida gostaria de usar?
echo 1-Minutos
echo 2-Horas
echo 3-voltar
set /p opcao= Escolha uma opcao: 
echo ------------------------------
if %opcao% equ 1 goto B11
if %opcao% equ 2 goto B12
if %opcao% equ 3 goto inicio

:B11
cls
echo.
echo /''''''''''''''''''''''''''''''''''\
echo -       AGENDAR DESLIGAMENTO       -
echo \................................../
echo.
echo Para daqui quantos minutos ocorrera o desligamento?
:inputLoop
set /p minutos=Digite a quantidade de tempo (apenas numeros): 

rem Verifique se a entrada é um número
echo %minutos% | findstr /R "[0-9]*" >nul
if errorlevel 1 (
    echo Valor invalido. Digite apenas números.
    goto inputLoop
)

set /a tempo=%minutos%*60

shutdown -s -t %tempo%

:B12
cls
echo.
echo /''''''''''''''''''''''''''''''''''\
echo -       AGENDAR DESLIGAMENTO       -
echo \................................../
echo.
echo Para daqui quantas horas ocorrera o desligamento?
:inputLoop
set /p horas=Digite a quantidade de tempo (apenas numeros): 


echo %horas% | findstr /R "[0-9]*" >nul
if errorlevel 1 (
    echo Valor invalido. Digite apenas numeros.
    goto inputLoop
)

set /a tempo=%horas%*3600

shutdown -s -t %tempo%

:B2
cls
echo.
echo /'''''''''''''''''''''''''''''''''''''\
echo -       AGENDAR REINICIALIZACAO       -
echo \...................................../
echo.
echo Qual medida gostaria de usar?
echo 1-Minutos
echo 2-Horas
echo 3-Voltar
set /p opcao= Escolha uma opcao: 
echo ------------------------------
if %opcao% equ 1 goto B11
if %opcao% equ 2 goto B12
if %opcao% equ 3 goto inicio

:B21
cls
echo.
echo /'''''''''''''''''''''''''''''''''''''\
echo -       AGENDAR REINICIALIZACAO       -
echo \...................................../
echo.
echo Para daqui quantos minutos ocorrera a reinicializacao?
:inputLoop
set /p minutos=Digite a quantidade de tempo (apenas numeros): 

rem Verifique se a entrada é um número
echo %minutos% | findstr /R "[0-9]*" >nul
if errorlevel 1 (
    echo Valor invalido. Digite apenas numeros.
    goto inputLoop
)

set /a tempo=%minutos%*60

shutdown -r -t %tempo%

:B22
cls
echo.
echo /'''''''''''''''''''''''''''''''''''''\
echo -       AGENDAR REINICIALIZACAO       -
echo \...................................../
echo.
echo Para daqui quantas horas ocorrera a reinicializacao?
:inputLoop
set /p horas=Digite a quantidade de tempo (apenas numeros): 

echo %horas% | findstr /R "[0-9]*" >nul
if errorlevel 1 (
    echo Valor invalido. Digite apenas numeros.
    goto inputLoop
)

set /a tempo=%horas%*3600

shutdown -r -t %tempo%

:B3
cls
echo.
echo /'''''''''''''''''''''''''''''''''''''\
echo -     CANCELAR DESLIGAR/REINICIAR     -
echo \...................................../
echo.
shutdown -a
pause
goto :B

:C
cls
color 02
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -      INFORMACOES DO SISTEMA     -
echo \................................./
echo.
systeminfo
ipconfig
pause
goto inicio

:D
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -           PING DE REDE          -
echo \................................./
echo.
:inputLoop
set /p ping=Digite o I.P. que deseja fazer o PING: 

echo %ping% | findstr /R "[0-9]*" >nul
if errorlevel 1 (
    echo Valor invalido. Digite apenas numeros.
    goto inputLoop
)
echo aperte CRTL + C para parar ping quando desejar.
ping %ping% -t

:E
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -             EXTESOES            -
echo \................................./
echo.
assoc
pause
goto inicio

:F
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -      GERENCIAMENTO DE TAREFAS   -
echo \................................./
echo.
echo 1-Listar processos.
echo 2-Finalizar processo.
echo 3-Voltar.
set /p opcao= Escolha uma opcao: 
echo ------------------------------
if %opcao% equ 1 goto F1
if %opcao% equ 2 goto F2
if %opcao% equ 3 goto inicio

:F1
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -       LISTA DE PROCESSOS       -
echo \................................./
echo.
tasklist
pause
goto :F

:F2
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -      FINALIZAR PROCESSO        -
echo \................................./
echo.
set /p pid=Digite o PID do processo: 
taskkill /PID %pid% /F
pause
goto :F

:G
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -        VERIFICAR DISCO         -
echo \................................./
echo.
echo Esta opcao ira verificar a integridade do disco.
chkdsk
pause
goto inicio

:H
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -      LIMPEZA DE TEMPORARIOS     -
echo \................................./
echo.
del /q/f/s %TEMP%\*
rd /s /q %TEMP%
echo Arquivos temporarios limpos.
pause
goto inicio

:I
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -      CONFIGURACOES DE REDE      -
echo \................................./
echo.
echo 1-Liberar IP.
echo 2-Renovar IP.
echo 3-Voltar.
set /p opcao= Escolha uma opcao: 
echo ------------------------------
if %opcao% equ 1 goto J1
if %opcao% equ 2 goto J2
if %opcao% equ 3 goto inicio

:I1
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -          LIBERAR IP            -
echo \................................./
echo.
ipconfig /release
pause
goto :I

:I2
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -          RENOVAR IP            -
echo \................................./
echo.
ipconfig /renew
pause
goto :I

:J
cls
echo.
echo /'''''''''''''''''''''''''''''''''\
echo -        BACKUP DE ARQUIVOS       -
echo \................................./
echo.
set /p source=Digite o caminho do diretorio de origem: 
set /p destination=Digite o caminho do diretorio de destino: 
set /p logpath=Digite o caminho do diretorio de log: 

if not exist "%logpath%" mkdir "%logpath%"

robocopy "%source%" "%destination%" /E /LOG:"%logpath%\backup_log.txt" /TEE /V
echo Backup concluido. O log pode ser encontrado em %logpath%\backup_log.txt
pause
goto inicio
