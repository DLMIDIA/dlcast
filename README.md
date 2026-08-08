<div align="center">

# DLCast

**Seu próprio estúdio de transmissão ao vivo, rodando na sua rede.**

De drones e câmeras direto para o seu computador — com menos de 1 segundo de atraso.

[![Licença MIT](https://img.shields.io/badge/licen%C3%A7a-MIT-3fb950?style=flat-square)](LICENSE)
[![Versão](https://img.shields.io/badge/vers%C3%A3o-0.4.0-58a6ff?style=flat-square)](docs/09-VISAO-E-DECISOES.md)
[![macOS](https://img.shields.io/badge/macOS-12%2B-lightgrey?style=flat-square&logo=apple)](#-instalação)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078d4?style=flat-square&logo=windows)](#-instalação)
[![Sem instalação](https://img.shields.io/badge/instala%C3%A7%C3%A3o-n%C3%A3o%20precisa-3fb950?style=flat-square)](#-instalação)
[![Gratuito](https://img.shields.io/badge/pre%C3%A7o-gratuito-3fb950?style=flat-square)](#-licença)

[Instalação](#-instalação) · [Como funciona](#-como-funciona) · [Documentação](#-documentação) · [Equipamentos](#-equipamentos-compatíveis) · [Download](#-download)

</div>

---

## O problema

Quando você transmite direto do drone para o YouTube, três coisas acontecem:

<table>
<tr>
<td width="33%" valign="top">

### Atraso de 10 a 30s

Quem está no chão não consegue orientar o piloto pelo que vê na tela. Quando fala "vira à direita", o drone já passou.

</td>
<td width="33%" valign="top">

### Você perde o original

O que fica salvo é o vídeo que a plataforma recomprimiu — não o que o drone enviou.

</td>
<td width="33%" valign="top">

### Preso a uma plataforma

Um destino por vez. E sem internet, nada funciona.

</td>
</tr>
</table>

## A solução

O DLCast coloca o **seu computador no meio do caminho**. O vídeo chega primeiro em você — íntegro e quase instantâneo — e só então segue para onde você decidir.

<div align="center">

| | Direto pro YouTube | Com o DLCast |
|---|:---:|:---:|
| **Atraso** | 10 a 30 segundos | **menos de 1 segundo** |
| **Gravação** | recomprimida | **original, intacta** |
| **Destinos** | um por vez | **vários ao mesmo tempo** |
| **Sem internet** | não funciona | **funciona normalmente** |
| **Custo** | — | **gratuito** |

</div>

---

## Como funciona

```
   ┌──────────┐        ┌──────────┐         ┌─────────────────────────┐
   │ DJI Air 3│ rádio  │ DJI RC 2 │  Wi-Fi  │      SEU COMPUTADOR     │
   │  câmera  │───────▶│ controle │────────▶│         DLCast          │
   └──────────┘        └──────────┘  RTMP   └────────────┬────────────┘
                                                         │
                    ┌────────────┬───────────┬───────────┼───────────┐
                    ▼            ▼           ▼           ▼           ▼
               ┌─────────┐  ┌─────────┐ ┌────────┐ ┌────────┐ ┌──────────┐
               │ WebRTC  │  │   HLS   │ │  RTSP  │ │  SRT   │ │ Gravação │
               │  <1seg  │  │ 2-5seg  │ │  OBS   │ │ 4G/5G  │ │   .mp4   │
               └─────────┘  └─────────┘ └────────┘ └────────┘ └──────────┘
                    │
                    ▼                              ┌──────────────────────┐
              você assiste                         │ YouTube · Facebook   │
              na hora, sem                ────────▶│ Twitch · Instagram   │
              atraso                               └──────────────────────┘
```

> **O detalhe que confunde todo mundo:** o drone não fala com o computador. Ele fala com o controle, por rádio. Quem envia o vídeo pela rede é o **controle** — por isso é ele que precisa estar no mesmo Wi-Fi.

---

## Instalação

**Não tem instalação.** O servidor já vem dentro do projeto.

<table>
<tr>
<td width="50%" valign="top">

### macOS

1. Baixe e descompacte o pacote
2. Abra a pasta **`mac`**
3. Clique duas vezes em **`DLCast.command`**

O painel abre sozinho no navegador.

> Se aparecer "desenvolvedor não identificado", clique com o botão direito → **Abrir**. Acontece uma vez só.

</td>
<td width="50%" valign="top">

### Windows

1. Baixe e descompacte o pacote
2. Abra a pasta **`windows`**
3. Clique duas vezes em **`DLCast.bat`**

Quando o Windows perguntar, marque **Redes particulares** e permita.

> Se negar o firewall, o drone não conecta e o erro não dá pista nenhuma.

</td>
</tr>
</table>

Ou simplesmente abra **`COMECE-AQUI.html`** — ele detecta seu sistema e mostra só o que interessa.

### Opcionais

| Programa | Precisa? | Para quê |
|---|:---:|---|
| **MediaMTX** | **sim** | É o servidor. **Já vem incluso.** |
| FFmpeg | não | Retransmitir a YouTube/Facebook e gerar vídeo de teste |
| Python | não | Painel visual com estatísticas (já vem no macOS) |

Sem FFmpeg e sem Python o sistema **recebe e grava normalmente**.

---

## Download

<div align="center">

| Sistema | Arquivo | Tamanho |
|---|---|:---:|
| **macOS** (Apple Silicon + Intel) | [`DLCast-macOS.zip`](../../releases/latest) | ~52 MB |
| **Windows** (10/11, 64 bits) | [`DLCast-Windows.zip`](../../releases/latest) | ~27 MB |

**[⬇ Baixar a versão mais recente](../../releases/latest)**

</div>

Cada pacote leva apenas o que aquele sistema precisa — quem usa Windows não baixa binários de Mac.

---

## O painel

Depois de ligar, o painel abre no navegador. Funciona também no celular, pelo mesmo endereço.

```
┌──────────────────────────────────────────────────────────────┐
│  DLCast                                    ● TRANSMITINDO    │
├──────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────┐  │
│  │ ● GRAVANDO                              00:14:32       │  │
│  │                                                        │  │
│  │                  vídeo ao vivo                         │  │
│  │                    (WebRTC)                            │  │
│  │                                                        │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌────────┬────────┬────────┬────────┬────────┬───────────┐  │
│  │4.2 Mb/s│  720p  │  30    │ 340 ms │  0.1%  │     3     │  │
│  │consumo │resoluç.│quadros │ atraso │ perda  │assistindo │  │
│  └────────┴────────┴────────┴────────┴────────┴───────────┘  │
│                                                              │
│  [ ● Gravar ]  [ Informações técnicas ]  [ Tela cheia ]      │
└──────────────────────────────────────────────────────────────┘
```

**O que ele faz:**

- Vídeo ao vivo com menos de 1 segundo de atraso
- Métricas reais de qualidade — consumo, resolução, quadros, atraso e perda de pacotes
- Botão de gravação que **pergunta onde salvar** antes de começar
- Links prontos para copiar e colar no OBS, vMix ou VLC
- Identificação do equipamento que está transmitindo

---

## Equipamentos compatíveis

O DLCast não é exclusivo de drones. Aceita **qualquer fonte RTMP**.

| Equipamento | Como envia | Endereço |
|---|---|---|
| **Drones DJI** — Air 3, Mini 3/4, Mavic 3, Avata 2 | RTMP nativo no DJI Fly | `/drone` |
| **Sony** — ILME-FX30, PXW-Z200, HXR-NX800 | RTMP nativo no menu de rede | `/camera` |
| **Canon, Nikon, Panasonic** | via OBS + captura HDMI | `/obs` |
| **Celular** — iPhone, Android | app Larix Broadcaster | `/celular` |
| **GoPro, encoders** | RTMP nativo | qualquer nome |

Vários equipamentos podem transmitir **ao mesmo tempo**, cada um no seu endereço.

---

## Estrutura do projeto

A estrutura é dividida por sistema operacional: o que é específico de cada plataforma fica na sua pasta, o que é idêntico nos dois fica compartilhado.

```
DLCast/
│
├── COMECE-AQUI.html          ★ ponto de entrada — detecta seu sistema
│
├── mac/                      ══ só macOS ══
│   ├── DLCast.command           clique duplo para ligar
│   ├── DESLIGAR.command         clique duplo para desligar
│   ├── mediamtx-arm64           servidor (Apple Silicon)
│   ├── mediamtx-intel           servidor (Macs Intel)
│   ├── djio                     comandos de terminal
│   ├── backup.sh                backup versionado
│   └── empacotar.sh             gera os pacotes de distribuição
│
├── windows/                  ══ só Windows ══
│   ├── DLCast.bat               clique duplo para ligar
│   ├── mediamtx.exe             servidor
│   ├── djio.ps1                 comandos de PowerShell
│   └── LEIA-ME.txt              passo a passo
│
├── config/                   ══ compartilhado ══
│   └── mediamtx.yml             configuração, comentada linha a linha
│
├── src/web/                  ══ compartilhado ══
│   ├── index.html               instruções por equipamento
│   ├── painel.html              painel de controle
│   ├── sobre.html               sobre o projeto
│   └── instalar-windows.html    guia visual do Windows
│
├── docs/                     ══ compartilhado ══
│   └── (documentação completa)
│
├── recordings/                  seus vídeos gravados
└── logs/                        registros do servidor
```

---

## Portas usadas

| Porta | Protocolo | Para quê |
|:---:|---|---|
| **1935** | RTMP | **Entrada do drone** — a mais importante |
| 8889 | WebRTC | Saída mais rápida (menos de 1s) |
| 8888 | HLS | Saída compatível (celular, TV) |
| 8554 | RTSP | OBS, vMix, VLC |
| 8890 | SRT | Rede instável (4G/5G) |
| 8080 | HTTP | Painel de controle |
| 9997 | HTTP | API de controle |

---

## Comandos (opcional)

Quem preferir o terminal:

```bash
./mac/djio start          # liga o servidor
./mac/djio painel         # abre o painel
./mac/djio url            # mostra o endereço para o DJI Fly
./mac/djio status         # quem está transmitindo agora
./mac/djio monitor        # vigia conexões ao vivo (diagnóstico)
./mac/djio test 30        # testa sem o drone, por 30 segundos
./mac/djio doctor         # diagnóstico completo
./mac/djio restream youtube SUA-CHAVE
./mac/djio stop           # desliga tudo
```

No Windows, o equivalente é `.\windows\djio.ps1 <comando>`.

---

## Documentação

| Documento | O que tem |
|---|---|
| [**Guia Rápido**](docs/01-GUIA-RAPIDO.md) | Uma página para levar a campo |
| [**Documento Mestre**](docs/00-DOCUMENTO-MESTRE.md) | Tudo, em detalhe |
| [**Visão e Decisões**](docs/09-VISAO-E-DECISOES.md) | Por que o projeto existe e por que cada escolha foi feita |
| [**Solução de Problemas**](docs/06-TROUBLESHOOTING.md) | Quando algo não funciona |
| [**Estratégia Multiplataforma**](docs/07-ESTRATEGIA-MULTIPLATAFORMA.md) | Plano para virar aplicativo |
| [**Publicar no GitHub**](docs/08-PUBLICAR-NO-GITHUB.md) | Como distribuir o projeto |

---

## Os dois erros que travam todo mundo

> ### 1. O botão de transmitir não funciona no controle
>
> **É o microfone.** A partir do DJI Fly v1.16.0, o controle RC 2 exige um microfone conectado no USB-C. Sem ele o botão simplesmente não responde — e não aparece mensagem de erro nenhuma explicando isso.

> ### 2. "Falha ao conectar"
>
> O controle precisa estar no **mesmo Wi-Fi** que o computador. Se estiver e ainda assim falhar, rode `./mac/djio monitor` e tente transmitir: se nada aparecer, o roteador está isolando os aparelhos entre si (procure por *AP Isolation* nas configurações dele).

---

## Limites do equipamento

Não são defeitos do DLCast — são limites físicos do controle:

| Limite | Detalhe |
|---|---|
| **720p máximo** | O RC 2 não tem processador para codificar 1080p ao vivo |
| **Microfone obrigatório** | Exigência do app DJI Fly, não do servidor |
| **Taxa de bits 1–5 Mbps** | Definida pelo app DJI |

---

## Tecnologia

Construído sobre software livre, sem dependências de Node, Docker ou banco de dados.

| Peça | Papel | Licença |
|---|---|---|
| [MediaMTX](https://github.com/bluenviron/mediamtx) | Núcleo de mídia | MIT |
| [FFmpeg](https://ffmpeg.org) | Retransmissão (opcional) | LGPL/GPL |

**Por que MediaMTX e não SRS ou OvenMediaEngine?** Porque os dois usam AGPL-3.0, que obrigaria cada pessoa que recebesse este projeto a lidar com obrigações jurídicas. A licença MIT não cria obrigação nenhuma. O raciocínio completo está em [Visão e Decisões](docs/09-VISAO-E-DECISOES.md).

---

## Licença

[MIT](LICENSE) — use, copie, modifique e distribua à vontade, inclusive comercialmente.

---

<div align="center">

**DLCast** — desenvolvido por **Daniel Júnior** · [DL Mídia](mailto:contato@dlmidia.com.br)

Agência de marketing, soluções web, mapeamento, filmagem e captação.

*Projeto gratuito. O vídeo nunca sai da sua rede, a menos que você mande.*

</div>
