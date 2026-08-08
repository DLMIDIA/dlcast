@echo off
REM ############################################################################
REM  DLCast - Servidor de transmissao ao vivo
REM  Arquivo de partida para Windows. Basta dar um clique duplo.
REM
REM  Este arquivo e um .bat puro de proposito: scripts .ps1 podem ser
REM  bloqueados pela politica de execucao do Windows, e um usuario comum nao
REM  tem como adivinhar isso. Comandos PowerShell chamados aqui dentro sao
REM  de linha unica, que a politica nao bloqueia.
REM
REM  O mediamtx.exe fica nesta mesma pasta, entao nao e preciso copiar nada.
REM  Mas o servidor precisa RODAR a partir da pasta principal, porque a
REM  configuracao usa caminhos relativos (e isso que torna o projeto portatil).
REM ############################################################################

title DLCast - Servidor de Transmissao

REM Sobe para a pasta principal do projeto (esta pasta e "windows")
cd /d "%~dp0.."

echo.
echo  ===========================================================
echo    DLCast - Servidor de Transmissao ao Vivo
echo    por Daniel Junior . DL Midia
echo  ===========================================================
echo.

REM --- Confere se esta tudo no lugar --------------------------------------
if not exist "windows\mediamtx.exe" (
    echo  [ERRO] O arquivo mediamtx.exe nao foi encontrado.
    echo.
    echo  Ele deveria estar na pasta "windows", junto deste arquivo.
    echo  Se voce apagou por engano, baixe de novo em:
    echo    https://github.com/bluenviron/mediamtx/releases/latest
    echo  (escolha o arquivo terminado em windows_amd64.zip)
    echo.
    pause
    exit /b 1
)

if not exist "config\mediamtx.yml" (
    echo  [ERRO] Configuracao nao encontrada: config\mediamtx.yml
    echo.
    echo  Parece que a pasta do DLCast esta incompleta.
    echo  Copie a pasta inteira novamente.
    echo.
    pause
    exit /b 1
)

REM --- Descobre o IP desta maquina na rede local --------------------------
REM Pega o endereco da placa que realmente atende a rota padrao, ignorando
REM adaptadores virtuais (VPN, VirtualBox, WSL) que apontariam para o lugar
REM errado e fariam o drone tentar conectar num endereco inexistente.
set "IP="
for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-NetIPConfiguration ^| Where-Object {$_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up'} ^| Select-Object -First 1).IPv4Address.IPAddress" 2^>nul') do set "IP=%%i"

if "%IP%"=="" (
    for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 ^| Where-Object {$_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*'} ^| Select-Object -First 1).IPAddress" 2^>nul') do set "IP=%%i"
)

if "%IP%"=="" (
    echo  [AVISO] Nao consegui descobrir o IP deste computador.
    echo  Verifique se o Wi-Fi ou o cabo de rede esta conectado.
    echo.
    set "IP=SEU-IP-AQUI"
)

REM --- Mostra o que o usuario precisa saber -------------------------------
echo  -----------------------------------------------------------
echo    DIGITE ISTO NO DJI FLY (controle do drone):
echo.
echo        rtmp://%IP%:1935/drone
echo.
echo  -----------------------------------------------------------
echo.
echo    Caminho no controle:
echo      Ajustes ^> Transmissao ^> Plataformas de Transmissao ^> RTMP
echo.
echo    LEMBRETES IMPORTANTES:
echo      1. O controle precisa estar no MESMO Wi-Fi que este PC
echo      2. E OBRIGATORIO ter um microfone conectado no controle,
echo         senao o botao de iniciar nao funciona (DJI Fly 1.16+)
echo      3. O controle RC 2 transmite no maximo em 720p
echo.
echo    Para assistir ao vivo, abra no navegador:
echo      http://%IP%:8889/drone
echo.
echo  -----------------------------------------------------------
echo.
echo    Na primeira vez, o Windows vai perguntar sobre o firewall.
echo    Marque "Redes particulares" e clique em "Permitir acesso".
echo.
echo    NAO FECHE ESTA JANELA enquanto estiver transmitindo.
echo    Para desligar o servidor, feche esta janela.
echo.
echo  -----------------------------------------------------------
echo.

REM --- Cria as pastas de trabalho -----------------------------------------
if not exist "logs" mkdir "logs"
if not exist "recordings" mkdir "recordings"

REM --- Sobe o servidor ----------------------------------------------------
windows\mediamtx.exe config\mediamtx.yml

REM Se chegou aqui, o servidor parou. Mantem a janela aberta para o usuario
REM conseguir ler a mensagem de erro em vez de a janela sumir na hora.
echo.
echo  ===========================================================
echo    O servidor foi encerrado.
echo  ===========================================================
echo.
pause
