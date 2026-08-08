#!/usr/bin/env bash
###############################################################################
# DLCast - Gerador de pacotes para distribuicao
#
# Cria dois arquivos .zip prontos para o usuario final, um por sistema:
#
#   dist/DLCast-macOS-v0.4.0.zip     -> para quem usa Mac
#   dist/DLCast-Windows-v0.4.0.zip   -> para quem usa Windows
#
# Cada pacote leva APENAS o que aquele sistema precisa. Quem usa Windows nao
# baixa 105 MB de binarios de Mac que nunca vai usar, e vice-versa.
#
# Uso:
#   ./mac/empacotar.sh
#
# Os arquivos gerados sao os que voce anexa em "Releases" no GitHub.
# Anexe os arquivos gerados em "Releases", no GitHub.
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

ok()    { echo "${VERDE}[OK]${FIM} $*"; }
erro()  { echo "${VERM}[ERRO]${FIM} $*" >&2; }
info()  { echo "${AZUL}[i]${FIM} $*"; }
aviso() { echo "${AMAR}[!]${FIM} $*"; }

VERSAO="$(cat config/VERSAO 2>/dev/null | tr -d '[:space:]')"
VERSAO="${VERSAO:-0.0.0}"

echo
echo "${NEG}=============================================================${FIM}"
echo "${NEG}  DLCast - Gerando pacotes para distribuicao (v${VERSAO})${FIM}"
echo "${NEG}=============================================================${FIM}"
echo

# Comeca do zero para nao misturar sobras de uma geracao anterior.
rm -rf dist
mkdir -p dist

###############################################################################
# Monta um pacote para um sistema.
#   $1 = nome do sistema (macOS ou Windows)
#   $2 = pasta especifica que entra (mac ou windows)
###############################################################################
montar_pacote() {
  local sistema="$1"
  local pasta_sistema="$2"
  local nome="DLCast-${sistema}-v${VERSAO}"
  local temp="dist/${nome}"

  info "Montando ${sistema}..."

  mkdir -p "$temp"

  # --- Arquivos comuns aos dois sistemas ------------------------------------
  # SUPORTE-IA.md e o arquivo que o usuario cola numa IA para resolver
  # problemas sozinho - vai nos dois pacotes.
  cp COMECE-AQUI.html README.md LICENSE SUPORTE-IA.md "$temp/" 2>/dev/null
  cp -R config src docs "$temp/" 2>/dev/null

  # A pagina "Resolver com IA" busca o arquivo dentro de src/web para o
  # botao de copiar funcionar; sem esta copia, o botao cai no plano B.
  cp SUPORTE-IA.md "$temp/src/web/SUPORTE-IA.md" 2>/dev/null


  # --- A pasta do sistema em questao ----------------------------------------
  cp -R "$pasta_sistema" "$temp/" 2>/dev/null

  # --- Pastas de trabalho, vazias mas presentes -----------------------------
  # Criadas aqui para o usuario ver onde as coisas vao aparecer, e para o
  # servidor nao falhar caso nao tenha permissao de criar pasta.
  mkdir -p "$temp/recordings" "$temp/logs"
  echo "As gravacoes aparecem aqui." > "$temp/recordings/LEIA-ME.txt"
  echo "Os registros do servidor aparecem aqui." > "$temp/logs/LEIA-ME.txt"

  # --- Limpeza: nada pessoal ou gerado pode vazar ---------------------------
  # ambiente.json tem os caminhos de pasta de QUEM GEROU o pacote.
  rm -f "$temp/src/web/ambiente.json"
  find "$temp" -name ".DS_Store" -delete 2>/dev/null
  find "$temp" -name "*.log" -delete 2>/dev/null

  # --- Compacta -------------------------------------------------------------
  ( cd dist && zip -qr "${nome}.zip" "${nome}" )
  rm -rf "$temp"

  local tam
  tam="$(du -h "dist/${nome}.zip" | cut -f1 | tr -d ' ')"
  ok "${sistema}: dist/${nome}.zip (${tam})"
}

# --- Confere se os binarios estao presentes antes de empacotar --------------
faltando=0
[ -f mac/mediamtx-arm64 ]     || { aviso "mac/mediamtx-arm64 nao encontrado"; faltando=1; }
[ -f mac/mediamtx-intel ]     || { aviso "mac/mediamtx-intel nao encontrado"; faltando=1; }
[ -f windows/mediamtx.exe ]   || { aviso "windows/mediamtx.exe nao encontrado"; faltando=1; }

if [ "$faltando" -eq 1 ]; then
  echo
  aviso "Os pacotes serao gerados SEM o servidor, e nao vao funcionar."
  info  "Baixe os binarios em: https://github.com/bluenviron/mediamtx/releases/latest"
  echo
fi

montar_pacote "macOS"   "mac"
montar_pacote "Windows" "windows"

echo
echo "${NEG}=============================================================${FIM}"
echo "${NEG}  PRONTO${FIM}"
echo "${NEG}=============================================================${FIM}"
echo
ls -lh dist/*.zip 2>/dev/null | awk '{printf "  %-8s %s\n", $5, $9}'
echo
info "Anexe estes arquivos em Releases, no GitHub."
info "Crie uma Release em: github.com/DLMIDIA/dlcast/releases/new"
echo
