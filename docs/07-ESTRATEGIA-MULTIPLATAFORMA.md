# Estratégia Multiplataforma — Como transformar o DLCast em aplicativo

**Pergunta que este documento responde:** qual a melhor forma de entregar o
DLCast para outras pessoas, funcionando tanto no Mac quanto no Windows, sem que
elas precisem usar o terminal?

---

## Resumo da recomendação

Duas fases, porque uma destrava o Windows **hoje** e a outra faz o produto de
verdade.

| Fase | O quê | Prazo | Esforço |
|---|---|---|---|
| **1. Scripts nativos** | Um `.ps1` para Windows equivalente ao nosso `djio` | Imediato | Baixo |
| **2. Binário único em Go** | Um arquivo executável, clique duplo, sem terminal | Depois | Médio |

**A recomendação final é Go.** O raciocínio completo está abaixo.

---

## Por que este projeto já é quase multiplataforma

Boa notícia antes de tudo: as três peças centrais já rodam nos três sistemas.

| Peça | Mac | Windows | Linux |
|---|---|---|---|
| MediaMTX | sim | sim | sim |
| FFmpeg | sim | sim | sim |
| Painel (HTML) | sim | sim | sim |

**A única coisa que não é portátil são os nossos scripts em Bash.** O Windows
não fala Bash nativamente. É só isso que falta.

Isso muda a natureza do problema: não precisamos reescrever o sistema, apenas
trocar a "casca" que dá partida nele.

---

## As opções avaliadas

### Opção A — Electron

Empacota o painel HTML com um Chrome inteiro dentro.

| A favor | Contra |
|---|---|
| Já sabemos HTML/JS | **150 a 200 MB** por aplicativo |
| Muitos exemplos prontos | Consome muita memória |
| Build para Mac e Windows | Leva um navegador inteiro junto |

**Veredito: descartado.** Pesado demais para o que fazemos. O nosso servidor
inteiro ocupa 30 MB; seria absurdo empacotá-lo dentro de 200 MB de navegador.

### Opção B — Tauri

Usa o navegador que já existe no sistema, em vez de embutir um.

| A favor | Contra |
|---|---|
| Aplicativo de ~10 MB | Precisa de Rust |
| Visual nativo bonito | **Compilar para Windows exige uma máquina Windows** |
| Instalador .dmg e .msi | Cadeia de build mais complexa |

**Veredito: bom, mas com um obstáculo sério.** O Tauri não faz compilação
cruzada com facilidade: para gerar o instalador do Windows, você precisaria de
um PC com Windows ou de uma automação na nuvem. Isso trava o seu fluxo de
trabalho, já que você desenvolve no Mac.

### Opção C — Python empacotado (PyInstaller)

**Veredito: descartado.** Executáveis gerados por PyInstaller são
frequentemente marcados como vírus por antivírus do Windows — um problema real
quando você vai distribuir para amigos, que veriam um alerta assustador.

### Opção D — Binário único em Go ← **recomendado**

Um programa pequeno em Go que dá partida no MediaMTX, serve o painel e abre o
navegador.

| A favor | Contra |
|---|---|
| **Compilação cruzada num comando** — do seu Mac sai o `.exe` do Windows | Precisa aprender um pouco de Go |
| Binário único, sem instalador, sem runtime | |
| ~15 MB | |
| `go:embed` coloca o painel HTML dentro do executável | |
| Mesma linguagem do MediaMTX | |
| Pode virar ícone na bandeja do sistema | |

**Veredito: é o caminho.**

---

## Por que Go vence para o seu caso

O critério decisivo não é técnico, é **de distribuição**. Você vai entregar
isso para pilotos de drone, não para programadores. O padrão-ouro é:

> "Baixe este arquivo e clique duas vezes."

Go é a única opção da lista que entrega exatamente isso **e** permite que você
gere a versão do Windows sem sair do Mac:

```bash
GOOS=windows GOARCH=amd64 go build -o DLCast.exe
```

```bash
GOOS=darwin GOARCH=arm64 go build -o DLCast
```

Dois comandos, dois arquivos, zero dependências para o usuário final. Nenhuma
outra opção da lista faz isso.

