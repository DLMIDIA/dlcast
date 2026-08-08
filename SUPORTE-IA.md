# DLCast — Arquivo de Contexto para Inteligência Artificial

> **COMO USAR ESTE ARQUIVO**
>
> 1. Abra este arquivo e **copie todo o conteúdo** (Ctrl+A / Cmd+A, depois Ctrl+C / Cmd+C)
> 2. Cole em qualquer IA: **ChatGPT, Gemini, Claude, Copilot, Grok, DeepSeek…**
> 3. Depois de colar, **escreva o seu problema** logo abaixo
>
> A IA vai entender o sistema inteiro e conseguir te ajudar, mesmo sem
> conhecer o DLCast antes.
>
> **Exemplo do que escrever depois de colar:**
> *"Meu drone não conecta. O servidor está ligado, mas quando aperto iniciar
> transmissão no DJI Fly dá erro de conexão. Estou no Windows."*

---

## INSTRUÇÕES PARA A IA

Você está ajudando o usuário de um sistema chamado **DLCast**. Todo o
conhecimento necessário está neste documento. Siga estas orientações:

1. **Comece pelas causas mais comuns.** Na seção "Problemas conhecidos", os
   itens estão em ordem de frequência real. O primeiro item resolve a maioria
   dos casos.
2. **O usuário provavelmente não é programador.** Ele é piloto de drone,
   fotógrafo ou produtor de vídeo. Explique sem jargão e dê passos concretos.
3. **Peça o diagnóstico automático.** O sistema tem um comando que identifica
   problemas sozinho — está na seção "Como coletar informações".
4. **Não invente recursos.** Se algo não está neste documento, diga que não
   sabe e sugira contato com o desenvolvedor (dados no fim).
5. **Verifique as limitações de hardware primeiro.** Muitas "falhas" são
   limites físicos do equipamento, não defeitos.

---

## 1. O QUE É O SISTEMA

O DLCast é um **servidor de transmissão de vídeo ao vivo que roda no
computador do próprio usuário** (macOS ou Windows). Não é um serviço em
nuvem, não tem cadastro e não envia dados para lugar nenhum.

**O que ele faz:**
- Recebe vídeo ao vivo via **RTMP** de drones DJI, câmeras profissionais,
  celulares e OBS
- Entrega esse vídeo simultaneamente em WebRTC, HLS, RTSP e SRT
- Grava em disco (fMP4/.mp4)
- Retransmite para YouTube, Facebook, Twitch e Instagram

**O ganho principal:** o atraso cai de 10–30 segundos (transmissão direta
para plataforma) para **menos de 1 segundo** via WebRTC na rede local.

**Versão atual:** 0.5.0
**Licença:** MIT (livre e gratuito)

---

## 2. TECNOLOGIAS USADAS

| Componente | Versão | Papel | Obrigatório? |
|---|---|---|---|
| **MediaMTX** | 1.20.0 | Núcleo de mídia. Recebe RTMP e redistribui. Escrito em Go, binário único. | **SIM** — já vem incluso no projeto |
| **FFmpeg** | 8.x | Retransmissão a plataformas e geração de vídeo de teste | Não |
| **Python** | 3.x | Serve o painel web na porta 8080 | Não (já vem no macOS) |

**Importante:** o sistema **recebe e grava vídeo sem FFmpeg e sem Python**.
Eles só adicionam recursos extras. Não trate como pré-requisitos.

Não há Node.js, Docker, banco de dados ou qualquer outra dependência.

---

## 3. ARQUITETURA E FLUXO DO VÍDEO

```
DJI Air 3 ──rádio OcuSync──► DJI RC 2 ──Wi-Fi/RTMP──► COMPUTADOR (porta 1935)
 (drone/câmera)               (controle)                      │
                                                    ┌─────────┴─────────┐
                                                    │     MediaMTX      │
                                                    └─────────┬─────────┘
                        ┌──────────┬────────────────┼──────────┬──────────┐
                        ▼          ▼                ▼          ▼          ▼
                     WebRTC       HLS             RTSP       SRT      Gravação
                      :8889      :8888           :8554      :8890      .mp4
                      <1seg      2-5seg           OBS      rede ruim
                                                              │
                                                        FFmpeg (opcional)
                                                              ▼
                                                YouTube / Facebook / Twitch
```

**PONTO CRÍTICO PARA DIAGNÓSTICO:** o drone **não** se conecta ao computador.
O drone fala com o **controle** por rádio; é o **controle** que se conecta ao
Wi-Fi e envia o RTMP. Portanto, quem precisa estar na mesma rede do
computador é o **controle**, não o drone.

