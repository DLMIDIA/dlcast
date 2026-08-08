# Guia Rápido de Campo — DLCast

> Uma página. Imprima ou deixe aberta no celular durante o voo.

---

## Antes de sair de casa

```bash
cd ~/Desktop/DJIO && ./mac/djio doctor
```

Se terminar com **"Sistema pronto para voar"**, pode ir.

---

## No local — 4 passos

### 1. Ligue o servidor

```bash
./mac/djio start
```

Anote o endereço que aparecer na tela. Algo como:

```
rtmp://192.168.1.250:1935/drone
```

### 2. Abra o painel (opcional, mas recomendado)

```bash
./mac/djio painel
```

O painel mostra o vídeo ao vivo, as estatísticas e o endereço para copiar.
Funciona também no celular, pelo mesmo endereço.

### 3. Configure o controle RC 2

| Passo | Onde |
|---|---|
| 1 | Conecte o **microfone** no USB-C do controle |
| 2 | Confirme que o controle está no **mesmo Wi-Fi** que o Mac |
| 3 | DJI Fly → **três pontinhos** (canto superior direito) |
| 4 | → **Transmissão** |
| 5 | → **Plataformas de Transmissão ao Vivo** |
| 6 | → **RTMP** |
| 7 | Digite o endereço do passo 1 (veja abaixo sobre a chave) |
| 8 | Toque em **Iniciar transmissão** |

#### E a "chave de transmissão"?

**No nosso servidor você NÃO precisa de chave.** Diferente do YouTube, que
gera uma chave secreta para identificar seu canal, aqui o servidor é seu — a
palavra `drone` no fim do endereço já é o nome do stream.

Como o DJI Fly muda de tela conforme a versão, pode aparecer de dois jeitos:

**Se aparecer UM campo só** (o mais comum):

```
rtmp://192.168.1.250:1935/drone
```

**Se aparecer DOIS campos** (Endereço e Chave), separe assim:

| Campo | O que preencher |
|---|---|
| Endereço / URL do servidor | `rtmp://192.168.1.250:1935/` |
| Chave / Stream Key | `drone` |

> Repare na **barra no final** do endereço quando os campos são separados. O
> app junta os dois pedaços, e sem a barra o endereço final fica errado.

Se o campo de chave for obrigatório e você já colocou tudo no primeiro campo,
pode escrever qualquer coisa na chave — nosso servidor aceita qualquer nome
graças à regra `all_others` na configuração.

### 4. Confirme que chegou

```bash
./mac/djio status
```

Deve aparecer `* drone` com os bytes recebidos aumentando.

---

## Voando onde não tem Wi-Fi

Fazenda, obra, mata — sem rede nenhuma. O controle precisa de uma rede para
alcançar o computador.

```bash
./mac/djio rede
```

O assistente confere se já dá para usar a rede atual e, se não, abre a tela
certa e explica o que marcar. Depois de ativar, confirme com:

```bash
./mac/djio rede --verificar
```

**A solução mais confiável em campo é um roteador de viagem** — daqueles de
bolso, ligados a uma bateria USB. Não consome o computador, tem alcance melhor
e não derruba o Wi-Fi da máquina.

> **Atenção:** quando o computador vira roteador, ele **sai do Wi-Fi atual**.
> A placa não consegue criar uma rede e usar outra ao mesmo tempo. Em campo
> isso não atrapalha, mas testando em casa você perde a internet.

---

## Durante o voo

| O que fazer | Comando |
|---|---|
| Ver o vídeo | `./mac/djio watch` |
| Ver estatísticas | `./mac/djio status` |
| Mandar pro YouTube | `./mac/djio restream youtube SUA-CHAVE` |
| Acompanhar o log | `./mac/djio logs` |

**A gravação é automática.** Tudo que o drone transmitir fica salvo em
`recordings/`, mesmo que você não faça mais nada.

---

## Ao terminar

```bash
./mac/djio stop
```

```bash
./mac/djio gravacoes
```

---

## Se der problema — nesta ordem

### O botão de iniciar não funciona no controle
**É o microfone.** O DJI Fly v1.16.0+ exige um microfone conectado ao RC 2.
Sem ele, o botão simplesmente não responde. Esta é a causa em 9 de cada 10
casos.

### "Falha ao conectar"
1. O servidor está ligado? → `./mac/djio status`
2. O controle está no **mesmo Wi-Fi** que o Mac?
3. O IP mudou? → `./mac/djio url` e confira se bate com o que está no
   controle. Roteadores trocam o IP de tempos em tempos.

### O vídeo trava ou fica quadriculado
Wi-Fi fraco entre o controle e o roteador. Aproxime-se do roteador.

### Não sei o que está errado
```bash
./mac/djio doctor
```

---

## Limites do equipamento (não são defeitos)

- **720p é o máximo** — o RC 2 não tem processador para 1080p ao vivo
- **Microfone é obrigatório** — exigência do app DJI, não do nosso sistema
- **A taxa de bits é definida pelo app** — não é ajustável livremente

---

## Endereços para assistir

Trocando `192.168.1.250` pelo IP que o `djio url` mostrar:

| Como | Endereço | Atraso |
|---|---|---|
| Navegador (rápido) | `http://192.168.1.250:8889/drone` | menos de 1s |
| Celular / TV | `http://192.168.1.250:8888/drone` | 2 a 5s |
| OBS / VLC | `rtsp://192.168.1.250:8554/drone` | 1 a 2s |
| Painel completo | `http://192.168.1.250:8080/painel.html` | — |
