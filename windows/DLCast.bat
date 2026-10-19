@echo off
REM ############################################################################
REM  DLCast Pro v2.0 - Servidor de Transmissao de Drones (Windows)
REM  Menu Interativo (Basta dar um clique duplo)
REM ############################################################################

title DLCast Pro v2.0 - Studio Broadcast de Drones
cd /d "%~dp0.."

:menu
cls
echo.
echo  ===========================================================
echo    DLCast Pro v2.0 - Estudio de Transmissao de Drones
echo    por Daniel Junior . DL Midia
echo  ===========================================================
echo.
echo  Escolha como deseja iniciar:
echo.
echo  [1] Iniciar DLCast Local (Wi-Fi Domestico / Estudio)
echo  [2] Iniciar DLCast Nuvem com ngrok (4G/5G em Qualquer Lugar)
echo  [3] Conectar Conta Google / ngrok (Salvar Authtoken)
echo  [4] Abrir Painel Studio Pro e Replay Instantaneo
echo  [5] Testar Transmissao (Sem drone)
echo  [0] Sair
echo.
echo  -----------------------------------------------------------
set /p opt="Opcao [1-5, 0]: "

if "%opt%"=="1" goto iniciar_local
if "%opt%"=="2" goto iniciar_ngrok
if "%opt%"=="3" goto config_ngrok
if "%opt%"=="4" goto abrir_painel
if "%opt%"=="5" goto testar
if "%opt%"=="0" exit /b 0
goto iniciar_local

:iniciar_local
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0djio.ps1" start
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0djio.ps1" url
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0djio.ps1" painel
pause
goto menu

:iniciar_ngrok
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0djio.ps1" start
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0djio.ps1" ngrok start
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0djio.ps1" url
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0djio.ps1" painel
pause
goto menu

:config_ngrok
echo.
echo  1. Acesse: https://dashboard.ngrok.com/signup
echo  2. Clique em "Continue with Google"
echo  3. Copie seu Authtoken em: https://dashboard.ngrok.com/get-started/your-authtoken
echo.
set /p token="Cole seu Authtoken aqui: "
if not "%token%"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0djio.ps1" ngrok token %token%
)
pause
goto menu

:abrir_painel
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0djio.ps1" painel
pause
goto menu

:testar
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0djio.ps1" test 15
pause
goto menu