---

## 4. ESTRUTURA DE PASTAS

A estrutura é dividida por sistema operacional. O que é específico de cada
plataforma fica na sua pasta; o resto é compartilhado.

```
DLCast/
├── COMECE-AQUI.html       Ponto de entrada, detecta o sistema
├── SUPORTE-IA.md          Este arquivo
├── README.md
│
├── mac/                   ══ SÓ macOS ══
│   ├── DLCast.command     Clique duplo para ligar
│   ├── DESLIGAR.command   Clique duplo para desligar
│   ├── mediamtx-arm64     Servidor (Apple Silicon)
│   ├── mediamtx-intel     Servidor (Macs Intel)
│   ├── djio               CLI principal
│   ├── backup.sh          Backup versionado
│   └── empacotar.sh       Gera pacotes de distribuição
│
├── windows/               ══ SÓ Windows ══
│   ├── DLCast.bat         Clique duplo para ligar
│   ├── mediamtx.exe       Servidor
│   ├── djio.ps1           CLI em PowerShell
│   └── LEIA-ME.txt
│
├── config/
│   └── mediamtx.yml       Configuração do servidor
│
├── src/web/               Painel e páginas (HTML puro, sem dependências)
├── docs/                  Documentação completa
├── recordings/            Vídeos gravados
└── logs/
    └── mediamtx.log       ★ LOG DO SERVIDOR — essencial para diagnóstico
```

---

## 5. PORTAS DE REDE

| Porta | Protocolo | Função |
|---|---|---|
| **1935** | RTMP | **Entrada do vídeo** — a mais importante |
| 8889 | WebRTC | Saída de baixa latência (<1s) |
| 8888 | HLS | Saída compatível (2–5s) |
| 8554 | RTSP | Saída para OBS/vMix/VLC |
| 8890 | SRT | Saída resistente a rede instável |
| 8080 | HTTP | Painel de controle |
| 9997 | HTTP | API de controle (usada pelo painel) |
| 9998 | HTTP | Métricas |
| 8189 | UDP | Tráfego de vídeo do WebRTC |

**Endereço que o usuário digita no equipamento:**
`rtmp://<IP-DO-COMPUTADOR>:1935/drone`

Se o app pedir endereço e chave separados:
- Endereço: `rtmp://<IP>:1935/` (com barra no final)
- Chave: `drone`

**Não existe chave secreta neste sistema.** O servidor aceita qualquer nome de
stream, graças a uma regra curinga na configuração.

---

## 6. COMANDOS DISPONÍVEIS

### macOS (terminal, a partir da pasta do projeto)

```bash
./mac/djio start        # liga o servidor
./mac/djio stop         # desliga tudo
./mac/djio status       # quem está transmitindo agora
./mac/djio url          # mostra o endereço para o equipamento
./mac/djio painel       # abre o painel no navegador
./mac/djio doctor       # ★ DIAGNÓSTICO AUTOMÁTICO
./mac/djio rede         # ★ assistente de rede (sem Wi-Fi no local)
./mac/djio monitor      # ★ vigia conexões ao vivo
./mac/djio test 30      # testa sem o drone, por 30 segundos
./mac/djio logs         # acompanha o log em tempo real
./mac/djio gravacoes    # lista os vídeos salvos
./mac/djio restream youtube <chave>
```

### Windows (PowerShell, a partir da pasta do projeto)

```powershell
.\windows\djio.ps1 start
.\windows\djio.ps1 stop
.\windows\djio.ps1 status
.\windows\djio.ps1 url
.\windows\djio.ps1 painel
.\windows\djio.ps1 doctor
.\windows\djio.ps1 rede
```

Se o PowerShell recusar a execução do script:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## 7. LIMITAÇÕES DE HARDWARE (não são defeitos)

| Limitação | Origem | Tem solução? |
|---|---|---|
| **Resolução máxima 720p** | O controle DJI RC 2 não tem processador para codificar 1080p ao vivo | Não. Só trocando para um controle melhor (RC Pro) |
| **Microfone obrigatório** | Exigência do app DJI Fly v1.16.0+ | Não. É preciso conectar um microfone |
| **Taxa de bits 1–5 Mbps** | Definida pelo app DJI | Não é ajustável livremente |

**Nenhuma configuração do servidor supera esses limites.** Se o usuário
reclamar de qualidade 720p, explique que é o controle, não o DLCast.

---

## 8. PROBLEMAS CONHECIDOS (em ordem de frequência real)