Há ainda um bônus: o MediaMTX **é escrito em Go**. Isso significa que, no
futuro, dá para embutir o servidor de mídia dentro do nosso próprio programa
em vez de chamá-lo como processo separado — um único arquivo contendo tudo.

---

## Como fica a arquitetura na fase 2

```
DLCast.exe  /  DLCast.app          ← um arquivo só
│
├── painel HTML embutido       (go:embed)
├── inicia o MediaMTX          (processo filho ou biblioteca)
├── serve o painel na :8080
├── abre o navegador sozinho
└── ícone na bandeja do sistema
     ├── Ligar / Desligar
     ├── Abrir painel
     ├── Copiar endereço
     └── Sair
```

O usuário baixa, clica duas vezes, o navegador abre no painel. Ele nunca vê um
terminal.

---

## O que muda por sistema operacional

Estes são os pontos onde o código precisa se comportar diferente. São poucos e
todos simples:

| Assunto | macOS | Windows |
|---|---|---|
| Descobrir o IP local | `ipconfig getifaddr` | `Get-NetIPAddress` |
| Abrir o navegador | `open` | `start` |
| Encerrar um processo | `pkill` | `Stop-Process` |
| Onde ficam os arquivos | pasta do app | pasta do app |
| **Firewall** | costuma deixar passar | **pede autorização na 1ª vez** |

**O firewall do Windows é o ponto de atenção.** Na primeira execução, o
Windows mostra um alerta perguntando se o programa pode aceitar conexões. O
usuário precisa marcar "Redes particulares" e permitir. Se ele negar, nada
funciona e a causa não é óbvia. Isso tem que estar na tela de boas-vindas do
instalador do Windows.

---

## Plano de execução sugerido

### Agora — destravar o Windows
1. Escrever `windows/djio.ps1`, equivalente ao nosso `djio` em PowerShell
2. Criar `DLCast.bat` para o usuário dar clique duplo
3. Documentar a autorização do firewall
4. Testar em um PC com Windows

### Depois — publicar no GitHub
1. Criar o repositório com README, licença MIT e capturas de tela
2. Adicionar as instruções de instalação para os dois sistemas
3. Usar GitHub Releases para distribuir os arquivos prontos

### Por fim — o aplicativo
1. Escrever o programa em Go que empacota tudo
2. Compilação cruzada para Mac e Windows
3. Automatizar o build pelo GitHub Actions
4. Publicar os executáveis a cada versão

---

## Sobre publicar no GitHub

O projeto está pronto para isso. Alguns cuidados:

**Licença.** Use MIT, a mesma do MediaMTX. É a mais permissiva e não cria
obrigações para quem baixar.

**O que não subir.** O `.gitignore` já exclui `recordings/`, `logs/` e
`backups/`. Confira também se nenhuma chave de transmissão de YouTube ou
Facebook ficou escrita em algum arquivo antes do primeiro envio.

**O que faz um projeto ser adotado.** Capturas de tela do painel logo no topo
do README, e a promessa clara em uma frase. Algo como: *"Transmita do seu
drone DJI para o seu próprio computador, com menos de 1 segundo de atraso."*

**Assinatura de código.** Sem assinar digitalmente, tanto o macOS quanto o
Windows mostrarão um alerta de "desenvolvedor não identificado". Dá para
contornar com instruções (clique com o botão direito → Abrir), mas assinar
custa em torno de 100 dólares por ano e elimina o atrito. Vale considerar
quando o projeto tiver tração.

---

## Sobre expandir para outras câmeras

Isso **já funciona** — não precisa de código novo.

O servidor aceita RTMP de qualquer origem. A configuração já traz caminhos
prontos para `camera`, `obs`, `celular` e `camera2`, além da regra curinga que
aceita qualquer nome não previsto. A página de boas-vindas
(`src/web/index.html`) já traz instruções para cada tipo de equipamento.

| Equipamento | Como envia |
|---|---|
| Drone DJI | RTMP nativo no app DJI Fly |
| Sony ILME-FX30, PXW-Z200, HXR-NX800 | RTMP nativo no menu de rede |
| Canon, Nikon, Panasonic | via OBS + placa de captura HDMI |
| Celular | app Larix Broadcaster |
| GoPro, encoders | RTMP nativo |

Vários equipamentos podem transmitir ao mesmo tempo, cada um em seu endereço.
