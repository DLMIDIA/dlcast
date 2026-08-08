# DLCast — Visão, Decisões e Possibilidades

> Este é o documento do **porquê**. Os outros explicam como usar e como
> funciona; este registra por que o projeto existe, por que cada escolha foi
> feita daquele jeito, o que descobrimos no caminho e o que dá para construir
> a partir daqui.
>
> Se alguém pegar este projeto daqui a dois anos — inclusive você — é este
> arquivo que evita refazer discussões já resolvidas.

---

## Índice

1. [Por que este projeto existe](#1-por-que-este-projeto-existe)
2. [O problema, em detalhe](#2-o-problema-em-detalhe)
3. [As decisões técnicas e o porquê de cada uma](#3-as-decisões-técnicas-e-o-porquê-de-cada-uma)
4. [O que descobrimos construindo](#4-o-que-descobrimos-construindo)
5. [Erros que cometemos e como foram corrigidos](#5-erros-que-cometemos-e-como-foram-corrigidos)
6. [Variações: o que dá para fazer com isso](#6-variações-o-que-dá-para-fazer-com-isso)
7. [O que deliberadamente NÃO fizemos](#7-o-que-deliberadamente-não-fizemos)
8. [Histórico de evolução](#8-histórico-de-evolução)

---

## 1. Por que este projeto existe

O DLCast não nasceu de uma ideia de laboratório. Nasceu de uma limitação real
encontrada trabalhando com drone em campo.

A DL Mídia faz filmagem, captação e mapeamento além do trabalho digital.
Transmitir ao vivo a imagem de um drone é uma necessidade concreta em
inspeções, eventos e acompanhamento de obra. O caminho óbvio — apontar o DJI
Fly para o YouTube — funciona, mas entrega um resultado ruim para trabalho
profissional por três motivos que só aparecem na prática.

**O primeiro é o atraso.** Entre 10 e 30 segundos. Parece pouco descrito no
papel, mas inviabiliza qualquer operação em que alguém no chão precise
orientar o piloto pelo que aparece na tela. Quando a pessoa fala "vira à
direita", o drone já passou do ponto há meio minuto.

**O segundo é a perda do material.** O que fica salvo é o vídeo que o YouTube
recomprimiu, não o que o drone enviou. Para quem entrega material ao cliente,
isso é perda de qualidade sem retorno nenhum.

**O terceiro é a dependência.** Um destino por vez, com as regras, as
interrupções e a política de conteúdo de uma plataforma que não é sua. E, sem
internet, nada funciona — o que elimina metade dos lugares onde se voa.

O DLCast resolve os três colocando o computador **no meio do caminho**. O
vídeo chega primeiro em você, íntegro e quase instantâneo; e só então segue
para onde você decidir — ou para lugar nenhum.

### Por que virou um projeto para distribuir

Depois que funcionou, ficou evidente que o problema não é só nosso. Todo
piloto de drone que já tentou transmitir enfrentou exatamente isso, e as
soluções que existem no mercado são caras, mensais, ou exigem conhecimento
técnico que um operador de câmera não tem por que ter.

Como o custo de distribuir é zero, o projeto passou a ser construído desde o
início para **rodar na máquina de outra pessoa sem ajuste nenhum**. Isso
influenciou quase todas as decisões técnicas listadas adiante.

---

## 2. O problema, em detalhe

### O caminho do vídeo, e onde cada tecnologia entra

```
DJI Air 3 ──rádio OcuSync──► DJI RC 2 ──Wi-Fi/RTMP──► Computador
   câmera                     controle                  DLCast
```

O ponto que confunde praticamente todo mundo no começo: **o drone não fala
com o computador**. O drone fala com o controle, por rádio. Quem se conecta ao
Wi-Fi e envia o vídeo é o **controle**. Por isso é o RC 2 que precisa estar na
mesma rede — e por isso a qualidade do Wi-Fi entre controle e roteador importa
mais que a velocidade da sua internet.

### Os limites que não dependem de nós

| Limite | Origem | Podemos mudar? |
|---|---|---|
| 720p máximo | Processador do RC 2 não codifica 1080p ao vivo | Não |
| Microfone obrigatório | Exigência do app DJI Fly v1.16.0+ | Não |
| Taxa de bits 1–5 Mbps | Definida pelo app DJI | Não |

Registrar isso importa porque poupa tempo: nenhuma configuração de servidor
supera esses limites, e tentar ajustá-los é perda de tempo garantida.

---

## 3. As decisões técnicas e o porquê de cada uma

### 3.1 MediaMTX como núcleo, em vez de SRS ou OvenMediaEngine

**A decisão.** Usar o MediaMTX como servidor de mídia.

**As alternativas avaliadas.** SRS, OvenMediaEngine, node-media-server e
nginx-rtmp.

**Por que MediaMTX venceu.** Três razões, em ordem de peso:

*A licença.* SRS e OvenMediaEngine usam AGPL-3.0, que obriga quem fornece um
serviço com o software a disponibilizar o código-fonte a todos os usuários.
Como a ideia é distribuir livremente para outros pilotos, a AGPL repassaria
obrigações jurídicas a cada pessoa que recebesse o projeto. A licença MIT do
MediaMTX não cria obrigação nenhuma — quem recebe usa e pronto.

*O peso da instalação.* É um executável único, sem instalador, sem
dependências, sem banco de dados. Isso é o que torna possível a promessa de
"copie a pasta e funciona". SRS e OvenMediaEngine exigem compilação ou Docker.

*WebRTC nativo.* É o recurso que entrega menos de 1 segundo de atraso.
nginx-rtmp e node-media-server simplesmente não têm.

### 3.2 Repassar o vídeo sem reconverter

**A decisão.** Na retransmissão, usar `ffmpeg -c copy` em vez de recodificar.

**Por quê.** O RC 2 já entrega H.264 com áudio AAC, que é exatamente o formato
que YouTube, Facebook e Twitch aceitam. Reconverter gastaria processador,
esquentaria a máquina e **pioraria** a qualidade, sem ganho nenhum. O
computador só repassa os pacotes como chegaram.

### 3.3 Caminhos relativos em toda a configuração

**A decisão.** Nenhum caminho absoluto na configuração; os scripts sempre
entram na raiz do projeto antes de executar qualquer coisa.

**Por quê.** É o que permite copiar a pasta para outro computador e funcionar
sem editar nada. Um único caminho fixo tipo `/Users/daniel/...` quebraria o
projeto na máquina de qualquer outra pessoa.

### 3.4 Painel servido por HTTP, não aberto como arquivo

**A decisão.** O painel roda em `http://ip:8080`, servido por um pequeno
servidor, em vez de ser aberto com clique duplo no arquivo HTML.

**Por quê.** Aberto como arquivo (`file://`), o navegador bloqueia por
segurança a consulta à API do servidor — o painel abriria bonito e vazio, sem
dado nenhum. Como efeito colateral positivo, servir por HTTP tornou o painel
acessível pelo celular e por qualquer aparelho da rede.

### 3.5 Player WebRTC próprio, em vez do player pronto

**A decisão.** Implementar um cliente WebRTC (padrão WHEP) dentro do painel,
em vez de embutir o player que o MediaMTX já oferece.

**Por quê.** Um player embutido em `iframe` é uma caixa fechada: não dá para
ler nada de dentro dele. Com o player próprio, temos acesso às estatísticas
reais da conexão — atraso, perda de pacotes, quadros por segundo, resolução —
que é o que alimenta as métricas e o modal técnico do painel.

### 3.6 Gravação desligada por padrão

**A decisão.** A gravação não começa sozinha; é o botão do painel que a inicia,
e ele pergunta antes onde salvar.

**Por quê.** Inicialmente a gravação era automática, como rede de segurança.
Na prática, isso enchia a pasta do projeto com vídeos sem o usuário perceber —
e voo em 720p ocupa perto de 2 GB por hora. Perguntar o destino transforma a
gravação em ação consciente e permite mandar o material direto para um disco
externo.

### 3.7 FFmpeg e Python como opcionais, não pré-requisitos

**A decisão.** Tratar os dois como opcionais em toda a documentação e no
diagnóstico.

**Por quê.** Esta foi uma das descobertas mais úteis do projeto. O MediaMTX
sozinho já recebe o RTMP, grava em disco e serve WebRTC, HLS e RTSP. O FFmpeg
só entra para retransmitir a plataformas e gerar vídeo de teste; o Python só
serve o painel.

Isso importa enormemente no Windows, onde nenhum dos dois vem instalado. Se
fossem tratados como obrigatórios, a instalação exigiria baixar mais de 130 MB
e instalar dois programas antes da primeira imagem aparecer. Como opcionais, a
instalação mínima do Windows é **zero**.

### 3.8 Estrutura dividida por sistema operacional

**A decisão.** Pastas `mac/` e `windows/` separadas, com `config/`, `src/` e
`docs/` compartilhados.

**Por quê.** Cada sistema executa programas de um jeito: o Mac usa
`.command`, o Windows usa `.bat`, e os executáveis do servidor são arquivos
diferentes. Já a configuração, o painel e a documentação são idênticos.
Separar só o que realmente difere evita duplicação e deixa óbvio onde mexer —
quem usa Mac abre uma pasta e ignora o resto.

### 3.9 `DLCast.bat` em .bat puro, não PowerShell

**A decisão.** O arquivo de partida do Windows é `.bat`, mesmo tendo um
`.ps1` completo disponível.

**Por quê.** A política de execução do Windows bloqueia scripts `.ps1` por
padrão, e um usuário comum não tem como adivinhar isso — veria um erro
incompreensível logo no primeiro contato. Comandos PowerShell de linha única
chamados de dentro de um `.bat` não são bloqueados, e é assim que ele descobre
o IP da máquina.

### 3.10 Servidor incluso nas duas pastas

**A decisão.** Distribuir o executável do MediaMTX dentro do projeto, em vez
de pedir que o usuário instale.

**Por quê.** No Mac, a versão anterior exigia `brew install`, o que obrigava a
pessoa a abrir o terminal e instalar um gerenciador de pacotes só para
começar. Incluir o binário eliminou o terminal da experiência: os dois
sistemas viraram clique duplo puro. O custo é 160 MB de arquivos que nunca
mudam — resolvido publicando-os via GitHub Releases, fora do repositório.

---

## 4. O que descobrimos construindo

Coisas que não estavam previstas e que mudaram decisões:

**O microfone do RC 2 trava tudo.** A partir do DJI Fly v1.16.0, sem um
microfone conectado ao controle o botão de iniciar transmissão simplesmente
não responde — sem mensagem de erro, sem pista. É a causa nº 1 de "não
funciona", e por isso aparece em destaque em toda a documentação.

**A API do MediaMTX precisa de permissão explícita.** Sem as ações `api` e
`metrics` no usuário anônimo, o servidor responde "authentication error" e
tanto o painel quanto o comando de status param de funcionar. Isso quebrou uma
vez durante o desenvolvimento e está registrado para não repetir.

**O MediaMTX recarrega a configuração sozinho.** Ao salvar o arquivo de
configuração, ele aplica as mudanças sem reiniciar — testamos isso durante uma
transmissão ativa, com espectadores conectados, e ninguém caiu. Isso muda o
jeito de trabalhar: dá para ajustar o servidor no meio de um voo.

**O silêncio no log é diagnóstico.** Quando o drone não conecta, a primeira
pergunta não é "o que está errado no servidor", e sim "chegou alguma coisa?".
Se o log não registra nenhuma tentativa de conexão, o problema é de rede — não
adianta mexer em configuração. Isso virou o comando `djio monitor`.

**Isolamento de clientes no roteador é armadilha silenciosa.** Muitos
roteadores de operadora impedem que aparelhos da mesma rede se enxerguem.
Tudo parece certo, mas nenhum pacote passa. O teste decisivo é abrir o painel
pelo celular: se não abrir, o problema é o roteador.

---

## 5. Erros que cometemos e como foram corrigidos

Registrado de propósito — errar de novo no mesmo ponto é o desperdício mais
caro que existe.

| Erro | Sintoma | Correção |
|---|---|---|
| Faltou permissão `api` na configuração | Painel e status vazios, "authentication error" | Adicionadas as ações `api` e `metrics` |
| Painel aberto como arquivo local | Painel abria sem dados | Passou a ser servido por HTTP na porta 8080 |
| Gravação automática na pasta do projeto | Vídeos acumulando sem o usuário perceber | Gravação virou ação consciente, com escolha de pasta |
| `djio.ps1` procurava o servidor na raiz | Windows não acharia o `mediamtx.exe` após a reorganização | Corrigido para `windows\mediamtx.exe` |
| Volume interno do sistema listado como destino | Time Machine aparecia como opção de gravação | Filtro de volumes protegidos e sem permissão de escrita |

---

## 6. Variações: o que dá para fazer com isso

O sistema é uma base, não um produto fechado. Algumas direções possíveis, da
mais simples à mais ambiciosa:

### 6.1 Variações que já funcionam hoje, sem código novo

**Várias câmeras ao mesmo tempo.** Cada equipamento publica em um endereço
diferente (`/drone`, `/camera`, `/obs`, `/celular`) e todos ficam disponíveis
simultaneamente. Já está configurado.

**Central de monitoramento.** Como o servidor aceita RTMP de qualquer origem,
dá para receber câmeras de segurança IP, drones e câmeras de solo no mesmo
lugar, e montar uma parede de vídeos no painel.

**Produção com OBS.** Puxar o vídeo do servidor para dentro do OBS por RTSP,
adicionar logo, legendas e outras fontes, e mandar o programa montado de volta
ao servidor ou direto à plataforma.

**Gravação em disco externo.** O botão de gravar já permite escolher qualquer
pasta, inclusive de um HD externo — o caminho natural para voos longos.

### 6.2 Variações que exigem trabalho

**Aplicativo de verdade, em Go.** Um executável único que embute o servidor e
o painel, com ícone na bandeja do sistema. Elimina pastas e cliques duplos em
arquivos. É a evolução natural e está detalhada em
`07-ESTRATEGIA-MULTIPLATAFORMA.md`.

**QR Code no painel.** Em vez de digitar o endereço na tela pequena do
controle, apontar a câmera e ler. Reduz o erro de digitação, que é uma das
causas comuns de falha em campo.

**Marca d'água e sobreposição.** Logo do cliente, telemetria do voo, horário e
coordenadas gravados sobre a imagem. O FFmpeg já faz isso; falta a interface.

**Gravação em duas qualidades.** Gravar em qualidade máxima enquanto
transmite em qualidade reduzida — entrega material melhor ao cliente sem
comprometer a estabilidade da live.

**Alerta de queda.** Aviso sonoro ou notificação quando a transmissão cai. Em
voo, o piloto olha para o céu, não para a tela.

**Acesso remoto seguro.** Hoje o sistema é deliberadamente local. Para o
cliente assistir de outra cidade, seria preciso um túnel (Tailscale, Cloudflare
Tunnel) — com atenção redobrada à segurança, já que o servidor não foi
projetado para ficar exposto.

**Servidor em nuvem para eventos grandes.** A mesma configuração roda num
servidor alugado quando o público for maior que a capacidade da rede local.
Aí o custo deixa de ser zero, mas a arquitetura não muda.

---

## 7. O que deliberadamente NÃO fizemos

Tão importante quanto o que foi feito.

**Não usamos Node, Docker ou banco de dados.** Cada dependência é um obstáculo
a mais para quem for instalar. O projeto tem exatamente duas peças de
software, e uma delas é opcional.

**Não expusemos o servidor à internet.** Por padrão ele só aceita conexões da
rede local, sem senha. É uma escolha consciente: a rede doméstica é um
ambiente controlado, e exigir senha atrapalharia o uso em campo. Abrir para a
internet exige configuração explícita e cuidados que estão documentados.

**Não criamos sistema de contas ou licenciamento.** O projeto é gratuito e
livre. Qualquer camada de controle de acesso seria trabalho para restringir
algo que queremos que se espalhe.

**Não medimos latência ponta a ponta.** O painel mostra o atraso da rede até a
tela, e diz isso explicitamente. Medir da lente até o olho exigiria uma
referência externa (o método clássico é filmar um cronômetro). Preferimos um
número honesto e explicado a um número impressionante e errado.

---

## 8. Histórico de evolução

| Versão | O que mudou |
|---|---|
| **0.1.0** | Servidor RTMP funcionando, saídas WebRTC/HLS/RTSP/SRT, gravação automática, CLI `djio`, backup versionado, documentação |
| **0.2.0** | Painel com player WebRTC próprio, métricas ao vivo, botão de gravação, cronômetro, modal técnico, comando `monitor` |
| **0.3.0** | Marca DLCast, página institucional, escolha de pasta de gravação, página de boas-vindas por equipamento, suporte documentado a Sony/OBS/celular, pacote Windows |
| **0.4.0** | Estrutura separada por sistema operacional, servidor incluso nas duas plataformas (fim da dependência de Homebrew), `COMECE-AQUI.html`, empacotador de distribuição, preparação para GitHub |

### Marcos de validação

- **Pipeline validado com vídeo sintético** — ingest RTMP, saídas simultâneas
  e gravação em disco confirmados antes de qualquer voo
- **Validado em voo real** com DJI Air 3 + RC 2, transmitindo 720p H.264 com
  áudio AAC
- **Painel validado com transmissão ativa**, com espectadores conectados
  simultaneamente

### Pendência conhecida

O `windows/djio.ps1` foi escrito sem acesso a uma máquina Windows e **nunca
foi executado**. O `DLCast.bat` foi revisado linha a linha, mas também não foi
testado em Windows real. Trate os dois como rascunho sólido até que alguém
rode de fato — é o próximo passo de validação do projeto.