### 8.1 — O botão de iniciar transmissão não funciona no controle DJI

**Frequência: causa nº 1 de todas.**

**Sintoma:** O usuário aperta "Iniciar transmissão" no DJI Fly e nada
acontece. Nenhuma mensagem de erro aparece.

**Causa:** A partir do DJI Fly v1.16.0, o controle RC 2 **exige um microfone
conectado** na porta USB-C para permitir a transmissão.

**Solução:** Conectar qualquer microfone USB-C ao controle. Funciona com
receptores sem fio (ex.: Hollyland Lark M2S) ou microfones USB-C simples.

---

### 8.2 — "Falha ao conectar" no DJI Fly

**Verificar nesta ordem:**

1. **O servidor está ligado?** Rodar `djio status`. Deve mostrar "RODANDO".
2. **O controle está no mesmo Wi-Fi que o computador?** Lembre que quem envia
   o vídeo é o controle, não o drone.
3. **O IP mudou?** Rodar `djio url` e comparar com o que está digitado no
   controle. Roteadores trocam o IP periodicamente.
   *Solução definitiva:* reservar IP fixo no roteador (DHCP reservation).
4. **O endereço está correto?** Formato: `rtmp://192.168.1.X:1935/drone`

---

### 8.3 — Nada chega ao servidor (silêncio total no log)

**Diagnóstico decisivo:**

Rodar `djio monitor` e tentar transmitir:
- **Se aparecer "CONEXÃO RECEBIDA":** a rede está OK, o problema é o app ou o
  endereço digitado.
- **Se não aparecer nada:** o controle não alcança o computador. Continue
  abaixo.

**Teste do celular (separa as duas causas em 30 segundos):**

Conectar o celular no mesmo Wi-Fi e abrir `http://<IP>:8080/painel.html`
- **Abriu:** a rede permite comunicação; o problema é o app/endereço.
- **Não abriu:** o roteador está **isolando os aparelhos** entre si.

**Sobre isolamento de clientes (AP Isolation):**
Muitos roteadores de operadora vêm com isso ativo de fábrica. Cada aparelho
enxerga a internet, mas não enxerga os outros da casa. É uma causa silenciosa
e comum.

Soluções, em ordem:
1. Verificar se o controle não está numa **rede de visitantes** (sempre isola)
2. Verificar se ambos estão na **mesma faixa** (2,4 GHz e 5 GHz às vezes são
   redes separadas que não se falam)
3. Desativar "AP Isolation" / "Isolamento de clientes" no roteador
4. Usar um roteador próprio ou roteador de viagem (sempre funciona)

---

### 8.4 — Windows: o drone não conecta mesmo com tudo certo

**Causa provável: firewall do Windows.**

Na primeira execução, o Windows pergunta se o programa pode aceitar conexões.
Se o usuário clicou em "Cancelar", nada funciona e **não há nenhuma pista** do
motivo.

**Solução:** Configurações do Windows → Firewall → "Permitir um aplicativo
pelo Firewall" → localizar `mediamtx.exe` → marcar **Particular** → OK.

---

### 8.5 — A janela preta abre e fecha na hora (Windows)

**Causa:** A pasta está incompleta — normalmente o `mediamtx.exe` foi apagado
(antivírus às vezes remove) ou a pasta `windows` foi separada do resto.

**Solução:** Copiar a pasta DLCast inteira novamente. O `DLCast.bat` precisa
conseguir subir um nível e encontrar `config\mediamtx.yml`.

---

### 8.6 — "A porta 1935 já está em uso"

**Causa:** Outra instância do servidor já está rodando.

**Solução:**
- macOS/Linux: `lsof -nP -iTCP:1935 -sTCP:LISTEN` para ver quem usa, depois
  `./mac/djio stop`
- Windows: `Get-NetTCPConnection -LocalPort 1935 -State Listen`

---

### 8.7 — O vídeo trava, pixela ou fica quadriculado

**Causa:** Sinal de Wi-Fi fraco entre o controle e o roteador.

**Soluções:** aproximar-se do roteador; reduzir a taxa de bits no DJI Fly;
preferir a faixa de 5 GHz se disponível.

---

### 8.8 — O vídeo está com muito atraso

**Causa:** O usuário está assistindo pelo HLS (porta 8888), que tem 2–5s.

**Solução:** usar o WebRTC (porta 8889), que tem menos de 1 segundo.
Comando: `djio watch`.

---

### 8.9 — A API responde "authentication error"

**Causa:** Falta a permissão `api` no bloco `authInternalUsers` em
`config/mediamtx.yml`.

