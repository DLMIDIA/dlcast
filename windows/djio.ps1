<#
################################################################################
 DJIO - Interface de linha de comando para Windows

 Equivalente ao script "djio" do macOS/Linux. Mesmos comandos, mesma logica.

 COMO USAR (PowerShell, na pasta do projeto):
     .\scripts\djio.ps1 start
     .\scripts\djio.ps1 painel
     .\scripts\djio.ps1 stop

 Se o Windows recusar a execucao de scripts, libere apenas para esta sessao:
     Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

 ATENCAO - FIREWALL: na primeira vez que o servidor subir, o Windows vai
 perguntar se o programa pode aceitar conexoes. Marque "Redes particulares" e
 permita. Se negar, o drone nao conseguira se conectar e a causa nao e obvia.

 STATUS: escrito para Windows 10/11, ainda NAO testado em maquina Windows.
################################################################################
#>

param(
    [Parameter(Position=0)][string]$Comando = "ajuda",
    [Parameter(Position=1)][string]$Arg1 = "",
    [Parameter(Position=2)][string]$Arg2 = ""
)

$ErrorActionPreference = "Continue"

# --- Localiza a raiz do projeto --------------------------------------------
# Todo o resto depende de estarmos na raiz, porque a configuracao usa
# caminhos relativos (o que torna o projeto portatil entre computadores).
$RaizProjeto = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $RaizProjeto

# --- Constantes ------------------------------------------------------------
$Config       = "config\mediamtx.yml"
$LogFile      = "logs\mediamtx.log"
$Api          = "http://127.0.0.1:9997/v3"
$StreamPadrao = "drone"

$PortaRtmp   = 1935
$PortaHls    = 8888
$PortaWebrtc = 8889
$PortaRtsp   = 8554
$PortaApi    = 9997
$PortaPainel = 8080

# --- Saida colorida --------------------------------------------------------
function Escrever-Ok    { param($t) Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host $t }
function Escrever-Erro  { param($t) Write-Host "[ERRO] " -ForegroundColor Red -NoNewline; Write-Host $t }
function Escrever-Aviso { param($t) Write-Host "[!] " -ForegroundColor Yellow -NoNewline; Write-Host $t }
function Escrever-Info  { param($t) Write-Host "[i] " -ForegroundColor Cyan -NoNewline; Write-Host $t }

function Escrever-Titulo {
    param($t)
    Write-Host ""
    Write-Host "=============================================================" -ForegroundColor White
    Write-Host " $t" -ForegroundColor White
    Write-Host "=============================================================" -ForegroundColor White
}

