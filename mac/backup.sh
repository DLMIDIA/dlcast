#!/usr/bin/env bash
###############################################################################
# DJIO - Sistema de backup versionado
#
# Tira uma "fotografia" completa do projeto e guarda em backups/, com data,
# hora e o motivo da versao. Nada e sobrescrito: cada backup e uma pasta nova.
#
# Uso:
#   ./mac/backup.sh                          (motivo automatico)
#   ./mac/backup.sh "antes de mudar a config"
#   ./mac/backup.sh --listar                 (mostra todos os backups)
#   ./mac/backup.sh --restaurar <pasta>      (volta a uma versao antiga)
#
# O QUE ENTRA NO BACKUP: codigo, configuracoes, documentacao e scripts.
# O QUE FICA DE FORA: videos gravados, logs e os proprios backups - eles sao
# pesados e recriaveis, e incluí-los faria cada backup dobrar de tamanho.
###############################################################################

set -uo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"; done
PROJECT_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
cd "$PROJECT_ROOT" || exit 1

DIR_BACKUP="backups"
INDICE="${DIR_BACKUP}/INDICE.md"
ARQ_VERSAO="config/VERSAO"

if [ -t 1 ]; then
  VERDE=$'\033[0;32m'; VERM=$'\033[0;31m'; AMAR=$'\033[0;33m'
  AZUL=$'\033[0;36m'; NEG=$'\033[1m'; FIM=$'\033[0m'
else
  VERDE=""; VERM=""; AMAR=""; AZUL=""; NEG=""; FIM=""
fi

ok()   { echo "${VERDE}[OK]${FIM} $*"; }
erro() { echo "${VERM}[ERRO]${FIM} $*" >&2; }
info() { echo "${AZUL}[i]${FIM} $*"; }

