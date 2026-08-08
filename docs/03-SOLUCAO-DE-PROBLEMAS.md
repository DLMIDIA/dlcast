# Solução de Problemas — DLCast

> Comece sempre por aqui: `./mac/djio doctor`

---

## O MÉTODO: descubra ONDE está o problema antes de mexer em qualquer coisa

Quando "não funciona", existem apenas dois lugares possíveis para o defeito.
Descobrir qual deles leva 30 segundos e evita horas de tentativa e erro.

### Passo 1 — Ligue o monitor

```bash
./mac/djio monitor
```

Deixe essa janela aberta e tente iniciar a transmissão no controle.

| O que aparece | O que significa |
|---|---|
| **"CONEXÃO RECEBIDA"** | O controle **alcança** o Mac. A rede está certa; o problema é o formato do endereço ou o app. Vá para a seção "Problemas no controle DJI". |
| **Nada, silêncio total** | O controle **não alcança** o Mac. O problema é de rede. Continue no passo 2. |

### Passo 2 — O teste do celular (decisivo)

Pegue o celular, conecte no **mesmo Wi-Fi** e abra no navegador:

```
http://192.168.1.250:8080/painel.html
```

(troque pelo IP que o `./mac/djio url` mostrar)

| Resultado | Diagnóstico | Solução |
|---|---|---|
| **O painel abre** | A rede permite que os aparelhos conversem. O problema está no DJI Fly — geralmente o microfone ou o endereço digitado. | Revise o endereço e o microfone |
| **Não abre / fica carregando** | O roteador está **isolando os aparelhos** entre si, ou o controle está em outra rede. | Veja abaixo |

### Isolamento de aparelhos no roteador

Muitos roteadores de operadora vêm com "isolamento de clientes" (também
chamado de *AP Isolation*, *Client Isolation* ou "Rede de Visitantes") ligado
de fábrica. Com ele ativo, cada aparelho enxerga apenas a internet — nunca os
outros aparelhos da casa. **É a causa silenciosa mais comum.**

**Como resolver, em ordem de facilidade:**

1. **Confira se o controle não está na rede de visitantes.** Redes com nome
   terminando em "_guest", "_visitante" ou similar sempre isolam.

2. **Verifique se ambos estão na mesma faixa.** Alguns roteadores criam redes
   separadas para 2,4 GHz e 5 GHz e não deixam uma falar com a outra. Coloque
   o Mac e o controle **na mesma rede**, com o mesmo nome.

3. **Desligue o isolamento** nas configurações do roteador (normalmente em
   Wi-Fi → Avançado). Procure por "AP Isolation" ou "Isolamento de clientes".

4. **Solução que sempre funciona: use um roteador próprio.** Leve um roteador
   de viagem ou crie uma rede só para o drone. Isso também é o recomendado em
   campo, onde não existe Wi-Fi disponível.

---

## Problemas no controle DJI

### O botão "Iniciar transmissão" não responde

**Esta é a causa mais comum de todas.** A partir do DJI Fly v1.16.0, o
controle RC 2 exige um **microfone conectado** para permitir a transmissão.
Sem ele, o botão fica inerte, sem mensagem de erro.

**Solução:** conecte um microfone à porta USB-C do controle. Funciona com
receptores USB-C sem fio (como o Hollyland Lark M2S) ou qualquer microfone
USB-C simples.

### "Falha ao conectar ao servidor"

Verifique nesta ordem:

**1. O servidor está ligado?**
```bash
./mac/djio status
```

**2. O controle está na mesma rede que o Mac?**
O controle RC 2 precisa estar no **mesmo Wi-Fi**. Lembre-se: o drone não fala
com o Mac — quem envia o vídeo é o controle.

**3. O IP do Mac mudou?**
```bash
./mac/djio url
```
Roteadores trocam o IP de tempos em tempos. Compare com o que está digitado no
controle.

**Solução definitiva:** reserve um IP fixo para o Mac no seu roteador (procure
por "DHCP reservation" ou "IP reservado" nas configurações). Assim o endereço
nunca mais muda.

### O app pede uma "chave de transmissão"

Aqui não existe chave secreta como no YouTube — o servidor é seu.

**Se o app mostra um campo só:**
```
rtmp://192.168.1.250:1935/drone
```

**Se mostra dois campos:**

| Campo | Valor |
|---|---|
| Endereço / URL | `rtmp://192.168.1.250:1935/` |
| Chave | `drone` |

A **barra no final** do endereço é essencial quando os campos são separados.

---

## Problemas de vídeo

### A imagem trava, pixela ou fica quadriculada

Sinal de Wi-Fi fraco entre o controle e o roteador.

- Aproxime-se do roteador
- Reduza a taxa de bits nas configurações do DJI Fly
- Prefira a faixa de 5 GHz se o roteador oferecer

### O vídeo está com muito atraso

Você provavelmente está assistindo pelo HLS. Use o WebRTC:

```bash
./mac/djio watch
```

| Saída | Atraso |
|---|---|
| WebRTC (porta 8889) | menos de 1 segundo |
| HLS (porta 8888) | 2 a 5 segundos |

### O vídeo não aparece no painel

O painel só mostra o vídeo quando há transmissão ativa. Confirme com:

```bash
./mac/djio status
```

Se aparecer "Nenhuma transmissão no ar", o problema está no controle, não no
servidor.

---

## Problemas no servidor

### "A porta 1935 já está em uso"

Descubra quem a ocupou:

```bash
lsof -nP -iTCP:1935 -sTCP:LISTEN
```

Normalmente é uma instância antiga do próprio servidor:

```bash
./mac/djio stop
```

### O servidor não sobe

Veja as últimas linhas do log:

```bash
tail -30 logs/mediamtx.log
```

### A API responde "authentication error"

Falta a permissão `api` no bloco `authInternalUsers` em
`config/mediamtx.yml`. O usuário anônimo precisa das ações `api` e `metrics`
além de `publish` e `read`.

### O firewall do macOS está bloqueando

Verifique:

```bash
/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

Se estiver ativo, autorize o MediaMTX a aceitar conexões quando o macOS
perguntar. Você também pode liberar manualmente em
**Ajustes do Sistema → Rede → Firewall → Opções**.

---

## Problemas de disco

### O disco encheu

As gravações são apagadas automaticamente após 7 dias. Para mudar o prazo,
edite `recordDeleteAfter` em `config/mediamtx.yml`:

```yaml
recordDeleteAfter: 168h   # 7 dias. Use 0s para nunca apagar.
```

Para ver o que está ocupando espaço:

```bash
./mac/djio gravacoes
```

### Quanto espaço uma gravação ocupa

Aproximadamente **30 MB por minuto** em 720p, ou cerca de **1,8 GB por hora**.

---

## Como voltar atrás

Se alguma alteração quebrou o sistema, restaure uma versão anterior:

```bash
./mac/backup.sh --listar
```

```bash
./mac/backup.sh --restaurar <nome-da-pasta>
```

Antes de restaurar, o sistema salva automaticamente o estado atual — então
nada se perde.

---

## Ainda não resolveu

Junte estas informações antes de pedir ajuda:

```bash
./mac/djio doctor
```

```bash
tail -50 logs/mediamtx.log
```