################################################################################
# Descobre o IP do computador na rede local.
#
# Este e o dado mais importante do projeto: e o endereco digitado no controle
# do drone. Procuramos a placa de rede que realmente atende a rota padrao,
# ignorando adaptadores virtuais (VirtualBox, VPN, WSL) que atrapalhariam.
################################################################################
function Obter-IpLocal {
    try {
        $rota = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction Stop |
                Sort-Object RouteMetric |
                Select-Object -First 1

        if ($rota) {
            $ip = Get-NetIPAddress -InterfaceIndex $rota.InterfaceIndex `
                                   -AddressFamily IPv4 -ErrorAction Stop |
                  Where-Object { $_.IPAddress -notlike "169.254.*" } |
                  Select-Object -First 1
            if ($ip) { return $ip.IPAddress }
        }
    } catch {}

    # Plano B: qualquer endereco de rede local valido.
    try {
        $ip = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
              Where-Object {
                  $_.IPAddress -notlike "127.*" -and
                  $_.IPAddress -notlike "169.254.*"
              } | Select-Object -First 1
        if ($ip) { return $ip.IPAddress }
    } catch {}

    return $null
}

function Servidor-Rodando {
    $null -ne (Get-Process -Name "mediamtx" -ErrorAction SilentlyContinue)
}

function Porta-EmUso {
    param($porta)
    $null -ne (Get-NetTCPConnection -LocalPort $porta -State Listen -ErrorAction SilentlyContinue)
}

################################################################################
# COMANDO: start
################################################################################
function Comando-Start {
    Escrever-Titulo "INICIANDO SERVIDOR DJIO"

    if (Servidor-Rodando) {
        Escrever-Aviso "O servidor JA esta rodando."
        Escrever-Info "Use '.\scripts\djio.ps1 status' para ver os detalhes."
        return
    }

    # Prioridade: o executavel que vem dentro da pasta windows\. Assim o
    # projeto funciona sem instalar nada, bastando copiar a pasta.
    # So depois procuramos uma instalacao no sistema, para quem prefere
    # manter atualizado por fora.
    $mediamtx = $null

    if (Test-Path "windows\mediamtx.exe") {
        $mediamtx = (Resolve-Path "windows\mediamtx.exe").Path
    } else {
        $doSistema = Get-Command mediamtx -ErrorAction SilentlyContinue
        if ($doSistema) {
            $mediamtx = $doSistema.Source
        } else {
            Escrever-Erro "O servidor MediaMTX nao foi encontrado."
            Escrever-Info "Ele deveria estar em: windows\mediamtx.exe"
            Escrever-Info "Se apagou por engano, baixe em:"
            Write-Host "    https://github.com/bluenviron/mediamtx/releases/latest"
            Escrever-Info "(escolha o arquivo terminado em windows_amd64.zip)"
            return
        }
    }

    if (-not (Test-Path $Config)) {
        Escrever-Erro "Configuracao nao encontrada: $Config"
        return
    }

    if (Porta-EmUso $PortaRtmp) {
        Escrever-Erro "A porta $PortaRtmp (RTMP) ja esta em uso por outro programa."
        Escrever-Info "Descubra quem esta usando com:"
        Write-Host "    Get-NetTCPConnection -LocalPort $PortaRtmp -State Listen"
        return
    }

    New-Item -ItemType Directory -Force -Path "logs","recordings" | Out-Null

    Start-Process -FilePath $mediamtx -ArgumentList $Config `
                  -WindowStyle Hidden -RedirectStandardOutput $LogFile `
                  -RedirectStandardError "logs\mediamtx.err.log"

    # Aguarda a porta aceitar conexao, em vez de supor que subiu.
    $tentativas = 0
    while ($tentativas -lt 20) {
        if (Porta-EmUso $PortaRtmp) {
            Escrever-Ok "Servidor no ar."
            Write-Host ""
            Comando-Url
            return
        }
        Start-Sleep -Milliseconds 250
        $tentativas++
    }

    Escrever-Erro "O servidor nao subiu. Ultimas linhas do log:"
    if (Test-Path $LogFile) { Get-Content $LogFile -Tail 15 }
}

################################################################################
# COMANDO: stop
################################################################################
function Comando-Stop {
    Escrever-Titulo "PARANDO SERVIDOR DJIO"

    # Encerra tambem o servidor do painel, se estiver no ar.
    Get-Process -Name "python","python3" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like "*http.server*" } |
        Stop-Process -Force -ErrorAction SilentlyContinue

    if (-not (Servidor-Rodando)) {
        Escrever-Aviso "O servidor ja estava parado."
        return
    }

    Stop-Process -Name "mediamtx" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 600

    if (Servidor-Rodando) {
        Escrever-Aviso "O servidor nao respondeu. Forcando encerramento."
        Stop-Process -Name "mediamtx" -Force -ErrorAction SilentlyContinue
    }

    Escrever-Ok "Servidor parado."
}

################################################################################
# COMANDO: url
################################################################################
function Comando-Url {
    $ip = Obter-IpLocal

    if (-not $ip) {
        Escrever-Erro "Nao consegui detectar o IP deste computador."
        Escrever-Aviso "Verifique se o Wi-Fi ou o cabo de rede esta conectado."
        return
    }

    Escrever-Titulo "DIGITE ISTO NO DJI FLY (controle RC 2)"
    Write-Host ""
    Write-Host "  rtmp://${ip}:${PortaRtmp}/${StreamPadrao}" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Caminho no controle:"
    Write-Host "    Ajustes > Transmissao > Plataformas de Transmissao > RTMP"
    Write-Host ""
    Write-Host "  LEMBRETES IMPORTANTES DO RC 2:" -ForegroundColor Yellow
    Write-Host "    1. O controle precisa estar no MESMO Wi-Fi que este computador."
    Write-Host "    2. A partir do DJI Fly v1.16.0 e obrigatorio ter um MICROFONE"
    Write-Host "       conectado ao controle, senao o botao de iniciar nao funciona."
    Write-Host "    3. O RC 2 transmite no maximo em 720p (limite do hardware dele)."
    Write-Host ""
    Write-Host "  Para assistir depois de iniciar:"
    Write-Host "    Navegador (rapido) : http://${ip}:${PortaWebrtc}/${StreamPadrao}"
    Write-Host "    Navegador (compat) : http://${ip}:${PortaHls}/${StreamPadrao}"
    Write-Host "    OBS / VLC          : rtsp://${ip}:${PortaRtsp}/${StreamPadrao}"
    Write-Host ""
}

################################################################################
# COMANDO: status
################################################################################
function Comando-Status {
    Escrever-Titulo "STATUS DO SERVIDOR DJIO"

    if (-not (Servidor-Rodando)) {
        Write-Host "  Estado: " -NoNewline; Write-Host "PARADO" -ForegroundColor Red
        Write-Host ""
        Escrever-Info "Inicie com: .\scripts\djio.ps1 start"
        return
    }

    $ip = Obter-IpLocal
    Write-Host "  Estado : " -NoNewline; Write-Host "RODANDO" -ForegroundColor Green
    Write-Host "  IP     : $ip"
    Write-Host ""

    try {
        $dados = Invoke-RestMethod -Uri "$Api/paths/list" -TimeoutSec 3
        $ativos = $dados.items | Where-Object { $_.ready }

        Write-Host "  TRANSMISSOES ATIVAS:" -ForegroundColor White
        if (-not $ativos) {
            Write-Host "    Nenhuma transmissao no ar. O servidor esta aguardando."
        } else {
            foreach ($p in $ativos) {
                $mb = [math]::Round($p.bytesReceived / 1MB, 1)
                Write-Host "    * $($p.name)"
                Write-Host "        recebido   : $mb MB"
                Write-Host "        faixas     : $($p.tracks -join ', ')"
                Write-Host "        assistindo : $($p.readers.Count) pessoa(s)"
            }
        }
    } catch {
        Escrever-Aviso "O processo esta vivo, mas a API nao respondeu."
    }
    Write-Host ""
}

################################################################################
# COMANDO: painel
################################################################################
function Comando-Painel {
    $ip = Obter-IpLocal
    if (-not $ip) { $ip = "127.0.0.1" }

    $pagina = "index.html"
    if ($Arg1 -eq "--direto") { $pagina = "painel.html" }
    $url = "http://${ip}:${PortaPainel}/${pagina}"

    if (Porta-EmUso $PortaPainel) {
        Escrever-Info "Painel ja estava no ar."
    } else {
        $python = Get-Command python -ErrorAction SilentlyContinue
        if (-not $python) { $python = Get-Command python3 -ErrorAction SilentlyContinue }

        if (-not $python) {
            Escrever-Erro "Python nao encontrado - necessario para servir o painel."
            Escrever-Info "Instale pela Microsoft Store ou em https://python.org"
            return
        }

        Start-Process -FilePath $python.Source `
            -ArgumentList "-m","http.server","$PortaPainel","--directory","src\web" `
            -WindowStyle Hidden
        Start-Sleep -Milliseconds 800
    }

    Escrever-Titulo "PAINEL DE CONTROLE DJIO"
    Write-Host ""
    Write-Host "  Neste computador:"
    Write-Host "    $url" -ForegroundColor Green
    Write-Host ""
    Write-Host "  No celular ou tablet (mesma rede Wi-Fi):"
    Write-Host "    $url"
    Write-Host ""

    Start-Process $url
}

################################################################################
# COMANDO: test
################################################################################
function Comando-Test {
    Escrever-Titulo "TESTE DO SISTEMA (sem o drone)"

    if (-not (Servidor-Rodando)) {
        Escrever-Erro "O servidor esta parado. Rode primeiro: .\scripts\djio.ps1 start"
        return
    }

    $ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if (-not $ffmpeg) {
        Escrever-Erro "FFmpeg nao encontrado."
        Escrever-Info "Instale com:  winget install Gyan.FFmpeg"
        return
    }

    $segundos = if ($Arg1) { $Arg1 } else { "30" }
    $ip = Obter-IpLocal

    Escrever-Info "Enviando video de teste por $segundos segundos..."
    Write-Host ""
    Write-Host "  Assista agora em:"
    Write-Host "    http://${ip}:${PortaWebrtc}/teste" -ForegroundColor Green
    Write-Host ""

    & ffmpeg -hide_banner -loglevel error -stats -re `
        -f lavfi -i "testsrc2=size=1280x720:rate=30" `
        -f lavfi -i "sine=frequency=1000:sample_rate=48000" `
        -c:v libx264 -preset veryfast -b:v 4000k -pix_fmt yuv420p -g 60 `
        -c:a aac -b:a 128k -ar 48000 `
        -t $segundos `
        -f flv "rtmp://127.0.0.1:$PortaRtmp/teste"

    Write-Host ""
    Escrever-Ok "Teste concluido."
}

################################################################################
# COMANDO: doctor
################################################################################
function Comando-Doctor {
    Escrever-Titulo "DIAGNOSTICO DO SISTEMA"
    $problemas = 0

    Write-Host "  SERVIDOR (obrigatorio)" -ForegroundColor White
    if (Test-Path "windows\mediamtx.exe") {
        Write-Host "    OK    MediaMTX (incluso na pasta windows)" -ForegroundColor Green
    } elseif (Get-Command mediamtx -ErrorAction SilentlyContinue) {
        Write-Host "    OK    MediaMTX (instalado no sistema)" -ForegroundColor Green
    } else {
        Write-Host "    FALTA MediaMTX - sem ele nada funciona" -ForegroundColor Red
        $problemas++
    }

    Write-Host ""
    Write-Host "  OPCIONAIS" -ForegroundColor White
    if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
        Write-Host "    OK    ffmpeg - retransmissao e testes disponiveis" -ForegroundColor Green
    } else {
        Write-Host "    --    ffmpeg ausente (so faz falta para retransmitir" -ForegroundColor Cyan
        Write-Host "          ao YouTube ou gerar video de teste)" -ForegroundColor Cyan
    }
    if ((Get-Command python -ErrorAction SilentlyContinue) -or (Get-Command python3 -ErrorAction SilentlyContinue)) {
        Write-Host "    OK    python - painel visual disponivel" -ForegroundColor Green
    } else {
        Write-Host "    --    python ausente (so faz falta para o painel)" -ForegroundColor Cyan
    }

    Write-Host ""
    Write-Host "  REDE" -ForegroundColor White
    $ip = Obter-IpLocal
    if ($ip) {
        Write-Host "    OK    IP local: $ip" -ForegroundColor Green
    } else {
        Write-Host "    FALTA Nenhum IP de rede detectado" -ForegroundColor Red
        $problemas++
    }

    Write-Host ""
    Write-Host "  PORTAS" -ForegroundColor White
    foreach ($p in @(@($PortaRtmp,"RTMP"), @($PortaHls,"HLS"), @($PortaWebrtc,"WebRTC"), @($PortaApi,"API"))) {
        if (Porta-EmUso $p[0]) {
            Write-Host "    OK    $($p[1]) ($($p[0])) - em uso" -ForegroundColor Green
        } else {
            Write-Host "    --    $($p[1]) ($($p[0])) - livre (servidor parado)" -ForegroundColor Cyan
        }
    }

    Write-Host ""
    Write-Host "  FIREWALL DO WINDOWS" -ForegroundColor White
    try {
        $perfis = Get-NetFirewallProfile -ErrorAction Stop
        foreach ($perfil in $perfis) {
            if ($perfil.Enabled) {
                Write-Host "    AVISO $($perfil.Name): ativo" -ForegroundColor Yellow
            } else {
                Write-Host "    OK    $($perfil.Name): desativado" -ForegroundColor Green
            }
        }
        Write-Host "    Se o drone nao conectar, autorize o mediamtx no firewall."
    } catch {
        Write-Host "    (nao foi possivel verificar)"
    }

    Write-Host ""
    if ($problemas -eq 0) {
        Escrever-Ok "Nenhum problema encontrado. Sistema pronto para voar."
    } else {
        Escrever-Aviso "$problemas ponto(s) de atencao acima."
    }
}

################################################################################
# AJUDA
################################################################################
function Comando-Ajuda {
    Write-Host ""
    Write-Host "DJIO" -ForegroundColor White -NoNewline
    Write-Host " - Servidor de transmissao para drones e cameras"
    Write-Host ""
    Write-Host "USO" -ForegroundColor White
    Write-Host "    .\scripts\djio.ps1 <comando>"
    Write-Host ""
    Write-Host "OPERACAO DIARIA" -ForegroundColor White
    Write-Host "    start            Liga o servidor"
    Write-Host "    stop             Desliga o servidor"
    Write-Host "    restart          Reinicia o servidor"
    Write-Host "    url              Mostra o endereco para o DJI Fly"
    Write-Host "    status           Mostra quem esta transmitindo"
    Write-Host "    painel           Abre a tela de controle"
    Write-Host ""
    Write-Host "VERIFICACAO" -ForegroundColor White
    Write-Host "    test [segundos]  Testa sem precisar do drone"
    Write-Host "    doctor           Diagnostica problemas"
    Write-Host ""
    Write-Host "PRIMEIRA VEZ? SIGA ESTA ORDEM" -ForegroundColor White
    Write-Host "    1. .\scripts\djio.ps1 doctor"
    Write-Host "    2. .\scripts\djio.ps1 start"
    Write-Host "    3. .\scripts\djio.ps1 test"
    Write-Host ""
}

################################################################################
# ROTEADOR
################################################################################
switch ($Comando.ToLower()) {
    "start"     { Comando-Start }
    "stop"      { Comando-Stop }
    "restart"   { Comando-Stop; Comando-Start }
    "status"    { Comando-Status }
    "url"       { Comando-Url }
    "painel"    { Comando-Painel }
    "dashboard" { Comando-Painel }
    "test"      { Comando-Test }
    "teste"     { Comando-Test }
    "doctor"    { Comando-Doctor }
    "ajuda"     { Comando-Ajuda }
    "help"      { Comando-Ajuda }
    default {
        Escrever-Erro "Comando desconhecido: $Comando"
        Comando-Ajuda
    }
}
