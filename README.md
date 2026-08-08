<div align="center">

# DLCast

**Seu próprio estúdio de transmissão ao vivo, rodando na sua rede.**

De drones e câmeras direto para o seu computador — com menos de 1 segundo de atraso.

[![Licença MIT](https://img.shields.io/badge/licen%C3%A7a-MIT-3fb950?style=flat-square)](LICENSE)
[![Versão](https://img.shields.io/badge/vers%C3%A3o-0.5.0-58a6ff?style=flat-square)](docs/04-COMO-FUNCIONA-POR-DENTRO.md)
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
│   ├── 01-GUIA-RAPIDO.md
│   ├── 02-MANUAL-COMPLETO.md
│   ├── 03-SOLUCAO-DE-PROBLEMAS.md
│   └── 04-COMO-FUNCIONA-POR-DENTRO.md
│
├── SUPORTE-IA.md                arquivo de diagnóstico para IA
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
./mac/djio rede           # cria uma rede própria (sem Wi-Fi no local)
./mac/djio monitor        # vigia conexões ao vivo (diagnóstico)
./mac/djio test 30        # testa sem o drone, por 30 segundos
./mac/djio doctor         # diagnóstico completo
./mac/djio restream youtube SUA-CHAVE
./mac/djio stop           # desliga tudo
```

No Windows, o equivalente é `.\windows\djio.ps1 <comando>`.

---

## Voando onde não tem Wi-Fi

Fazenda, obra, mata fechada — sem rede nenhuma. Como o controle do drone
precisa de uma rede para alcançar o computador, o DLCast traz um assistente:

```bash
./mac/djio rede
```

Ele verifica se já dá para usar a rede atual e, se não houver, abre a tela de
configuração do sistema e explica exatamente o que marcar — em macOS ou
Windows.

<table>
<tr>
<td width="33%" valign="top">

### 1. Roteador de viagem

**O mais confiável.** Um roteador de bolso ligado a uma bateria USB. Não
consome o computador e tem alcance melhor.

</td>
<td width="33%" valign="top">

### 2. Computador vira roteador

**Sem hardware extra.** O assistente guia pelo Compartilhamento de Internet
(macOS) ou Ponto de Acesso Móvel (Windows).

</td>
<td width="33%" valign="top">

### 3. Cabo de rede

**Só para câmeras.** O RC 2 não tem porta Ethernet — serve para Sony FX30,
PXW-Z200 e afins.

</td>
</tr>
</table>

> **Duas coisas que confundem:** os sistemas operacionais foram feitos para
> *compartilhar internet*, não para criar rede isolada — por isso é preciso
> escolher uma interface como origem, mesmo sem cabo nem internet. E a placa
> Wi-Fi não faz dois papéis: ao criar a rede, o computador sai do Wi-Fi atual.

---

## Documentação

| | Documento | O que tem |
|:---:|---|---|
| **01** | [**Guia Rápido**](docs/01-GUIA-RAPIDO.md) | Uma página para levar a campo no dia do voo |
| **02** | [**Manual Completo**](docs/02-MANUAL-COMPLETO.md) | Tudo em detalhe: arquitetura, protocolos, operação e segurança |
| **03** | [**Solução de Problemas**](docs/03-SOLUCAO-DE-PROBLEMAS.md) | O método para achar o defeito em 30 segundos |
| **04** | [**Como Funciona por Dentro**](docs/04-COMO-FUNCIONA-POR-DENTRO.md) | Por que o projeto existe e o raciocínio de cada escolha técnica |
| 🤖 | [**Resolver com IA**](SUPORTE-IA.md) | Cole no ChatGPT ou Gemini e resolva sozinho |

Todas as páginas também estão em versão navegável dentro do sistema — abra
**`COMECE-AQUI.html`** e vá em *Documentação*.

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

**Por que MediaMTX e não SRS ou OvenMediaEngine?** Porque os dois usam AGPL-3.0, que obrigaria cada pessoa que recebesse este projeto a lidar com obrigações jurídicas. A licença MIT não cria obrigação nenhuma. O raciocínio completo está em [Visão e Decisões](docs/04-COMO-FUNCIONA-POR-DENTRO.md).

---

## Perguntas frequentes

<details>
<summary><b>Preciso de internet para usar?</b></summary>

<br>

Não. O DLCast funciona **inteiramente na rede local**. Você pode estar numa fazenda sem sinal de celular: leve um roteador portátil, conecte o computador e o controle nele, e tudo funciona — vídeo ao vivo e gravação.

A internet só é necessária se você quiser **retransmitir** para YouTube, Facebook ou Twitch.

</details>

<details>
<summary><b>Funciona com o meu drone?</b></summary>

<br>

Se o aplicativo dele tiver a opção **"RTMP personalizado"**, funciona. Isso inclui praticamente todos os DJI recentes: Air 3, Air 3S, Mini 3, Mini 4 Pro, Mavic 3, Avata 2, Neo.

O que muda é a resolução máxima, que depende do controle — não do DLCast.

</details>

<details>
<summary><b>Por que 720p e não 1080p ou 4K?</b></summary>

<br>

É limitação física do **controle**, não do servidor. O DJI RC 2 não tem processador suficiente para codificar 1080p ao vivo enquanto pilota o drone.

Com o controle DJI RC Pro, que tem processador melhor, dá para chegar a 1080p. O DLCast recebe o que o controle mandar — inclusive 4K, se algum equipamento enviar.

</details>

<details>
<summary><b>Quanto de espaço a gravação ocupa?</b></summary>

<br>

Cerca de **30 MB por minuto** em 720p, ou **1,8 GB por hora**.

O painel mostra a estimativa em tempo real, calculada com a taxa que está entrando de verdade. E na hora de gravar, você escolhe a pasta — dá para mandar direto para um HD externo.

</details>

<details>
<summary><b>Meu vídeo vai para algum servidor na internet?</b></summary>

<br>

**Não.** O DLCast roda no seu computador e o vídeo nunca sai da sua rede, a menos que você mande explicitamente para uma plataforma usando o comando de retransmissão.

Não há nuvem, não há cadastro, não há telemetria. Nada é enviado para lugar nenhum.

</details>

<details>
<summary><b>Posso transmitir para o YouTube e gravar ao mesmo tempo?</b></summary>

<br>

Sim, e é justamente uma das vantagens. A gravação guarda o vídeo **original**, sem a recompressão que a plataforma aplica. Se a live cair, o material fica salvo.

Dá inclusive para transmitir para várias plataformas simultaneamente, abrindo um comando de retransmissão para cada uma.

</details>

<details>
<summary><b>É seguro? Alguém pode invadir?</b></summary>

<br>

Por padrão o servidor aceita conexões **apenas da sua rede local**, sem senha — igual a uma impressora Wi-Fi de casa.

Ele **não deve ser exposto à internet** como está. Se você abrir a porta 1935 no roteador, qualquer pessoa poderá transmitir pelo seu servidor. Para esse caso existe configuração de senha, documentada no [Documento Mestre](docs/02-MANUAL-COMPLETO.md#12-segurança).

</details>

<details>
<summary><b>Preciso saber programar?</b></summary>

<br>

Não. Você clica duas vezes num arquivo e o painel abre no navegador.

Os comandos de terminal existem para quem quiser, mas são opcionais — tudo o que importa está no painel.

</details>

<details>
<summary><b>Posso usar comercialmente?</b></summary>

<br>

Pode. A licença MIT permite uso comercial, modificação e redistribuição, sem pagar nada e sem pedir autorização. Só é preciso manter o aviso de copyright.

</details>

<details>
<summary><b>Como atualizo para uma versão nova?</b></summary>

<br>

Baixe o pacote novo e substitua a pasta. Suas gravações ficam em `recordings/`, então copie essa pasta antes se tiver material lá dentro.

</details>

---

## Glossário

Termos que aparecem na documentação, explicados sem jargão:

| Termo | O que significa |
|---|---|
| **RTMP** | O "idioma" que o drone usa para enviar vídeo. Todas as plataformas aceitam. |
| **WebRTC** | Tecnologia do Google Meet e WhatsApp. Entrega vídeo com menos de 1 segundo de atraso. |
| **HLS** | Formato da Apple. Mais lento (2 a 5s), mas funciona em qualquer aparelho. |
| **RTSP** | Padrão de câmeras de segurança. É o que o OBS e o vMix entendem. |
| **SRT** | Formato que aguenta internet ruim, recuperando pacotes perdidos. |
| **Stream** | A transmissão em si — o fluxo de vídeo ao vivo. |
| **Chave / Stream Key** | Senha que identifica seu canal no YouTube. **Aqui não é necessária.** |
| **Bitrate / Taxa de bits** | Quantos dados por segundo o vídeo consome. Mais alto = melhor imagem. |
| **Latência / Atraso** | Tempo entre a câmera capturar e você ver na tela. |
| **Ingest** | A entrada do vídeo no servidor. |

---

## Suporte

<div align="center">

**Ficou com dúvida? Fale direto comigo.**

[![WhatsApp](https://img.shields.io/badge/WhatsApp-(62)%2092001--6146-25D366?style=for-the-badge&logo=whatsapp&logoColor=white)](https://wa.me/5562920016146)
[![Site](https://img.shields.io/badge/Site-dlmidia.com.br-58a6ff?style=for-the-badge&logo=googlechrome&logoColor=white)](https://dlmidia.com.br)
[![E-mail](https://img.shields.io/badge/E--mail-contato@dlmidia.com.br-d29922?style=for-the-badge&logo=gmail&logoColor=white)](mailto:contato@dlmidia.com.br)

</div>

**Antes de chamar**, vale conferir — resolve na maioria dos casos:

1. O **microfone** está conectado no controle? (causa nº 1)
2. O controle está no **mesmo Wi-Fi** que o computador?
3. Rode `./mac/djio doctor` — ele aponta o problema sozinho
4. Consulte a [Solução de Problemas](docs/03-SOLUCAO-DE-PROBLEMAS.md)

Encontrou um erro no projeto? Abra uma [issue aqui no GitHub](../../issues) — assim a correção ajuda todo mundo.

---

## Licença

[MIT](LICENSE) — use, copie, modifique e distribua à vontade, inclusive comercialmente.

---

<div align="center">

### DL Mídia

**Marketing · Soluções Web · Mapeamento · Filmagem · Captação**

Desenvolvido por **Daniel Júnior**, que opera drone e câmera no dia a dia —
este projeto nasceu de uma necessidade real de trabalho, não de uma ideia de laboratório.

[**dlmidia.com.br**](https://dlmidia.com.br) · [WhatsApp (62) 92001-6146](https://wa.me/5562920016146) · [contato@dlmidia.com.br](mailto:contato@dlmidia.com.br)

<br>

*Projeto gratuito. O vídeo nunca sai da sua rede, a menos que você mande.*

</div>