**Solução:** o usuário anônimo precisa das ações `api` e `metrics`, além de
`publish` e `read`. Sem elas, o painel e o comando `status` param de
funcionar.

---

### 8.10 — O disco encheu

Gravação em 720p ocupa cerca de **30 MB por minuto** (1,8 GB por hora).

Por padrão o sistema **não grava automaticamente** — a gravação é iniciada
pelo botão do painel, que pergunta onde salvar.

Se a gravação automática estiver ativada, o parâmetro `recordDeleteAfter` em
`config/mediamtx.yml` controla por quantos dias os arquivos são mantidos.

---

### 8.11 — Não existe Wi-Fi no local do voo

**Cenário:** fazenda, obra, mata — sem rede nenhuma. O controle do drone
precisa de uma rede para alcançar o computador.

**O sistema tem um assistente para isso:**

```bash
./mac/djio rede              # macOS
.\windows\djio.ps1 rede      # Windows
```

Ele detecta se já há rede utilizável, e se não houver, abre a tela de
configuração e explica o que marcar. Depois:

```bash
./mac/djio rede --verificar
```

**Como funciona:** o computador cria uma rede Wi-Fi de verdade, com nome e
senha, igual à de um roteador. No controle do drone, essa rede aparece na
lista de Wi-Fi normalmente; o piloto seleciona, digita a senha e pronto — o
controle passa a enxergar o computador.

O assistente sugere nome (`DLCast`) e uma senha pronta, para o usuário não
precisar inventar em campo. A senha precisa ter no mínimo 8 caracteres, por
exigência do padrão WPA2.

**As três soluções, da melhor para a mais simples:**

1. **Roteador de viagem** — o mais confiável. Um roteador portátil ligado a
   uma bateria USB. Não consome o computador e tem alcance melhor.

2. **O computador vira roteador** — macOS: Ajustes → Geral → Compartilhamento
   → Compartilhamento de Internet (compartilhar de uma interface sem uso,
   para Wi-Fi). Windows: Configurações → Rede → Ponto de acesso móvel.

3. **Cabo de rede** — só para equipamento com porta Ethernet. **O DJI RC 2
   não tem** — ele só fala Wi-Fi. Serve para câmeras profissionais (Sony
   FX30, PXW-Z200) e para outro computador rodando OBS.

**Duas limitações importantes que causam confusão:**

*Os sistemas exigem uma "origem" de internet.* Tanto o macOS quanto o Windows
foram feitos para **compartilhar** internet, não para criar rede isolada. No
Windows, o método do PowerShell chama `GetInternetConnectionProfile()` e falha
sem internet. A saída é escolher uma interface qualquer como origem — mesmo
sem cabo, mesmo sem internet. A rede sobe do mesmo jeito e funciona para
tráfego local, que é tudo o que o DLCast precisa.

*Uma placa Wi-Fi não faz dois papéis.* Ao criar a rede, o computador **sai do
Wi-Fi atual**. Em campo isso não atrapalha; testando em casa, ele perde a
internet enquanto o hotspot estiver ligado.

**Faixas de endereço que indicam que funcionou:**

| Faixa | Significa |
|---|---|
| `192.168.2.x` | Compartilhamento do macOS ativo |
| `192.168.137.x` | Ponto de acesso do Windows ativo |
| `169.254.x.x` | **Falhou** — placa ativa mas sem roteador nem compartilhamento |

---

### 8.12 — macOS: "desenvolvedor não identificado"

**Solução:** clicar com o botão direito no arquivo `.command` e escolher
**Abrir**. Acontece apenas na primeira vez. É proteção do macOS contra
programas baixados da internet.

---

## 9. COMO COLETAR INFORMAÇÕES PARA DIAGNÓSTICO

Peça ao usuário para rodar estes comandos e colar o resultado:

### Diagnóstico automático (sempre peça este primeiro)

macOS:
```bash
cd ~/Desktop/DJIO && ./mac/djio doctor
```

Windows:
```powershell
.\windows\djio.ps1 doctor
.\windows\djio.ps1 rede
```

Ele verifica: servidor presente, dependências opcionais, arquivos do projeto,
IP da rede, portas em uso e espaço em disco.

### Últimas linhas do log

macOS:
```bash
tail -40 ~/Desktop/DJIO/logs/mediamtx.log
```

Windows:
```powershell
Get-Content logs\mediamtx.log -Tail 40
```

### O que procurar no log