###############################################################################
# Lista os backups existentes
###############################################################################
listar() {
  echo
  echo "${NEG}BACKUPS SALVOS${FIM}"
  echo "-------------------------------------------------------------"

  if [ ! -d "$DIR_BACKUP" ] || [ -z "$(ls -A "$DIR_BACKUP" 2>/dev/null | grep -v INDICE.md)" ]; then
    info "Nenhum backup ainda. Crie o primeiro com: ./mac/backup.sh"
    return 0
  fi

  for d in "$DIR_BACKUP"/*/; do
    [ -d "$d" ] || continue
    local nome tam motivo
    nome="$(basename "$d")"
    tam="$(du -sh "$d" 2>/dev/null | cut -f1)"
    motivo="$(grep -m1 '^\*\*Motivo:\*\*' "$d/MANIFESTO.md" 2>/dev/null | sed 's/\*\*Motivo:\*\* //')"
    printf "  %-42s %6s  %s\n" "$nome" "$tam" "${motivo:-}"
  done

  echo
  local total
  total="$(du -sh "$DIR_BACKUP" 2>/dev/null | cut -f1)"
  echo "  ${NEG}Total: ${total}${FIM}"
  echo
}

###############################################################################
# Restaura uma versao anterior
###############################################################################
restaurar() {
  local origem="${1:-}"

  if [ -z "$origem" ]; then
    erro "Informe qual backup restaurar."
    listar
    return 1
  fi

  # Aceita tanto o nome da pasta quanto o caminho completo.
  [ -d "$origem" ] || origem="${DIR_BACKUP}/${origem}"

  if [ ! -d "$origem" ]; then
    erro "Backup nao encontrado: $origem"
    listar
    return 1
  fi

  echo
  echo "${AMAR}${NEG}ATENCAO${FIM}"
  echo "  Isto vai substituir os arquivos atuais pelos da versao:"
  echo "    $origem"
  echo
  echo "  Antes de mexer em qualquer coisa, sera criado automaticamente um"
  echo "  backup de seguranca do estado atual, entao nada se perde."
  echo
  printf "  Digite SIM para confirmar: "
  read -r resposta

  if [ "$resposta" != "SIM" ]; then
    info "Cancelado. Nada foi alterado."
    return 0
  fi

  criar "restauracao-automatica-antes-de-voltar-para-$(basename "$origem")" >/dev/null

  for pasta in config mac windows src docs; do
    if [ -d "$origem/$pasta" ]; then
      rm -rf "./$pasta"
      cp -R "$origem/$pasta" "./$pasta"
      ok "Restaurado: $pasta/"
    fi
  done

  for arquivo in README.md SUPORTE-IA.md; do
    [ -f "$origem/$arquivo" ] && cp "$origem/$arquivo" "./$arquivo" && ok "Restaurado: $arquivo"
  done

  chmod +x mac/* 2>/dev/null

  echo
  ok "Restauracao concluida."
  info "Reinicie o servidor: ./mac/djio restart"
}

###############################################################################
# Cria um novo backup
###############################################################################
criar() {
  local motivo="${1:-snapshot automatico}"

  local versao="0.1.0"
  [ -f "$ARQ_VERSAO" ] && versao="$(cat "$ARQ_VERSAO" 2>/dev/null | tr -d '[:space:]')"

  local carimbo destino
  carimbo="$(date +%Y-%m-%d_%H-%M-%S)"

  # Transforma o motivo em algo seguro para nome de pasta:
  # minusculas, sem acento, espacos viram hifen.
  local motivo_curto
  motivo_curto="$(echo "$motivo" \
    | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || echo "$motivo")"
  motivo_curto="$(echo "$motivo_curto" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs '[:alnum:]' '-' \
    | sed 's/^-*//; s/-*$//' \
    | cut -c1-40)"

  destino="${DIR_BACKUP}/v${versao}_${carimbo}_${motivo_curto}"

  mkdir -p "$destino"

  # Copia as pastas de trabalho (as que contem o que criamos).
  for pasta in config mac windows src docs; do
    [ -d "$pasta" ] && cp -R "$pasta" "$destino/" 2>/dev/null
  done

  # Remove os binarios do servidor da copia.
  #
  # Motivo: mediamtx-arm64, mediamtx-intel e mediamtx.exe somam cerca de
  # 160 MB e NUNCA mudam - sao arquivos de terceiros baixados prontos.
  # Inclui-los faria cada snapshot pesar isso a toa; em dez backups seriam
  # 1,6 GB de arquivos identicos. O MANIFESTO registra qual versao estava
  # em uso, que e a informacao que realmente importa para restaurar.
  rm -f "$destino/mac/mediamtx-arm64" \
        "$destino/mac/mediamtx-intel" \
        "$destino/windows/mediamtx.exe" 2>/dev/null

  # Copia os arquivos soltos da raiz.
  # A pasta windows/ fica de fora de proposito: o mediamtx.exe tem 53 MB e
  # faria cada backup pesar isso, sem necessidade - ele nunca muda.
  for arquivo in README.md SUPORTE-IA.md LICENSE COMECE-AQUI.html .gitignore; do
    [ -f "$arquivo" ] && cp "$arquivo" "$destino/" 2>/dev/null
  done

  # --- Gera o manifesto: a ficha de identidade deste backup ----------------
  {
    echo "# Manifesto do Backup"
    echo
    echo "**Versao:** v${versao}"
    echo "**Data:** $(date '+%d/%m/%Y as %H:%M:%S')"
    echo "**Motivo:** ${motivo}"
    echo "**Criado em:** $(hostname)"
    echo
    echo "---"
    echo
    echo "## Ambiente no momento do backup"
    echo
    echo "| Componente | Versao |"
    echo "|---|---|"
    echo "| macOS | $(sw_vers -productVersion 2>/dev/null) ($(uname -m)) |"
    echo "| MediaMTX | $(mediamtx --version 2>/dev/null | head -1 || echo 'nao instalado') |"
    echo "| FFmpeg | $(ffmpeg -version 2>/dev/null | head -1 | awk '{print $3}' || echo 'nao instalado') |"
    echo "| Python | $(python3 --version 2>/dev/null | awk '{print $2}' || echo 'nao instalado') |"
    echo "| Node | $(node --version 2>/dev/null || echo 'nao instalado') |"
    echo
    echo "## Arquivos incluidos"
    echo
    echo '```'
    (cd "$destino" && find . -type f -not -name MANIFESTO.md | sed 's|^\./||' | sort)
    echo '```'
    echo
    echo "## Como restaurar esta versao"
    echo
    echo '```bash'
    echo "./mac/backup.sh --restaurar $(basename "$destino")"
    echo '```'
  } > "$destino/MANIFESTO.md"

  # --- Atualiza o indice geral ---------------------------------------------
  if [ ! -f "$INDICE" ]; then
    {
      echo "# Indice de Backups - Projeto DJIO"
      echo
      echo "Historico de todas as versoes salvas do projeto, da mais antiga"
      echo "para a mais recente. Cada linha aponta para uma pasta completa e"
      echo "funcional do projeto naquele momento."
      echo
      echo "| Data | Versao | Motivo | Pasta |"
      echo "|---|---|---|---|"
    } > "$INDICE"
  fi

  echo "| $(date '+%d/%m/%Y %H:%M') | v${versao} | ${motivo} | \`$(basename "$destino")\` |" >> "$INDICE"

  local tam
  tam="$(du -sh "$destino" 2>/dev/null | cut -f1)"

  echo
  ok "Backup criado."
  echo "  Pasta  : $destino"
  echo "  Tamanho: $tam"
  echo "  Motivo : $motivo"
  echo
}

###############################################################################
# Roteador
###############################################################################
case "${1:-}" in
  --listar|-l|listar)      listar ;;
  --restaurar|-r|restaurar) restaurar "${2:-}" ;;
  --ajuda|-h|--help)
    sed -n '2,25p' "$0" | sed 's/^# \{0,1\}//'
    ;;
  *)                        criar "${1:-snapshot automatico}" ;;
esac
