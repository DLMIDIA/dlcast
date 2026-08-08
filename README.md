# DLCast

**Servidor próprio de transmissão ao vivo para drones DJI, rodando no seu Mac.**

Recebe o vídeo do drone, grava tudo automaticamente e redistribui em vários
formatos — inclusive retransmitindo para YouTube, Facebook e Twitch.

```
DJI Air 3 ──rádio──► DJI RC 2 ──Wi-Fi──► SEU MAC ──► você assiste em <1 segundo
                                              │
                                              └──► YouTube / Facebook / Twitch
```

---

## Por que usar isto em vez de transmitir direto pro YouTube

| | Direto pro YouTube | Com o DLCast |
|---|---|---|
| Atraso | 10 a 30 segundos | **menos de 1 segundo** |
| Gravação | o que o YouTube recomprimiu | **o original, intacto** |
| Destinos | um por vez | **vários ao mesmo tempo** |
| Sem internet | não funciona | **funciona normalmente** |

---

## Instalação

**Não tem instalação.** O servidor já vem dentro do projeto, nas versões para
macOS (Apple Silicon e Intel) e Windows.

| Seu sistema | O que fazer |
|---|---|
| **macOS** | Abra a pasta `mac` e clique duas vezes em `DLCast.command` |
| **Windows** | Abra a pasta `windows` e clique duas vezes em `DLCast.bat` |

Ou abra o arquivo **`COMECE-AQUI.html`**, que detecta seu sistema e mostra o
caminho certo.

### Opcional

O **FFmpeg** só é necessário para retransmitir a YouTube/Facebook e para gerar
vídeo de teste. O sistema recebe e grava sem ele.

```bash
brew install ffmpeg
```

---

## Uso pelo terminal (opcional)

```bash
./mac/djio start
```

```bash
./mac/djio painel
```

```bash
./mac/djio stop
```

O comando `start` já mostra na tela o endereço que você digita no controle DJI.
Rode `./mac/djio` sem argumentos para ver todos os comandos.

---

## Documentação

| Arquivo | Para quê |
|---|---|
| [Guia Rápido](docs/01-GUIA-RAPIDO.md) | Uma página para levar a campo |
| [Documento Mestre](docs/00-DOCUMENTO-MESTRE.md) | Tudo, em detalhe |
| [CLAUDE.md](CLAUDE.md) | Mapa técnico do projeto |

---

## Os dois erros mais comuns

**1. O botão de iniciar não funciona no controle.**
Falta o microfone. O DJI Fly v1.16.0+ exige um microfone conectado ao RC 2.

**2. "Falha ao conectar".**
O controle precisa estar no mesmo Wi-Fi que o Mac. E confira se o IP não
mudou, com `./mac/djio url`.

---

## Requisitos

- **macOS 12+** ou **Windows 10/11**
- Uma fonte de vídeo RTMP: drone DJI, câmera com RTMP nativo, OBS ou celular
- Nada além disso — o servidor vem incluso

| Programa | Obrigatório? | Para quê |
|---|---|---|
| MediaMTX | Sim — **já incluso** | O servidor |
| FFmpeg | Não | Retransmitir a plataformas |
| Python | Não (vem no macOS) | Painel visual |

---

## Licença

Software livre. MediaMTX é MIT; FFmpeg é LGPL/GPL. Pode copiar, modificar e
distribuir à vontade.
