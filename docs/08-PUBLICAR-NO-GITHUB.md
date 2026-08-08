# Como publicar o DLCast no GitHub

> Passo a passo completo, escrito para quem tem conta no GitHub mas nunca
> publicou um projeto pela linha de comando.

---

## Antes de começar: o que já está pronto

Você não precisa preparar nada. Já deixei tudo no lugar:

| Item | Estado |
|---|---|
| `LICENSE` (MIT) | pronto, com seu nome |
| `.gitignore` | pronto, já exclui o que não pode subir |
| `README.md` | pronto, é a primeira coisa que aparece no repositório |
| Documentação em `docs/` | pronta |
| Repositório Git local | **já inicializado, com o primeiro commit feito** |

Falta só uma coisa: **criar o repositório no site do GitHub e enviar**.

---

## O que sobe e o que NÃO sobe

Esta é a parte que mais gera confusão, então vale entender antes.

### Sobe (o projeto em si)

```
COMECE-AQUI.html    README.md      LICENSE
CLAUDE.md           .gitignore
mac/          (sem os binários)
windows/      (sem o mediamtx.exe)
config/  src/  docs/
```

### NÃO sobe

| O quê | Por quê |
|---|---|
| `recordings/` | São **seus** vídeos. Podem ter conteúdo de clientes. |
| `logs/` | Registros da sua máquina, sem valor para outros. |
| `backups/` | O Git **já é** o histórico de versões. Duplicaria tudo. |
| `mac/mediamtx-*` e `windows/mediamtx.exe` | **160 MB de binários.** Ver abaixo. |
| `src/web/ambiente.json` | Tem os caminhos de pasta do **seu** computador. |

### Por que os binários não sobem

Os três executáveis do MediaMTX somam cerca de 160 MB. Se entrarem no
repositório:

- Todo mundo que clonar baixa 160 MB, mesmo querendo só ler o código
- O histórico do Git guarda **cada versão** desses arquivos para sempre
- O GitHub recusa arquivos acima de 100 MB de qualquer forma

**A solução correta é a seção Releases**, que existe exatamente para isso:
distribuir arquivos prontos, sem poluir o repositório. Explico na etapa 5.

---

## Etapa 1 — Criar o repositório no GitHub

1. Entre em **github.com** e clique no **+** no canto superior direito
2. Escolha **New repository**
3. Preencha:

| Campo | O que colocar |
|---|---|
| **Repository name** | `dlcast` |
| **Description** | `Servidor de transmissão ao vivo para drones DJI e câmeras. Menos de 1 segundo de atraso, gravação local e retransmissão para YouTube, Facebook e Twitch.` |
| **Public / Private** | **Public** (para as pessoas poderem usar) |
| **Add a README** | ❌ **NÃO marque** — já temos um |
| **Add .gitignore** | ❌ **NÃO marque** — já temos um |
| **Choose a license** | ❌ **NÃO marque** — já temos uma |

> Marcar qualquer uma dessas três opções cria arquivos no GitHub que vão
> **conflitar** com os nossos na hora de enviar. Deixe tudo desmarcado.

4. Clique em **Create repository**

O GitHub vai mostrar uma página com comandos. **Ignore essa página** — os
comandos certos estão abaixo.

---

## Etapa 2 — Dizer ao Git quem é você

Só precisa fazer uma vez neste computador.

```bash
git config --global user.name "Daniel Júnior"
```

```bash
git config --global user.email "contato@dlmidia.com.br"
```

> O e-mail aparece publicamente em cada alteração enviada. Se preferir não
> expor o seu, o GitHub oferece um e-mail anônimo em
> **Settings → Emails → Keep my email addresses private**, no formato
> `12345+usuario@users.noreply.github.com`. Use esse no lugar.

---

## Etapa 3 — Conectar a pasta ao GitHub

Troque `SEU-USUARIO` pelo seu nome de usuário do GitHub:

```bash
cd ~/Desktop/DJIO && git remote add origin https://github.com/SEU-USUARIO/dlcast.git
```

---

## Etapa 4 — Enviar

```bash
cd ~/Desktop/DJIO && git branch -M main && git push -u origin main
```

O GitHub vai pedir login. **Atenção: a senha da sua conta não funciona mais
aqui** — o GitHub desativou isso em 2021. Você precisa de um *token*:

