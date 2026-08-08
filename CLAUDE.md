# CLAUDE.md — Projeto DLCast

> **Este arquivo é lido automaticamente pelo Claude Code a cada nova sessão.**
> Ele contém o mapa completo do sistema, o estado atual e as regras de
> trabalho. Mantenha-o atualizado sempre que a estrutura mudar.

---

## 1. O que é este projeto

**DLCast** é um servidor de transmissão de vídeo ao vivo, rodando localmente
no computador. Recebe vídeo via RTMP de drones DJI, câmeras profissionais,
celulares e OBS; grava em disco e redistribui em vários protocolos —
inclusive retransmitindo para YouTube, Facebook e Twitch.

### A marca

| | |
|---|---|
| **Nome** | DLCast — "DL" de DL Mídia, "Cast" de broadcast |
| **Autor** | Daniel Júnior, fundador |
| **Empresa** | DL Mídia — marketing, soluções web, mapeamento, filmagem e captação |
| **Contato** | contato@dlmidia.com.br |
| **Modelo** | Gratuito e livre para redistribuir |

> **Atenção ao escrever textos:** o nome do produto é **DLCast**. A pasta do
> projeto e o comando do terminal continuam sendo `DJIO` e `djio` por
> compatibilidade — não renomeie sem migrar tudo junto.
>
> O nome evita de propósito mencionar "drone": o sistema também atende
> câmeras Sony, OBS e celulares, e um nome preso a drones limitaria o alcance.

| | |
|---|---|
| **Raiz do projeto** | `~/Desktop/DJIO` |
| **Versão atual** | `0.3.0` (ver `config/VERSAO`) |
| **Hardware alvo** | DJI Air 3 + RC 2 — **e qualquer fonte RTMP** (Sony, OBS, celular) |
| **Plataforma** | macOS 26.5.1, Apple Silicon (arm64). Windows via `djio.ps1` |
| **Estado** | **Validado em voo real com o drone** |
| **Objetivo** | Uso próprio + distribuição gratuita + publicação no GitHub |

---

## 2. Mapa de arquivos

**A estrutura é dividida por sistema operacional.** O que é específico de cada
plataforma fica na sua pasta; o que é idêntico nos dois fica compartilhado.
Isso evita arquivo duplicado e deixa óbvio onde mexer.

```
DJIO/
│
├── COMECE-AQUI.html            ★ Ponto de entrada (detecta o sistema sozinho)
├── CLAUDE.md                   ← ESTE ARQUIVO (lido a cada sessão)
├── README.md
│
├── mac/                        ══ SÓ macOS ══
│   ├── DLCast.command          Clique duplo para ligar (Finder)
│   ├── DESLIGAR.command        Clique duplo para desligar
│   ├── mediamtx-arm64          Servidor, Apple Silicon (51 MB, incluso)
│   ├── mediamtx-intel          Servidor, Macs Intel (54 MB, incluso)
│   ├── djio                    ★ CLI principal — toda operação passa por aqui
│   ├── backup.sh               Backup versionado
│   └── instalar.sh             Instalador (hoje quase desnecessário)
│
├── windows/                    ══ SÓ Windows ══
│   ├── DLCast.bat              Clique duplo para ligar
│   ├── mediamtx.exe            Servidor (53 MB, incluso)
│   ├── djio.ps1                CLI em PowerShell (NÃO testado ainda)
│   ├── LEIA-ME.txt             Passo a passo (CRLF, p/ Bloco de Notas)
│   └── LICENSE-mediamtx.txt
│
├── config/                     ══ COMPARTILHADO ══
│   ├── mediamtx.yml            Configuração, comentada linha a linha
│   └── VERSAO
│
├── src/web/                    ══ COMPARTILHADO ══
│   ├── index.html              Boas-vindas por tipo de equipamento
│   ├── painel.html             Painel com vídeo, métricas e gravação
│   ├── sobre.html              Institucional (marca, autor, empresa)
│   ├── instalar-windows.html   Guia visual do Windows
│   └── ambiente.json           GERADO por "djio painel" — não versionar
│
├── docs/                       ══ COMPARTILHADO ══
│   ├── 00-DOCUMENTO-MESTRE.md  ★ Documentação completa
│   ├── 01-GUIA-RAPIDO.md       Uma página para levar a campo
│   ├── 06-TROUBLESHOOTING.md   Soluções de problemas
│   └── 07-ESTRATEGIA-MULTIPLATAFORMA.md
│
├── backups/                    Histórico interno (fora do Git)
├── recordings/                 Vídeos gravados (gerado)
└── logs/                       Logs do servidor (gerado)
```

**O que NÃO vai para o GitHub** (já está no `.gitignore`): `backups/`,
`recordings/`, `logs/`, `ambiente.json` e os três binários do MediaMTX. Os
binários somam ~160 MB e devem ser publicados via **GitHub Releases**, nunca
no repositório — deixariam o clone lento para todo mundo.

