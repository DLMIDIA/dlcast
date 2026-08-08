# DLCast — Documento Mestre

**Servidor próprio de transmissão ao vivo para drones DJI**

| | |
|---|---|
| **Versão do documento** | 1.0 |
| **Data** | 07 de agosto de 2026 |
| **Autor** | Daniel Junior Barbosa da Silva |
| **Local do projeto** | `~/Desktop/DJIO` |
| **Estado** | Servidor funcional e testado de ponta a ponta |
| **Hardware alvo** | DJI Air 3 + controle DJI RC 2 |
| **Plataforma** | macOS 26.5.1 (Apple Silicon, arm64) |

> Este é o documento central do projeto. Ele reúne **tudo**: a decisão técnica,
> a arquitetura, o passo a passo de operação, os problemas conhecidos e o
> plano de evolução. Se você só puder ler um arquivo, leia este.

---

## Índice

1. [Resumo executivo](#1-resumo-executivo)
2. [O problema que estamos resolvendo](#2-o-problema-que-estamos-resolvendo)
3. [O hardware: DJI Air 3 + RC 2](#3-o-hardware-dji-air-3--rc-2)
4. [Arquitetura do sistema](#4-arquitetura-do-sistema)
5. [Pesquisa de tecnologias e a decisão](#5-pesquisa-de-tecnologias-e-a-decisão)
6. [Os protocolos, explicados](#6-os-protocolos-explicados)
7. [Mapa de arquivos do projeto](#7-mapa-de-arquivos-do-projeto)
8. [Instalação](#8-instalação)
9. [Operação: o dia do voo](#9-operação-o-dia-do-voo)
10. [Cenários de uso](#10-cenários-de-uso)
11. [Problemas conhecidos e soluções](#11-problemas-conhecidos-e-soluções)
12. [Segurança](#12-segurança)
13. [Distribuição para outras pessoas](#13-distribuição-para-outras-pessoas)
14. [Sistema de backup e versionamento](#14-sistema-de-backup-e-versionamento)
15. [Roadmap](#15-roadmap)
16. [Referências](#16-referências)

---

## 1. Resumo executivo

O DLCast transforma o seu Mac em um **servidor de transmissão de vídeo
profissional** para drones DJI. Em vez de depender do YouTube ou do Facebook
para receber a imagem do drone, o vídeo chega primeiro ao seu computador, onde
você tem controle total sobre ele.

**O que o sistema faz hoje, já testado e funcionando:**

- Recebe o vídeo ao vivo do drone via RTMP, direto do controle DJI RC 2
- Entrega esse vídeo simultaneamente em quatro formatos diferentes
  (WebRTC, HLS, RTSP e SRT), sem trabalho manual
- Grava tudo automaticamente em disco, como rede de segurança
- Retransmite para YouTube, Facebook, Twitch e Instagram — inclusive para
  vários ao mesmo tempo
- Permite que qualquer pessoa na mesma rede assista pelo navegador, sem
  instalar nada

**O ganho principal é a latência.** Pelo caminho tradicional (drone → YouTube →
espectador), a imagem chega com 10 a 30 segundos de atraso. Pelo DLCast usando
WebRTC, o atraso cai para **menos de 1 segundo** na rede local. Isso muda o que
é possível fazer: dá para dirigir a operação em tempo real, comentar o que está
acontecendo e reagir ao que a câmera mostra.

**Custo:** zero. Todo o software usado é livre e gratuito.

---

## 2. O problema que estamos resolvendo

Quando você transmite direto do DJI Fly para o YouTube, três coisas ruins
acontecem:

**Primeira: você perde o vídeo original.** O que fica gravado é o que o YouTube
recomprimiu, não o que o drone enviou. Se a live cair no meio, não sobra nada.

**Segunda: o atraso é grande demais para trabalhar.** Entre 10 e 30 segundos.
Se alguém no chão precisa orientar o piloto com base no que vê na tela, essa
demora inviabiliza a operação.

**Terceira: você fica preso a uma plataforma.** Um destino de cada vez, com as
regras, a qualidade e as interrupções que ela impõe.

O DLCast resolve os três colocando o seu Mac **no meio do caminho**. O drone envia
para o seu computador; o seu computador guarda uma cópia perfeita, mostra a
imagem com atraso quase nulo, e só então repassa para onde você quiser — para
uma plataforma, para várias, ou para nenhuma.

---

## 3. O hardware: DJI Air 3 + RC 2

Esta seção é a mais importante do documento em termos práticos, porque as
limitações do controle definem o que o sistema consegue entregar. **Nenhuma
configuração de servidor supera estes limites físicos.**

### 3.1 Como o vídeo sai do drone

```
   DJI Air 3                  DJI RC 2                    Seu Mac
   (câmera)                   (controle)                  (servidor)
       |                          |                            |
       |   rádio OcuSync 4        |        Wi-Fi comum         |
       |------------------------->|--------------------------->|
       |   até 20 km, 1080p60     |   rede local, RTMP         |
```

O ponto que confunde muita gente: **o drone não fala com o seu Mac
diretamente**. O drone fala com o controle por rádio. É o *controle* que se
conecta ao Wi-Fi e envia o RTMP. Portanto, quem precisa estar na sua rede é o
controle RC 2, não o drone.

### 3.2 Limitações do DJI RC 2 (críticas)

| Limitação | Detalhe | Consequência prática |
|---|---|---|
| **Resolução máxima: 720p** | O RC 2 não tem processador para codificar 1080p ao vivo | Não adianta pedir 1080p no app; o teto é 720p |
| **Microfone obrigatório** | A partir do DJI Fly v1.16.0, é preciso ter um microfone conectado ao controle | **Sem microfone, o botão de iniciar transmissão simplesmente não funciona** |
| **Taxa de bits limitada** | Definida pelo app, tipicamente 1 a 5 Mbps | Não é ajustável livremente |
| **Wi-Fi compartilhado** | O mesmo rádio do controle faz o Wi-Fi | Wi-Fi fraco derruba a transmissão |

> **O erro número 1 de quem começa** é o microfone. A pessoa configura tudo
> certo, o servidor está no ar, e o botão de iniciar não responde — porque
> falta um microfone plugado no controle. Qualquer microfone de celular
> resolve.

### 3.3 O que isso significa para o projeto

Como o RC 2 entrega no máximo 720p em H.264, e é exatamente esse o formato que
o YouTube e o Facebook aceitam, **não precisamos reconverter o vídeo em momento
algum**. O Mac apenas repassa os pacotes como chegaram. Isso tem duas
consequências ótimas: o processador quase não trabalha, e não há perda de
qualidade por recompressão.

### 3.4 Outros drones compatíveis

O sistema não depende do Air 3. Funciona com qualquer drone DJI cujo aplicativo
ofereça a opção "RTMP personalizado": Mini 3 / Mini 4 Pro, Air 3S, Mavic 3,
Avata 2, entre outros. Muda apenas a resolução máxima, conforme o controle.

---

## 4. Arquitetura do sistema

### 4.1 Visão geral

```
┌──────────────┐
│  DJI Air 3   │  câmera, sensor de 1/1.3"
└──────┬───────┘
       │ OcuSync 4 (rádio)
       ▼
┌──────────────┐
│  DJI RC 2    │  app DJI Fly → "RTMP personalizado"
└──────┬───────┘
       │ Wi-Fi → rtmp://192.168.1.250:1935/drone
       ▼
╔══════════════════════════════════════════════════════════╗
║                  SEU MAC — SERVIDOR DLCast                 ║
║                                                          ║
║   ┌────────────────────────────────────────────────┐    ║
║   │  MediaMTX (núcleo de mídia)                    │    ║
║   │  porta 1935 — recebe o RTMP do controle        │    ║
║   └───┬──────────┬──────────┬──────────┬───────────┘    ║
║       │          │          │          │                ║
║       ▼          ▼          ▼          ▼                ║
║   ┌───────┐ ┌────────┐ ┌────────┐ ┌──────────┐         ║
║   │WebRTC │ │  HLS   │ │  RTSP  │ │ Gravação │         ║
║   │ :8889 │ │ :8888  │ │ :8554  │ │ em disco │         ║
║   │ <1seg │ │ 2-5seg │ │  OBS   │ │   .mp4   │         ║
║   └───┬───┘ └───┬────┘ └───┬────┘ └────┬─────┘         ║
║       │         │          │           │                ║
║   ┌───────────────────────────────────────────────┐    ║
║   │  FFmpeg (retransmissão, sob demanda)          │    ║
║   └───────────────────┬───────────────────────────┘    ║
╚═══════════════════════│══════════════════════════════════╝
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
   ┌─────────┐    ┌──────────┐   ┌──────────┐
   │ YouTube │    │ Facebook │   │  Twitch  │
   └─────────┘    └──────────┘   └──────────┘
```

### 4.2 As duas peças de software

O sistema inteiro se apoia em dois programas, e é importante entender o papel
de cada um:

**MediaMTX — o núcleo.** É ele que fica ouvindo na porta 1935 esperando o
drone. Quando o vídeo chega, ele o mantém na memória e o oferece em todos os
formatos ao mesmo tempo. É um único arquivo executável, sem instalador, sem
banco de dados, sem dependências. Escrito em Go, licença MIT.

**FFmpeg — o canivete suíço.** Usado apenas quando é preciso *mexer* no vídeo:
retransmitir para o YouTube, gerar o vídeo de teste, converter formatos. Não
fica rodando o tempo todo; é chamado sob demanda.

### 4.3 Portas usadas

| Porta | Protocolo | Para que serve |
|---|---|---|
| **1935** | RTMP | **Entrada do drone** — a mais importante |
| 8889 | WebRTC | Saída rápida (menos de 1 segundo) |
| 8888 | HLS | Saída compatível (celular, TV) |
| 8554 | RTSP | Saída para OBS, vMix, VLC |
| 8890 | SRT | Saída resistente a rede ruim |
| 9997 | HTTP | API de controle (usada pelo painel) |
| 9998 | HTTP | Métricas |
| 9996 | HTTP | Reprodução de gravações |

---

## 5. Pesquisa de tecnologias e a decisão

Foram avaliadas as cinco principais opções livres do mercado.

| Software | Licença | Peso | Protocolos | Veredito |
|---|---|---|---|---|
| **MediaMTX** | **MIT** | ~30 MB, 1 arquivo | RTMP, WebRTC, HLS, RTSP, SRT, MoQ | **Escolhido** |
| SRS | AGPL-3.0 | Médio | RTMP, WebRTC, HLS, SRT | Licença restritiva |
| OvenMediaEngine | AGPL-3.0 | Pesado | WebRTC, LLHLS, RTMP | Licença restritiva |
| node-media-server | — | Leve | RTMP, HTTP-FLV | Sem WebRTC |
| nginx-rtmp | BSD | Médio | RTMP, HLS | Abandonado, sem WebRTC |

### 5.1 Por que MediaMTX

**Motivo 1 — É um único arquivo, sem dependências.** Isso importa muito porque
você vai distribuir isso para os amigos do grupo de drone. Não há instalador
para quebrar, nem versão de Python ou Node para conflitar. O programa roda ou
não roda.

**Motivo 2 — A licença MIT não cria obrigações para ninguém.** SRS e
OvenMediaEngine usam AGPL-3.0, uma licença que obriga quem *fornece um serviço*
com o software a disponibilizar o código-fonte a todos os usuários. Como você
quer distribuir livremente para outras pessoas, a MIT evita repassar qualquer
amarra jurídica a elas. Elas recebem, usam e modificam sem pensar no assunto.

**Motivo 3 — Faz WebRTC nativamente.** Esse é o recurso que entrega o vídeo com
menos de um segundo de atraso. É a diferença central em relação ao nginx-rtmp e
ao node-media-server, que não têm WebRTC.

**Motivo 4 — Converte entre protocolos sozinho.** O vídeo entra uma vez, por
RTMP, e sai em cinco formatos sem nenhuma configuração adicional e sem gastar
processador reconvertendo.

---

## 6. Os protocolos, explicados

Você não precisa decorar isto, mas entender a diferença ajuda a escolher a
saída certa em cada situação.

### RTMP — a entrada
Criado pela Adobe nos anos 2000 para o Flash. O Flash morreu, mas o RTMP
sobreviveu porque virou o padrão que **todas** as plataformas aceitam. É por
isso que o DJI o usa. Atraso típico: 2 a 5 segundos.

### WebRTC — a saída mais rápida
A tecnologia por trás do Google Meet e do WhatsApp. Abre mão da perfeição em
troca de velocidade: se um pedaço do vídeo se perde, ele segue em frente em vez
de esperar. Atraso: **0,3 a 0,8 segundo**. Abre direto no navegador, sem
instalar nada.

> **Use WebRTC** para pilotar olhando na tela grande, ou para o cliente
> acompanhar ao vivo de verdade.

### HLS — a saída universal
Criado pela Apple. Corta o vídeo em pedacinhos e os entrega como arquivos
comuns. Por ser tão simples, funciona em absolutamente tudo: iPhone, Android,
Smart TV, e atravessa qualquer firewall. Em compensação, é mais lento: 2 a 5
segundos, mesmo na versão de baixa latência que configuramos.

> **Use HLS** quando o espectador estiver longe, em rede desconhecida, ou for
> assistir pela TV.

### RTSP — a saída profissional
O padrão das câmeras de segurança. Serve para levar o vídeo até programas
profissionais como OBS, vMix ou VLC.

> **Use RTSP** quando quiser montar uma produção no OBS com logotipo, legendas
> e várias câmeras.

### SRT — a saída para rede ruim
Desenvolvido pela Haivision para transmitir por internet instável. Recupera
pacotes perdidos automaticamente.

> **Use SRT** quando estiver em campo, transmitindo por 4G/5G.

---

## 7. Mapa de arquivos do projeto

```
DJIO/
│
├── CLAUDE.md                  Instruções lidas pelo Claude Code a cada sessão
├── README.md                  Porta de entrada do projeto
│
├── COMECE-AQUI.html           PONTO DE ENTRADA (detecta seu sistema)
│
├── mac/                       ══ SÓ macOS ══
│   ├── DLCast.command         Clique duplo para ligar
│   ├── DESLIGAR.command       Clique duplo para desligar
│   ├── mediamtx-arm64         Servidor para Apple Silicon (incluso)
│   ├── mediamtx-intel         Servidor para Macs Intel (incluso)
│   ├── djio                   Comando principal (start, stop, status...)
│   ├── backup.sh              Sistema de backup versionado
│   └── instalar.sh            Instalador para uma máquina nova
│
├── windows/                   ══ SÓ Windows ══
│   ├── DLCast.bat             Clique duplo para ligar
│   ├── mediamtx.exe           Servidor (incluso)
│   ├── djio.ps1               Comandos no PowerShell
│   └── LEIA-ME.txt            Passo a passo
│
├── config/                    ══ COMPARTILHADO ══
│   ├── mediamtx.yml           Configuração (comentada linha a linha)
│   └── VERSAO                 Número da versão atual
│
├── src/web/                   ══ COMPARTILHADO ══
│   ├── index.html             Instruções por tipo de equipamento
│   ├── painel.html            Painel de controle visual
│   ├── sobre.html             Sobre o projeto e a DL Mídia
│   └── instalar-windows.html  Guia visual do Windows
│
├── docs/                      ══ COMPARTILHADO ══
│   ├── 00-DOCUMENTO-MESTRE.md Este arquivo — contém tudo
│   ├── 01-GUIA-RAPIDO.md      Uma página para levar a campo
│   ├── 06-TROUBLESHOOTING.md  Soluções de problemas
│   └── 07-ESTRATEGIA-MULTIPLATAFORMA.md
│
├── backups/                   HISTÓRICO DE VERSÕES
│   ├── INDICE.md              Lista de todos os backups
│   └── v<versão>_<data>_<motivo>/
│
├── recordings/                VÍDEOS GRAVADOS
└── logs/                      REGISTROS DO SERVIDOR
```

**Por que dividir por sistema.** Cada plataforma executa programas de um
jeito: o Mac usa `.command`, o Windows usa `.bat`, e os servidores são
executáveis diferentes. Já a configuração, o painel e a documentação são
idênticos nos dois — então ficam em pastas compartilhadas, sem duplicação.
Quem usa Mac abre a pasta `mac` e ignora o resto; quem usa Windows faz o
contrário.

---

## 8. Instalação

### 8.1 O que o sistema precisa

| Requisito | Mínimo | Observação |
|---|---|---|
| macOS | 12 (Monterey) | Testado no macOS 26.5.1 |
| Processador | Intel ou Apple Silicon | Apple Silicon usa aceleração de vídeo |
| Memória | 4 GB | O servidor usa cerca de 100 MB |
| Disco | 10 GB livres | ~30 MB por minuto gravado em 720p |
| Rede | Wi-Fi ou cabo | O controle precisa alcançar o Mac |

### 8.2 Instalação

**Não há instalação.** O servidor vem incluso nas pastas `mac` e `windows`.

| Sistema | O que fazer |
|---|---|
| macOS | Pasta `mac` → clique duplo em `DLCast.command` |
| Windows | Pasta `windows` → clique duplo em `DLCast.bat` |

Para conferir tudo antes, pelo terminal:

```bash
./mac/djio doctor
```

Opcional, só para retransmitir a plataformas e gerar vídeo de teste:

```bash
brew install ffmpeg
```

**Se o macOS reclamar de "desenvolvedor não identificado"** ao abrir o
`.command` pela primeira vez, clique com o botão direito e escolha **Abrir**.
Acontece uma vez só: é o macOS protegendo contra programas baixados da
internet, não um problema do projeto.

Se o diagnóstico terminar com "Sistema pronto para voar", está tudo certo.

### 8.3 Versões instaladas e testadas

| Componente | Versão | Papel |
|---|---|---|
| MediaMTX | 1.20.0 | Núcleo de mídia |
| FFmpeg | 8.1.2 | Retransmissão e testes |
| Python | 3.9.6 | Leitura de status (já vem no macOS) |
| macOS | 26.5.1 arm64 | Sistema |

---

## 9. Operação: o dia do voo

### Passo 1 — Ligar o servidor

```bash
./mac/djio start
```

O comando já mostra na tela o endereço que você vai digitar no controle.

### Passo 2 — Conferir a rede

O controle RC 2 **precisa estar no mesmo Wi-Fi que o Mac**. Este é o segundo
erro mais comum, depois do microfone.

### Passo 3 — Configurar o controle DJI

No DJI Fly, dentro do controle:

1. Toque nos **três pontinhos** (Ajustes), no canto superior direito
2. Vá em **Transmissão**
3. Toque em **Plataformas de Transmissão ao Vivo**
4. Escolha **RTMP**
5. Digite o endereço mostrado pelo comando `djio url`, por exemplo:
   ```
   rtmp://192.168.1.250:1935/drone
   ```
6. **Conecte um microfone ao controle** (obrigatório a partir da v1.16.0)
7. Toque em **Iniciar transmissão**

### Passo 4 — Confirmar que chegou

```bash
./mac/djio status
```

Se aparecer `* drone` com bytes recebidos aumentando, o vídeo está entrando.

### Passo 5 — Assistir

```bash
./mac/djio watch
```

### Passo 6 — Retransmitir (opcional)

```bash
./mac/djio restream youtube SUA-CHAVE-AQUI
```

### Passo 7 — Encerrar

```bash
./mac/djio stop
```

As gravações ficam salvas em `recordings/`. Para vê-las:

```bash
./mac/djio gravacoes
```

---

## 10. Cenários de uso

### Cenário A — Monitoramento local, sem internet
Você está numa fazenda, sem sinal de celular. Leva um roteador portátil,
conecta o Mac e o controle nele. O vídeo aparece na tela grande com menos de um
segundo de atraso e fica gravado. **Não precisa de internet nenhuma.**

### Cenário B — Live profissional no YouTube
O drone envia para o Mac; você monta a produção no OBS puxando por RTSP,
adiciona logotipo e legendas, e o OBS envia para o YouTube. Você ganha controle
de produção e mantém a gravação original intacta.

### Cenário C — Cliente acompanhando de outro lugar
Durante uma inspeção, o cliente assiste pelo celular através do link HLS,
enquanto o vídeo em qualidade máxima fica gravado no seu Mac para entrega
posterior.

### Cenário D — Vários destinos ao mesmo tempo
Abra um terminal para cada plataforma:

```bash
./mac/djio restream youtube CHAVE-1
```

```bash
./mac/djio restream facebook CHAVE-2
```

---

## 11. Problemas conhecidos e soluções

### O botão de iniciar transmissão não funciona no controle
**Causa:** falta microfone conectado. A partir do DJI Fly v1.16.0 isso é
obrigatório no RC 2.
**Solução:** conecte qualquer microfone à entrada do controle.

### "Falha ao conectar" no DJI Fly
Verifique, nesta ordem:
1. O servidor está ligado? → `./mac/djio status`
2. O controle está no mesmo Wi-Fi que o Mac?
3. O IP mudou? Roteadores trocam o IP de tempos em tempos. Rode
   `./mac/djio url` de novo e confira.
4. O firewall do macOS está bloqueando? Veja a seção 12.

### O IP do Mac muda sozinho
**Causa:** o roteador entrega IPs dinamicamente.
**Solução definitiva:** reserve um IP fixo para o Mac nas configurações do
roteador (procure por "DHCP reservation"). Assim você nunca mais precisa
reconfigurar o controle.

### O vídeo trava ou fica quadriculado
Sinal de Wi-Fi fraco entre o controle e o roteador. Aproxime-se do roteador ou
reduza a taxa de bits no DJI Fly.

### A porta 1935 já está em uso
```bash
lsof -nP -iTCP:1935 -sTCP:LISTEN
```
Isso mostra qual programa a ocupou. Normalmente é uma instância antiga do
próprio servidor: rode `./mac/djio stop`.

### O disco encheu
As gravações são apagadas automaticamente após 7 dias. Para mudar esse prazo,
edite `recordDeleteAfter` em `config/mediamtx.yml`.

---

## 12. Segurança

### O estado atual: aberto na rede local
Por padrão, qualquer aparelho na sua rede pode publicar e assistir. Isso é
proposital: facilita o uso e a rede doméstica é um ambiente controlado.

**Este servidor não deve ser exposto à internet como está.** Se você abrir a
porta 1935 no roteador, qualquer pessoa poderá transmitir pelo seu servidor.

### Como colocar senha

Edite `config/mediamtx.yml`, substituindo o bloco `authInternalUsers` por:

```yaml
authInternalUsers:
  - user: piloto
    pass: uma-senha-forte-aqui
    ips: []
    permissions:
      - action: publish
  - user: any
    pass:
    ips: [127.0.0.1, 192.168.0.0/16]
    permissions:
      - action: read
      - action: api
      - action: metrics
```

O endereço no controle passa a ser:
```
rtmp://piloto:uma-senha-forte-aqui@192.168.1.250:1935/drone
```

### Firewall do macOS
Se o firewall estiver ligado, o macOS pode pedir autorização na primeira vez.
Autorize o MediaMTX a aceitar conexões.

---

## 13. Distribuição para outras pessoas

O projeto foi desenhado desde o início para ser **replicável**: você entrega a
pasta para um amigo e funciona no Mac dele sem editar nada.

### Por que funciona em qualquer Mac
Toda a configuração usa **caminhos relativos**, e os scripts sempre entram na
pasta do projeto antes de rodar. Não há nenhum caminho fixo apontando para a
sua conta de usuário.

### Como entregar

1. Rode um backup limpo: `./mac/backup.sh "versao para distribuir"`
2. Compacte a pasta do projeto (sem `recordings/`, `logs/` e `backups/`)
3. Entregue junto esta instrução de uma linha:

> Descompacte, abra o arquivo **COMECE-AQUI.html** e siga o que aparecer.

A página detecta sozinha se a pessoa está no Mac ou no Windows e mostra
apenas o caminho dela. Não há comando para digitar nem programa para instalar.

### Situação jurídica
Todo o software envolvido é livre e permite redistribuição:

| Componente | Licença | Pode redistribuir? |
|---|---|---|
| MediaMTX | MIT | Sim, sem restrições |
| FFmpeg | LGPL/GPL | Sim (instalado separadamente pelo usuário) |
| Código do DLCast | Seu | Você decide |

Como o FFmpeg e o MediaMTX são instalados pelo próprio usuário via Homebrew,
você distribui apenas os seus scripts e a sua documentação — o que simplifica
tudo.

---

## 14. Sistema de backup e versionamento

Cada etapa do projeto é preservada. Nada é sobrescrito.

```bash
./mac/backup.sh "descrição do que mudou"
```

Isso cria `backups/v0.1.0_2026-08-07_19-30-00_descricao/` com uma cópia
completa de `config/`, `mac/`, `windows/`, `src/` e `docs/`, sem os
binarios do servidor (que nunca mudam e pesam 160 MB).

Cada backup inclui um **MANIFESTO.md** registrando data, motivo, versões de
todos os programas naquele momento e a lista de arquivos.

```bash
./mac/backup.sh --listar
```

```bash
./mac/backup.sh --restaurar v0.1.0_2026-08-07_19-30-00_descricao
```

Antes de restaurar, o sistema faz automaticamente um backup do estado atual —
então é impossível perder trabalho por engano.

---

## 15. Roadmap

### v0.1 — Fundação (concluída)
- [x] Servidor RTMP recebendo e testado ponta a ponta
- [x] Saídas WebRTC, HLS, RTSP e SRT funcionando
- [x] Gravação automática em disco
- [x] CLI `djio` com diagnóstico
- [x] Sistema de backup versionado
- [x] Documentação completa

### v0.2 — Facilidade de uso
- [ ] Painel web com estatísticas ao vivo
- [ ] QR Code na tela para configurar o controle sem digitar
- [ ] Instalador de um clique
- [ ] Alerta sonoro quando a transmissão cai

### v0.3 — Produção
- [ ] Marca d'água e logotipo sobre o vídeo
- [ ] Retransmissão simultânea gerenciada pelo painel
- [ ] Gravação em qualidade máxima paralela à transmissão
- [ ] Registro de telemetria junto ao vídeo

### v1.0 — Produto
- [ ] Aplicativo Mac com ícone, sem terminal
- [ ] Instalação em um clique
- [ ] Atualização automática

---

## 16. Referências

**Documentação oficial**
- MediaMTX: https://github.com/bluenviron/mediamtx
- FFmpeg: https://ffmpeg.org/documentation.html
- DJI Fly — guia de transmissão: https://support.dji.com/help/content?customId=en-us03400006727

**Comparativos consultados**
- Servidores de mídia auto-hospedados: https://www.pistack.xyz/posts/2026-06-04-srs-ovenmediaengine-node-media-server-self-hosted-streaming-guide/
- Guia de implantação do MediaMTX: https://stable-learn.com/en/mediamtx-streaming-server/

**Comunidade DJI**
- Air 3 transmitindo pelo RC 2: https://forum.dji.com/thread-295850-1-1.html
- RTMP personalizado no DJI Fly: https://terasor.com/blog/dji-fly-custom-rtmp-live-streaming

---

*Documento mantido junto ao código. Ao alterar o sistema, atualize este
arquivo e rode um backup.*