1. No GitHub, vá em **Settings** (do seu perfil, não do repositório)
2. Desça até **Developer settings**, lá no fim do menu da esquerda
3. **Personal access tokens** → **Tokens (classic)**
4. **Generate new token (classic)**
5. Dê um nome como `Mac do Daniel`
6. Marque a caixa **repo**
7. Clique em **Generate token** e **copie o código que aparecer**

Esse código é a "senha" que você cola no terminal. Ele aparece **uma única
vez** — se perder, gere outro.

> Guarde o token no seu gerenciador de senhas. Ele dá acesso de escrita aos
> seus repositórios; trate como senha de verdade.

---

## Etapa 5 — Publicar os executáveis (Releases)

Aqui é onde entram os 160 MB de binários que ficaram de fora do repositório.

1. Na página do seu repositório, clique em **Releases** (coluna da direita)
2. **Create a new release**
3. Preencha:

| Campo | O que colocar |
|---|---|
| **Tag** | `v0.4.0` → clique em *Create new tag on publish* |
| **Title** | `DLCast v0.4.0` |
| **Description** | O que mudou nesta versão |

4. Na área **Attach binaries**, arraste os arquivos prontos para uso

O ideal é anexar **dois arquivos .zip completos**, um por sistema, para a
pessoa baixar um só e já ter tudo. Para gerá-los:

```bash
cd ~/Desktop/DJIO && ./mac/empacotar.sh
```

Isso cria os pacotes dentro de `dist/`, já sem logs, gravações e backups.

5. **Publish release**

Pronto: quem entrar no seu repositório vê "Releases" e baixa o arquivo do
sistema dele, com tudo dentro.

---

## Etapa 6 — Deixar a página bonita

Depois do primeiro envio, vale investir 10 minutos nisto — é o que faz alguém
usar o projeto em vez de fechar a aba.

**Capturas de tela.** Tire uma foto do painel com vídeo ao vivo rodando e
coloque no topo do README. É o que mais converte: a pessoa vê funcionando
antes de ler qualquer coisa.

Salve em `docs/imagens/` e adicione ao README assim:

```markdown
![Painel do DLCast](docs/imagens/painel.png)
```

**Tópicos.** Na página do repositório, clique na engrenagem ao lado de
*About* e adicione: `drone`, `dji`, `rtmp`, `streaming`, `webrtc`,
`mediamtx`, `live-streaming`, `obs`. É assim que as pessoas encontram o
projeto na busca.

**Descrição e site.** No mesmo lugar, confirme a descrição e coloque
`dlmidia.com.br` no campo *Website*.

---

## Depois: enviando alterações

Sempre que mudar alguma coisa no projeto:

```bash
cd ~/Desktop/DJIO && git add -A && git commit -m "descreva o que mudou"
```

```bash
cd ~/Desktop/DJIO && git push
```

### E os backups locais?

Continuam funcionando normalmente, e **não conflitam** com o Git:

- `./mac/backup.sh` é a sua rede de segurança **local**, para desfazer algo na
  sua máquina em segundos
- O Git é o histórico **público**, que outras pessoas enxergam

A pasta `backups/` está no `.gitignore`, então nunca vai para o GitHub.

---

## Perguntas que costumam aparecer

**Preciso pagar?** Não. Repositórios públicos e Releases são gratuitos, sem
limite prático para um projeto deste tamanho.

**Alguém pode roubar o projeto?** A licença MIT permite que copiem, modifiquem
e até vendam — desde que mantenham o aviso de copyright com o seu nome. Foi
uma escolha consciente: é o que torna o projeto de fato livre. Se quiser
impedir uso comercial fechado, a licença teria que ser outra (AGPL), mas aí
você imporia a mesma obrigação a todos os seus amigos.

**E se eu subir algo errado sem querer?** Apagar do GitHub não apaga do
histórico. Por isso confira o `.gitignore` antes do primeiro envio — o comando
`git status` mostra exatamente o que vai subir. **Nunca deixe uma chave de
transmissão do YouTube ou Facebook escrita em arquivo nenhum.**

**Posso deixar privado?** Pode, e dá para trocar depois em
**Settings → Danger Zone → Change visibility**. Mas se a ideia é distribuir
para o grupo de drone, público é mais simples: eles baixam sem precisar de
convite.
