#!/usr/bin/env bash
###############################################################################
# DJIO - Instalador
#
# Prepara um Mac novo para rodar o servidor. Feito para ser executado por
# alguem que nunca usou terminal: explica cada passo e nao assume nada.
#
# Uso:
#   ./mac/instalar.sh
###############################################################################

set -uo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"; done
PROJECT_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
cd "$PROJECT_ROOT" || exit 1

if [ -t 1 ]; then
  VERDE=$'\033[0;32m'; VERM=$'\033[0;31m'; AMAR=$'\033[0;33m'
  AZUL=$'\033[0;36m'; NEG=$'\033[1m'; FIM=$'\033[0m'
else
  VERDE=""; VERM=""; AMAR=""; AZUL=""; NEG=""; FIM=""
fi

ok()   { echo "${VERDE}[OK]${FIM} $*"; }
erro() { echo "${VERM}[ERRO]${FIM} $*" >&2; }
info() { echo "${AZUL}[i]${FIM} $*"; }

echo
echo "${NEG}=============================================================${FIM}"
echo "${NEG}  DJIO - INSTALACAO                                          ${FIM}"
echo "${NEG}  Servidor de transmissao ao vivo para drones DJI            ${FIM}"
echo "${NEG}=============================================================${FIM}"
echo

# --- 1. Sistema ------------------------------------------------------------
echo "${NEG}[1/5] Verificando o sistema${FIM}"

if [ "$(uname)" != "Darwin" ]; then
  erro "Este instalador e para macOS."
  exit 1
fi

versao_macos="$(sw_vers -productVersion)"
ok "macOS ${versao_macos} ($(uname -m))"
echo

# --- 2. Homebrew -----------------------------------------------------------
echo "${NEG}[2/5] Verificando o Homebrew${FIM}"
info "O Homebrew e o instalador de programas do Mac. Precisamos dele."
echo

if command -v brew >/dev/null 2>&1; then
  ok "Homebrew ja instalado ($(brew --version | head -1))"
else
  echo "${AMAR}O Homebrew nao esta instalado.${FIM}"
  echo
  echo "Abra o site oficial e siga a instrucao de instalacao:"
  echo "    ${NEG}https://brew.sh${FIM}"
  echo
  echo "Depois de instalar, rode este instalador novamente."
  echo
  info "Nao instalamos automaticamente porque o Homebrew pede a sua senha"
  info "de administrador, e voce deve digita-la apenas em um comando que"
  info "voce mesmo iniciou, vindo do site oficial."
  exit 1
fi
echo

# --- 3. Dependencias -------------------------------------------------------
echo "${NEG}[3/5] Instalando os programas necessarios${FIM}"
echo

faltando=()
command -v mediamtx >/dev/null 2>&1 || faltando+=("mediamtx")
command -v ffmpeg   >/dev/null 2>&1 || faltando+=("ffmpeg")

if [ ${#faltando[@]} -eq 0 ]; then
  ok "MediaMTX e FFmpeg ja estao instalados"
else
  info "Instalando: ${faltando[*]}"
  info "Isso pode demorar alguns minutos na primeira vez."
  echo
  if brew install "${faltando[@]}"; then
    ok "Programas instalados"
  else
    erro "A instalacao falhou. Tente rodar manualmente:"
    echo "    brew install ${faltando[*]}"
    exit 1
  fi
fi
echo

# --- 4. Permissoes e pastas ------------------------------------------------
echo "${NEG}[4/5] Preparando o projeto${FIM}"

chmod +x mac/* 2>/dev/null
ok "Comandos liberados para execucao"

mkdir -p logs recordings backups
ok "Pastas de trabalho criadas"

[ -f config/VERSAO ] || echo "0.1.0" > config/VERSAO
ok "Versao registrada: $(cat config/VERSAO)"
echo

# --- 5. Diagnostico --------------------------------------------------------
echo "${NEG}[5/5] Conferindo tudo${FIM}"
echo
./mac/djio doctor

# --- Conclusao -------------------------------------------------------------
echo
echo "${NEG}=============================================================${FIM}"
echo "${NEG}  PRONTO                                                     ${FIM}"
echo "${NEG}=============================================================${FIM}"
echo
echo "  Para comecar:"
echo
echo "    ${VERDE}./mac/djio start${FIM}     liga o servidor"
echo "    ${VERDE}./mac/djio painel${FIM}    abre a tela de controle"
echo "    ${VERDE}./mac/djio test${FIM}      testa sem precisar do drone"
echo
echo "  Antes do primeiro voo, leia o guia de campo:"
echo "    ${AZUL}docs/01-GUIA-RAPIDO.md${FIM}"
echo
echo "  ${AMAR}Lembrete:${FIM} o controle DJI RC 2 precisa de um microfone"
echo "  conectado para conseguir iniciar a transmissao."
echo
