# Transmissão Mundial em Nuvem via ngrok — DLCast Pro

> Transmita seu drone de **qualquer lugar do mundo** via chip 4G/5G ou Wi-Fi externo, direto para o seu computador, sem mexer no roteador e sem pagar servidores caros.

---

## O Problema Que o ngrok Resolve

Quando você está voando em campo (fazenda, praia, evento esportivo, inspeção em rodovia):
1. Seu controle DJI RC 2 está conectado à internet via **4G/5G do celular** ou chip interno.
2. Seu computador está no escritório, na sua casa ou em uma van de produção.
3. Redes domésticas e corporativas ficam atrás de **roteadores, firewalls e CGNAT**. O drone simplesmente não consegue achar o IP local (`192.168.x.x`) do seu computador através da internet pública.
4. Fazer "abertura de portas" (Port Forwarding 1935) é complexo, inseguro e a maioria das operadoras de internet móvel e fibra bloqueia.

### A Solução DLCast Pro + ngrok

O ngrok cria um **túnel reverso criptografado ultrarrápido** entre o seu computador e a nuvem global. 
- O seu computador se conecta à rede do ngrok.
- O ngrok fornece um **endereço RTMP mundial seguro** (ex: `rtmp://0.tcp.sa.ngrok.io:18492/drone`).
- O drone envia os pacotes de vídeo pelo 4G/5G para esse endereço, e o ngrok entrega direto no DLCast com **menos de 300ms de latência**.

---

## Passo a Passo (Menos de 2 Minutos)

### 1. Crie sua conta gratuita no ngrok com o Google
Acesse: [https://dashboard.ngrok.com/signup](https://dashboard.ngrok.com/signup)
Clique em **"Continue with Google"** (1 clique com sua conta Google, sem preencher formulários).

### 2. Instale o ngrok
* **No macOS** (Terminal):
  ```bash
  brew install ngrok
  ```
* **No Windows** (PowerShell Administrador):
  ```powershell
  winget install ngrok.ngrok
  ```

### 3. Salve seu Authtoken
Acesse seu painel ngrok em [Your Authtoken](https://dashboard.ngrok.com/get-started/your-authtoken), copie a chave gerada e rode no Terminal:
```bash
./mac/djio ngrok token SEU_AUTHTOKEN_AQUI
```
*(No Windows: `.\windows\djio.ps1 ngrok token SEU_AUTHTOKEN_AQUI`)*

---

## Como Usar no Dia do Voo

### 1. Inicie o túnel de nuvem
```bash
./mac/djio ngrok start
```
*(Ou dê clique duplo no menu `mac/DLCast.command` e escolha a opção `[2]`)*

### 2. Pegue o endereço RTMP público
O DLCast exibirá na tela:
```
=============================================================
  TÚNEL NGROK ATIVO E CONECTADO:

  Endereço RTMP para o Drone (4G/5G / Mundo Inteiro):
    rtmp://0.tcp.sa.ngrok.io:18492/drone

  Painel Studio Remoto (HTTPS / Clientes):
    https://dlcast-live.ngrok-free.app/painel.html
=============================================================
```

### 3. Digite no controle DJI Fly
No DJI RC 2 / RC Pro / Celular:
1. Toque nos **três pontinhos** (`...`) no canto superior direito.
2. Vá em **Transmissão** → **Plataformas de Transmissão ao Vivo** → **RTMP**.
3. Digite o endereço global fornecido pelo ngrok (ex: `rtmp://0.tcp.sa.ngrok.io:18492/drone`).
4. Toque em **Iniciar Transmissão**.

### 4. Compartilhe com Clientes ou Diretores
Você pode enviar o link do **Painel Studio Remoto** (`https://xxxx.ngrok-free.app/painel.html`) para qualquer pessoa no mundo assistir ao vivo pelo navegador do celular, iPad ou computador com certificado SSL ativado!

---

## Comandos Úteis do ngrok

| Comando | O que faz |
|---|---|
| `./mac/djio ngrok start` | Inicia o servidor e abre os túneis RTMP e Web |
| `./mac/djio ngrok stop` | Desliga os túneis de nuvem |
| `./mac/djio ngrok status` | Exibe os endereços públicos e portas ativas |
| `./mac/djio ngrok token <t>` | Atualiza ou salva sua chave de autenticação |
