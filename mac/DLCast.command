#!/usr/bin/env bash
###############################################################################
# DLCast - Servidor de transmissao ao vivo
# Arquivo de partida para macOS. Basta dar um clique duplo no Finder.
#
# Um arquivo .command e um script que o Finder sabe abrir no Terminal com
# clique duplo. E o equivalente do DLCast.bat do Windows: existe para que
# ninguem precise saber o que e um terminal para usar o projeto.
#
# Se o clique duplo nao funcionar na primeira vez, e porque o macOS ainda nao
# marcou o arquivo como executavel. Rode uma unica vez no Terminal:
#     chmod +x mac/DLCast.command
###############################################################################

# Sobe para a pasta principal do projeto (esta pasta e "mac")
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

clear

echo
echo "  ==========================================================="
echo "    DLCast - Servidor de Transmissao ao Vivo"
echo "    por Daniel Junior . DL Midia"
echo "  ==========================================================="
echo

# --- Confere as dependencias ------------------------------------------------
if ! command -v mediamtx >/dev/null 2>&1; then
  echo "  [ERRO] O MediaMTX nao esta instalado."
  echo
  echo "  COMO RESOLVER - copie e cole no Terminal:"
  echo
  echo "      brew install mediamtx ffmpeg"
  echo
  echo "  Se o comando 'brew' tambem nao existir, instale o Homebrew"
  echo "  primeiro, seguindo as instrucoes em https://brew.sh"
  echo
  echo "  Instrucoes completas: abra COMECE-AQUI.html"
  echo
  read -r -p "  Pressione Enter para fechar..."
  exit 1
fi

# --- Liga o servidor e o painel ---------------------------------------------
./mac/djio start

echo
echo "  -----------------------------------------------------------"
echo "    Abrindo o painel de controle no navegador..."
echo "  -----------------------------------------------------------"
echo

./mac/djio painel

echo
echo "  ==========================================================="
echo "    O servidor esta rodando em segundo plano."
echo
echo "    Voce pode FECHAR esta janela - o servidor continua no ar."
echo
echo "    Para desligar depois, de um clique duplo em:"
echo "        mac/DESLIGAR.command"
echo "  ==========================================================="
echo
read -r -p "  Pressione Enter para fechar esta janela..."
