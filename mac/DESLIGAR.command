#!/usr/bin/env bash
###############################################################################
# DLCast - Desligar o servidor
# Clique duplo neste arquivo para encerrar tudo.
###############################################################################

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

clear
echo
echo "  ==========================================================="
echo "    DLCast - Desligando"
echo "  ==========================================================="
echo

./mac/djio stop

echo
echo "  Tudo encerrado. As gravacoes continuam salvas."
echo
read -r -p "  Pressione Enter para fechar esta janela..."