---

## 3. Arquitetura em uma imagem

```
DJI Air 3 ──rádio──► DJI RC 2 ──Wi-Fi/RTMP──► MAC (porta 1935)
                                                    │
                                          ┌─────────┴─────────┐
                                          │     MediaMTX      │
                                          └─────────┬─────────┘
                        ┌──────────┬────────────────┼──────────┬──────────┐
                        ▼          ▼                ▼          ▼          ▼
                     WebRTC       HLS             RTSP       SRT      Gravação
                      :8889      :8888           :8554      :8890      .mp4
                      <1seg      2-5seg           OBS      rede ruim  automática
                                                              │
                                                        FFmpeg (restream)
                                                              ▼
                                                   YouTube / Facebook / Twitch
```

**Ponto que sempre confunde:** o drone NÃO fala com o Mac. O drone fala com o
controle por rádio; é o **controle** que envia o RTMP pelo Wi-Fi. Portanto quem
precisa estar na mesma rede do Mac é o RC 2.

---

## 4. Portas em uso

| Porta | Serviço | Observação |
|---|---|---|
| **1935** | RTMP (entrada do drone) | **A mais importante** |
| 8889 | WebRTC | Saída mais rápida (<1s) |
| 8888 | HLS | Saída compatível (celular, TV) |
| 8554 | RTSP | Para OBS, vMix, VLC |
| 8890 | SRT | Rede instável |
| 8080 | Painel web | Servido por `python3 -m http.server` |
| 9997 | API de controle | Usada pelo painel e por `djio status` |
| 9998 | Métricas | Formato Prometheus |
| 9996 | Playback | Rever gravações |

---

## 5. Comandos do projeto

Todos partem da raiz do projeto:

```bash
./mac/djio start        # liga o servidor
./mac/djio stop         # desliga tudo (servidor + painel)
./mac/djio status       # quem está transmitindo agora
./mac/djio url          # endereço para digitar no controle DJI
./mac/djio painel       # abre o painel visual (o "app")
./mac/djio watch        # abre só o vídeo no navegador
./mac/djio test 30      # testa o sistema sem o drone, por 30s
./mac/djio doctor       # diagnóstico completo
./mac/djio logs         # acompanha o log em tempo real
./mac/djio gravacoes    # lista os vídeos salvos
./mac/djio restream youtube <chave>
./mac/backup.sh "motivo"
```

---

## 6. Dependências

| Programa | Versão | Obrigatório? | Como obter | Papel |
|---|---|---|---|---|
| MediaMTX | 1.20.0 | **Sim** | **já incluso nas pastas** | Núcleo de mídia |
| FFmpeg | 8.1.2 | Não | `brew` / `winget` | Retransmissão e teste |
| Python | 3.9.6 | Não | vem no macOS | Painel e status |

**O MediaMTX vem incluso nos dois sistemas.** Essa foi uma decisão
deliberada: antes o Mac exigia `brew install`, o que obrigava o usuário a
abrir o terminal e instalar um gerenciador de pacotes só para começar. Hoje
os dois sistemas são clique duplo puro, sem instalar nada.

O `mac/djio` escolhe o binário pela arquitetura (`uname -m`): `arm64` usa
`mediamtx-arm64`, `x86_64` usa `mediamtx-intel`. Se nenhum dos dois existir,
ele cai para uma instalação do sistema — então quem prefere manter via
Homebrew continua funcionando.

**Não há dependências de Node, banco de dados ou Docker.** Isso é intencional:
o projeto precisa ser simples de instalar na máquina de outras pessoas.

---

## 7. Decisões técnicas já tomadas (não refazer sem motivo)

**MediaMTX em vez de SRS ou OvenMediaEngine.**
Motivo: licença MIT (não impõe obrigações a quem receber o projeto), binário
único sem dependências, e WebRTC nativo. SRS e OvenMediaEngine são AGPL-3.0,
que obrigaria a abrir o código de quem oferecer o serviço.

**Repasse sem reconversão (`ffmpeg -c copy`) na retransmissão.**
Motivo: o RC 2 já entrega H.264/AAC, exatamente o formato que as plataformas
aceitam. Reconverter gastaria processador e pioraria a qualidade sem ganho.

**Caminhos relativos em toda a configuração.**
Motivo: o projeto precisa funcionar ao ser copiado para o Mac de outra pessoa,
sem editar nada. Por isso os scripts sempre entram na raiz do projeto antes de
executar qualquer coisa.

**Painel servido por HTTP, não aberto como arquivo.**
Motivo: aberto via `file://`, o navegador bloqueia a consulta à API e o painel
fica sem dados. Servido por HTTP, também fica acessível pelo celular.

