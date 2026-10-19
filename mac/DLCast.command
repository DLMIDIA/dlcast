#!/usr/bin/env bash
###############################################################################
# DLCast Pro v2.0 - Servidor de Transmissão ao Vivo para Drones
# Menu Interativo para macOS (Clique duplo no Finder)
###############################################################################

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

VERDE=$'\033[0;32m'; AZUL=$'\033[0;36m'; AMAR=$'\033[0;33m'; NEG=$'\033[1m'; FIM=$'\033[0m'

menu() {
  clear
  echo
  echo "  ${AZUL}===========================================================${FIM}"
  echo "  ${NEG}  DLCast Pro v2.0 - Estúdio de Transmissão de Drones${FIM}"
  echo "  ${AZUL}===========================================================${FIM}"
  echo "    por Daniel Junior · DL Mídia"
  echo
  echo "  ${NEG}Escolha como deseja iniciar:${FIM}"
  echo
  echo "  ${VERDE}[1]${FIM} ${NEG}Iniciar DLCast Local${FIM} (Wi-Fi Doméstico / Estúdio)"
  echo "  ${AZUL}[2]${FIM} ${NEG}Iniciar DLCast Nuvem com ngrok${FIM} (4G/5G / Qualquer Lugar do Mundo)"
  echo "  ${AMAR}[3]${FIM} ${NEG}Conectar Conta Google / ngrok${FIM} (Salvar Authtoken)"
  echo "  ${VERDE}[4]${FIM} ${NEG}Abrir Painel Studio Pro & Replay Instantâneo${FIM}"
  echo "  [5] Testar Transmissão (Gerar barras de cores e áudio)"
  echo "  [6] Diagnóstico do Sistema (Doctor)"
  echo "  [0] Desligar e Sair"
  echo
  echo "  -----------------------------------------------------------"
  read -r -p "  Opção [1-6, 0]: " opt
  echo

  case "$opt" in
    1)
      ./mac/djio start
      ./mac/djio url
      ./mac/djio painel
      ;;
    2)
      ./mac/djio start
      ./mac/djio ngrok start
      ./mac/djio url
      ./mac/djio painel
      ;;
    3)
      echo "  1. Acesse: https://dashboard.ngrok.com/signup"
      echo "  2. Faça login com sua conta do Google"
      echo "  3. Copie seu Authtoken em: https://dashboard.ngrok.com/get-started/your-authtoken"
      echo
      read -r -p "  Cole seu authtoken aqui: " token
      if [ -n "$token" ]; then
        ./mac/djio ngrok token "$token"
      fi
      ;;
    4)
      ./mac/djio painel --direto
      ;;
    5)
      ./mac/djio test 15
      ;;
    6)
      ./mac/djio doctor
      ;;
    0)
      ./mac/djio stop
      exit 0
      ;;
    *)
      ./mac/djio start
      ./mac/djio painel
      ;;
  esac

  echo
  echo "  -----------------------------------------------------------"
  read -r -p "  Pressione Enter para voltar ao menu..."
  menu
}

menu