| No log aparece | Significa |
|---|---|
| `[RTMP] [conn ...] opened` | O equipamento **conseguiu** conectar |
| `is publishing to path 'drone'` | O vídeo **está entrando** — sucesso |
| `stream is available and online` | Tudo funcionando |
| **Nenhuma linha nova ao tentar transmitir** | O equipamento **não alcança** o computador → problema de rede |
| `authentication error` | Falta permissão na configuração (ver 8.9) |

### Estado das transmissões

```bash
curl -s http://127.0.0.1:9997/v3/paths/list
```

Retorna JSON com os streams ativos, bytes recebidos, codecs e espectadores.

---

## 10. EQUIPAMENTOS COMPATÍVEIS

| Equipamento | Como envia | Caminho sugerido |
|---|---|---|
| Drones DJI (Air 3, Air 3S, Mini 3/4, Mavic 3, Avata 2) | RTMP nativo no DJI Fly | `/drone` |
| Sony ILME-FX30, PXW-Z200, HXR-NX800 | RTMP nativo no menu de rede | `/camera` |
| Canon, Nikon, Panasonic | via OBS + captura HDMI | `/obs` |
| Celular (iPhone/Android) | app Larix Broadcaster | `/celular` |
| GoPro, encoders de hardware | RTMP nativo | qualquer nome |

Vários equipamentos podem transmitir simultaneamente, cada um em seu caminho.

**Codificação recomendada:** vídeo H.264, áudio AAC. É o que todo equipamento
produz e o que as plataformas aceitam — assim o vídeo passa sem reconversão.

---

## 11. CONFIGURAÇÃO DO SERVIDOR

O arquivo `config/mediamtx.yml` controla tudo. Pontos relevantes:

```yaml
# Autenticação: liberada na rede local. As ações "api" e "metrics" são
# OBRIGATÓRIAS, senão o painel e o comando status param de funcionar.
authInternalUsers:
  - user: any
    pass:
    ips: []
    permissions:
      - action: publish
      - action: read
      - action: playback
      - action: api
      - action: metrics

# Gravação: DESLIGADA por padrão. O botão do painel liga, perguntando a pasta.
pathDefaults:
  record: no
  recordPath: ./recordings/%path/%Y-%m-%d_%H-%M-%S-%f
  recordFormat: fmp4
  overridePublisher: yes   # reconexão assume o lugar da conexão antiga
```

**O MediaMTX recarrega a configuração sozinho** ao salvar o arquivo. Não é
preciso reiniciar o servidor — nem mesmo durante uma transmissão ativa.

---

## 12. SEGURANÇA

Por padrão o servidor aceita conexões **apenas da rede local**, sem senha.
Isso é intencional: facilita o uso e a rede doméstica é controlada.

**Este servidor não deve ser exposto à internet como está.** Abrir a porta
1935 no roteador permitiria que qualquer pessoa transmitisse por ele.

Para adicionar senha, substituir o bloco `authInternalUsers` por um com
usuário e senha, e o endereço passa a ser:
`rtmp://usuario:senha@IP:1935/drone`

---

## 13. QUANDO ESCALAR PARA O DESENVOLVEDOR

Se após seguir este documento o problema persistir, oriente o usuário a
entrar em contato com o desenvolvedor, **enviando junto**:

1. A saída completa do comando `doctor`
2. As últimas 40 linhas do `logs/mediamtx.log`
3. Sistema operacional e versão
4. Modelo do drone/câmera e do controle
5. O que já foi tentado

**Contato:**
- WhatsApp: (62) 92001-6146 — https://wa.me/5562920016146
- Site: https://dlmidia.com.br
- E-mail: contato@dlmidia.com.br

---

## FICHA TÉCNICA RESUMIDA

```
Nome:          DLCast v0.5.0
Autor:         Daniel Júnior — DL Mídia
Licença:       MIT (livre, gratuito, uso comercial permitido)
Sistemas:      macOS 12+ (Apple Silicon e Intel), Windows 10/11
Núcleo:        MediaMTX 1.20.0 (Go, licença MIT)
Entrada:       RTMP na porta 1935
Saídas:        WebRTC (8889), HLS (8888), RTSP (8554), SRT (8890)
Gravação:      fMP4 (.mp4), manual, com escolha de pasta
Painel:        HTTP na porta 8080, HTML puro sem dependências
API:           HTTP na porta 9997
Dependências:  nenhuma obrigatória além do servidor incluso
Internet:      não é necessária (só para retransmitir a plataformas)
Telemetria:    nenhuma — nada é enviado para lugar algum
```

---

*Fim do arquivo de contexto. Escreva abaixo o seu problema.*