**FFmpeg e Python são OPCIONAIS, não obrigatórios.**
Motivo: o MediaMTX sozinho recebe o RTMP, grava em disco e serve WebRTC, HLS
e RTSP. O FFmpeg só entra para retransmitir a plataformas e gerar vídeo de
teste; o Python só serve o painel. Isso importa muito no Windows, onde nenhum
dos dois vem instalado — a instalação mínima é **um arquivo só**. Não escreva
documentação que os apresente como pré-requisito.

**`DLCast.bat` é .bat puro, não PowerShell.**
Motivo: a política de execução do Windows bloqueia scripts `.ps1` por padrão,
e um usuário comum não tem como adivinhar isso. Comandos PowerShell de linha
única chamados de dentro do .bat não são bloqueados — é assim que ele
descobre o IP.

**No `.gitignore`, comentário só em linha própria.**
Motivo: o Git NÃO aceita comentário no fim da linha. Escrever
`logs/   # registros` faz o padrão virar o texto inteiro, que não casa com
nada — e os arquivos sobem assim mesmo. Isso já aconteceu aqui: os logs e o
`ambiente.json` (que tem os caminhos pessoais do usuário) entraram no primeiro
`git add` por causa disso. Confira sempre com `git status` antes de publicar.

**Arquivo já rastreado ignora o `.gitignore`.**
Motivo: as regras só valem para arquivos ainda não rastreados. Se algo entrou
no índice por engano, corrigir o `.gitignore` não basta — é preciso
`git reset` e adicionar de novo.

**Permissões `api` e `metrics` no usuário anônimo.**
Motivo: sem elas o MediaMTX responde "authentication error" e tanto o painel
quanto o `djio status` param de funcionar. Já quebrou uma vez durante o
desenvolvimento.

---

## 8. Limitações do hardware (não são bugs)

| Limitação | Detalhe |
|---|---|
| **720p máximo** | O RC 2 não tem processador para codificar 1080p ao vivo |
| **Microfone obrigatório** | DJI Fly v1.16.0+ exige microfone conectado ao RC 2, senão o botão de iniciar não funciona |
| **Taxa de bits fixa** | Definida pelo app DJI, tipicamente 1–5 Mbps |

> O erro nº 1 de quem começa é o microfone. Sempre pergunte sobre isso antes de
> investigar o servidor.

---

## 9. Regras de trabalho neste projeto

1. **Antes de mudanças estruturais, rode um backup:**
   `./mac/backup.sh "o que vai mudar"`
2. **Documentação em português do Brasil**, escrita para alguém que não é
   programador. O projeto será distribuído para pilotos de drone, não para
   desenvolvedores.
3. **Comentários no código explicam o PORQUÊ**, não o quê. As configurações
   têm valores fora do padrão por motivos específicos — registre-os.
4. **Não introduza dependências novas** (Node, Docker, bancos) sem necessidade
   real. Cada dependência é um obstáculo a mais para quem for instalar.
5. **Sempre teste com `./mac/djio test`** antes de considerar algo pronto.
   Não é preciso o drone para validar o servidor.
6. **Ao mudar a estrutura de pastas, atualize este arquivo.**

---

## 10. Estado atual e próximos passos

### Concluído (v0.1.0 e v0.2.0)
- [x] Servidor RTMP recebendo, testado ponta a ponta
- [x] Saídas WebRTC, HLS, RTSP e SRT validadas
- [x] Gravação automática em disco confirmada
- [x] CLI `djio` completo com diagnóstico e monitor ao vivo
- [x] Sistema de backup versionado
- [x] Documentação completa
- [x] **Validado em voo real com o DJI Air 3 + RC 2**
- [x] Painel com player WebRTC próprio (WHEP), métricas ao vivo, botão de
      gravação, cronômetro e modal técnico
- [x] Página de boas-vindas com instruções por tipo de equipamento
- [x] Script PowerShell para Windows (escrito, **não testado**)

### Próximo (v0.3)
- [ ] **Testar `djio.ps1` numa máquina Windows real** — nunca foi executado
- [ ] QR Code no painel para configurar o controle sem digitar
- [ ] Publicar no GitHub com licença MIT
- [ ] Aplicativo em Go, binário único para Mac e Windows
      (ver `docs/07-ESTRATEGIA-MULTIPLATAFORMA.md`)

### Avisos para quem for continuar
1. O `djio.ps1` foi escrito às cegas, sem máquina Windows disponível. Trate
   como rascunho até alguém executá-lo de fato.
2. A latência mostrada no painel é da **rede até o navegador**, não é
   glass-to-glass. O modal explica isso ao usuário; não mude o rótulo para
   sugerir que mede o caminho inteiro.
3. O MediaMTX **recarrega a configuração sozinho** ao salvar o arquivo. Não é
   preciso reiniciar o servidor (nem derrubar uma transmissão em andamento)
   para aplicar mudanças em `config/mediamtx.yml`.
