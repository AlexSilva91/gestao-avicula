# Proposta comercial, precificacao e plano de marketing - SELETO

Este documento organiza uma proposta comercial para vender o SELETO para pequenos produtores, com opcoes de venda direta, assinatura, suporte, instalacao, cameras, sensores e comodato.

Valores sugeridos em reais. Revise antes de enviar proposta formal, pois hardware, deslocamento, impostos e disponibilidade regional mudam.

Data-base: 2026-09-28.

## 1. Posicionamento do produto

O SELETO deve ser vendido como uma solucao de gestao e automacao acessivel para pequenos e medios produtores, nao como apenas um aplicativo.

Mensagem central:

> Controle producao, estoque, alimentacao, ambiente, agua, cameras, iluminacao e ventilacao da granja em uma unica plataforma, com instalacao assistida e suporte tecnico.

## 2. Publico-alvo

### 2.1. Cliente ideal inicial

- Pequeno produtor de ovos caipiras.
- Pequeno avicultor familiar.
- Produtor com 1 a 4 galpoes.
- Produtor que ainda controla producao em caderno, planilha ou WhatsApp.
- Produtor com perda por falha de agua, calor, falta de registro ou dificuldade de acompanhar rotina.
- Produtor que precisa de controle mas nao consegue pagar sistema industrial caro.

### 2.2. Cliente secundario

- Cooperativas.
- Tecnicos agropecuarios.
- Lojas agropecuarias que queiram revender.
- Integradores de camera/alarme em cidades pequenas.
- Associações de produtores.

## 3. O que vender

Venda em blocos modulares:

1. App/sistema.
2. Implantacao inicial.
3. Assinatura mensal.
4. Kit sensores.
5. Kit cameras.
6. Kit automacao: luz/ventilacao.
7. Suporte remoto.
8. Suporte presencial.
9. Comodato opcional de cameras/sensores.

Nao venda tudo como obrigatorio. Pequeno produtor aceita melhor quando pode comecar pequeno e evoluir.

## 4. Custos de referencia consultados

Estes valores servem para balizar proposta. Use margem de seguranca.

| Item | Referencia consultada | Valor observado |
| --- | --- | ---: |
| ESP32 Bluetooth/Wi-Fi | MakerHero, placa ESP32 Bluetooth | R$42,90 |
| Modulo rele 8 canais 5V/10A | Curto Circuito | R$42,00 promocional / R$52,00 cheio |
| DHT22/AM2302 | MakerHero | R$39,90 |
| Modulo pH PH-4502C | MakerHero | R$99,90 |
| Sensor TDS/EC | Eletrogate | referencia tecnica e faixa de mercado ~R$55 a R$70 |
| Camera IP Intelbras 2MP PoE basica | NetAlarmes | R$313,22 a R$396,77 em modelos VIP/VIPC 1230 |
| Switch PoE 5 portas Intelbras | Intelcenter | R$377,26 / R$371,60 Pix |
| Cabo CFTV/rede caixa 300 m | Intelcenter | R$330,03 / R$325,08 Pix |

Fontes:

- ESP32 MakerHero: https://www.makerhero.com/produto/modulo-wifi-esp32-bluetooth/
- Rele 8 canais Curto Circuito: https://curtocircuito.com.br/modulo-rele-8-canais-5v-10a.html
- DHT22 MakerHero: https://www.makerhero.com/produto/sensor-de-umidade-e-temperatura-am2302-dht22/
- pH MakerHero: https://www.makerhero.com/produto/modulo-de-leitura-ph-4502c-para-sensor-de-ph/
- TDS Eletrogate: https://www.eletrogate.com/modulo-medidor-de-qualidade-da-agua-tds-meter-v10
- Cameras IP NetAlarmes: https://www.netalarmes.com.br/camera-de-seguranca/ip?pg=1
- Switch PoE Intelcenter: https://www.intelcenter.com.br/redes/switch-poe
- Manual Intelbras S1105F-P, 4 portas PoE + 1 uplink: https://manuais-switches.intelbras.com.br/pt-BR/switches/switchNG/S1105F-P/guia.html

## 5. Estrutura de custos internos

### 5.1. Custo de hardware por cliente

#### Kit controle basico

| Item | Qtde | Custo estimado |
| --- | ---: | ---: |
| ESP32 | 1 | R$45 a R$70 |
| Modulo rele 4 ou 8 canais | 1 | R$40 a R$70 |
| Fonte 5V/12V | 1 | R$25 a R$80 |
| Caixa plastica/protecao simples | 1 | R$40 a R$150 |
| Bornes, conectores, jumpers, prensa-cabos | 1 kit | R$40 a R$120 |
| Cabos/fios internos | 1 kit | R$30 a R$100 |
| Margem para perdas/pecas extras | 1 | R$50 a R$120 |

Estimativa: `R$270 a R$710`.

#### Kit sensores completo

| Item | Qtde | Custo estimado |
| --- | ---: | ---: |
| DHT22/AM2302 ou SHT31 | 1 | R$40 a R$100 |
| HX711 | 1 | R$15 a R$45 |
| Celula de carga | 1 a 4 | R$40 a R$250 |
| Botoes tara/calibracao/taxa | 3 | R$15 a R$45 |
| Sensor nivel agua | 1 | R$15 a R$120 |
| DS18B20 inox | 1 | R$20 a R$60 |
| Sensor pH com modulo | 1 | R$100 a R$250 |
| Sensor TDS/EC | 1 | R$55 a R$150 |
| ADS1115 | 1 | R$25 a R$80 |
| Caixa, cabos, conectores e protecao | 1 kit | R$100 a R$300 |

Estimativa: `R$425 a R$1.400`.

#### Kit cameras pequeno

| Item | Qtde | Custo estimado |
| --- | ---: | ---: |
| Camera IP PoE 2MP | 2 | R$600 a R$900 |
| Switch PoE 4 portas | 1 | R$250 a R$400 |
| Cabo rede/CFTV proporcional | 1 | R$80 a R$250 |
| Conectores RJ45, caixas, fixadores | 1 kit | R$60 a R$180 |
| Fonte/nobreak pequeno opcional | 1 | R$150 a R$500 |

Estimativa: `R$990 a R$2.230`.

#### Kit cameras medio

| Item | Qtde | Custo estimado |
| --- | ---: | ---: |
| Camera IP PoE 2MP | 4 | R$1.200 a R$1.800 |
| Switch PoE 4/8 portas | 1 | R$300 a R$700 |
| Cabos e conectores | 1 kit | R$160 a R$450 |
| NVR/mini PC/gravacao opcional | 1 | R$600 a R$2.500 |

Estimativa: `R$1.660 a R$5.450`.

### 5.2. Deslocamento

Use regra simples:

| Tipo | Valor sugerido |
| --- | ---: |
| Ate 20 km ida/volta | incluso na instalacao |
| Acima de 20 km | R$1,50 a R$2,50 por km rodado |
| Pedagio/estacionamento | repasse integral |
| Diaria tecnica fora da cidade | R$350 a R$600 |
| Pernoite, se necessario | repasse integral ou combinado antes |

Sugestao pratica:

```text
Deslocamento = max(0, km_total - 20) x R$2,00
```

### 5.3. Mao de obra

| Servico | Valor sugerido |
| --- | ---: |
| Hora tecnica remota avulsa | R$80 a R$150 |
| Hora tecnica presencial | R$120 a R$220 |
| Instalacao simples sem camera | R$350 a R$700 |
| Instalacao com sensores | R$700 a R$1.500 |
| Instalacao com cameras | R$900 a R$2.500 |
| Treinamento inicial | R$250 a R$600 |

Regra minima: nunca cobre menos que o custo de deslocamento + 4 horas tecnicas + margem de retrabalho.

## 6. Pacotes comerciais sugeridos

### 6.1. Plano Essencial - entrada acessivel

Para produtor pequeno que quer comecar sem cameras.

Inclui:

- App SELETO.
- Cadastro de lotes.
- Coleta de ovos.
- Estoque.
- Alimentacao.
- Financeiro basico.
- Relatorios.
- Alertas locais.
- 1 integracao ESP32.
- Iluminacao ou ventilacao simples.
- Suporte remoto.

Nao inclui:

- Cameras.
- Kit completo de agua.
- Balanca fisica, se nao comprada.
- Visita presencial recorrente.

Preco sugerido:

```text
Implantacao: R$790 a R$1.490
Assinatura: R$99 a R$149/mes
Suporte incluso: ate 1 hora remota/mes
Fidelidade sugerida: 12 meses
```

Quando usar:

- Propriedade perto.
- Poucos sensores.
- Sem camera.
- Cliente sensivel a preco.

### 6.2. Plano Controle - melhor custo-beneficio

Plano recomendado para maior parte dos pequenos produtores.

Inclui:

- Tudo do Essencial.
- Kit ESP32 configurado.
- Balanca integrada ou preparada.
- Sensor de ambiente.
- Controle de iluminacao.
- Controle de ventilacao.
- Painel de hardware no app.
- Treinamento remoto ou presencial curto.
- Suporte remoto prioritario.

Preco sugerido:

```text
Implantacao sem comodato: R$1.990 a R$3.490
Assinatura: R$179 a R$249/mes
Suporte incluso: ate 2 horas remotas/mes
Visita presencial: cobrada a parte
Fidelidade sugerida: 12 meses
```

Quando usar:

- Granja pequena com 1 galpao.
- Cliente quer automacao real, mas sem cameras ainda.
- Bom equilibrio entre acessivel e viavel.

### 6.3. Plano Monitorado - app + sensores + cameras

Inclui:

- Tudo do Controle.
- 2 cameras IP.
- Cadastro e configuracao RTSP/ONVIF.
- Tela de monitoramento.
- Suporte a audio se camera permitir.
- Organizacao de rede local.
- Checklist de pontos criticos.

Preco sugerido:

```text
Implantacao sem comodato: R$3.490 a R$5.990
Assinatura: R$249 a R$399/mes
Suporte incluso: ate 3 horas remotas/mes
Fidelidade sugerida: 12 ou 18 meses
```

Adicional por camera:

```text
Camera extra instalada: R$550 a R$950
Assinatura por camera extra: R$20 a R$50/mes
```

Quando usar:

- Cliente quer ver a granja pelo celular.
- Precisa acompanhar mortalidade, abastecimento, entrada/saida, reservatorio ou corredor.

### 6.4. Plano Completo - granja conectada

Inclui:

- App completo.
- Sensores de ambiente, agua, balanca, iluminacao e ventilacao.
- 4 cameras.
- Treinamento presencial.
- Documentacao da instalacao.
- Revisao apos 30 dias.
- Suporte prioritario.

Preco sugerido:

```text
Implantacao sem comodato: R$5.990 a R$9.900
Assinatura: R$399 a R$699/mes
Suporte incluso: ate 5 horas remotas/mes
1 visita preventiva semestral opcional
Fidelidade sugerida: 18 ou 24 meses
```

Quando usar:

- Cliente tem operacao maior.
- Mais de um galpao.
- Quer acompanhamento serio.

## 7. Modelo com comodato

Comodato reduz barreira de entrada, mas aumenta risco. Use contrato com fidelidade, multa e devolucao dos equipamentos.

### 7.1. Regras basicas de comodato

1. Equipamentos continuam pertencendo a sua empresa.
2. Cliente paga taxa de adesao/instalacao.
3. Cliente paga assinatura mensal maior.
4. Prazo minimo: 24 meses.
5. Cancelamento antes do prazo exige:
   - pagamento de multa;
   - devolucao dos equipamentos;
   - pagamento de danos, se houver.
6. Manutencao cobre defeito normal, nao cobre mau uso, raio, agua, corte de cabo, inseto, roedor, queda ou alteracao por terceiros.

### 7.2. Comodato Essencial

Inclui:

- 1 ESP32.
- 1 modulo rele.
- Sensor ambiente.
- Configuracao do app.

Preco sugerido:

```text
Adesao/instalacao: R$490 a R$990
Mensalidade: R$189 a R$249
Prazo minimo: 24 meses
```

### 7.3. Comodato Monitorado

Inclui:

- 1 controlador ESP32.
- Sensor ambiente.
- Controle de luz/ventilacao simples.
- 2 cameras IP.
- Switch PoE.
- Configuracao no app.

Preco sugerido:

```text
Adesao/instalacao: R$990 a R$1.990
Mensalidade: R$349 a R$549
Prazo minimo: 24 meses
```

### 7.4. Comodato Completo

Inclui:

- Controlador ESP32.
- Kit sensores completo.
- Balanca.
- Agua.
- Ambiente.
- Luz/ventilacao.
- 4 cameras.

Preco sugerido:

```text
Adesao/instalacao: R$1.990 a R$3.990
Mensalidade: R$699 a R$1.190
Prazo minimo: 24 meses
```

Use este plano apenas quando houver contrato bem feito, cliente confiavel e margem suficiente.

## 8. Valores avulsos e adicionais

| Item | Valor sugerido ao cliente |
| --- | ---: |
| Camera IP instalada adicional | R$550 a R$950 |
| Sensor ambiente adicional | R$250 a R$450 |
| Sensor agua completo adicional | R$650 a R$1.300 |
| Balanca integrada adicional | R$700 a R$1.800 |
| Canal rele adicional | R$150 a R$350 |
| Treinamento extra remoto | R$120/h |
| Treinamento presencial extra | R$180/h + deslocamento |
| Reconfiguracao de rede/camera | R$150 a R$400 |
| Visita tecnica corretiva | R$250 minimo + deslocamento |
| Cabo adicional instalado | R$5 a R$12 por metro |
| Conectorizacao RJ45 | R$15 a R$30 por ponta |

## 9. Como calcular proposta personalizada

Use esta formula:

```text
Preco implantacao =
  custo_hardware
  + custo_materiais
  + deslocamento
  + horas_tecnicas x valor_hora
  + margem_de_risco
  + margem_lucro
```

Sugestao:

```text
valor_hora = R$120 a R$180
margem_de_risco = 15% a 25%
margem_lucro = 30% a 60%
```

Para pequeno produtor, reduza a entrada e preserve margem na assinatura.

### 9.1. Formas de pagamento com taxa da maquininha incluída

Use esta regra para apresentar parcelamento sem perder margem:

```text
valor_a_cobrar = valor_liquido_desejado / (1 - taxa_da_maquininha)
valor_da_parcela = valor_a_cobrar / quantidade_de_parcelas
```

Nunca calcule a parcela apenas dividindo o preco Pix pelo numero de parcelas. Primeiro aplique a taxa da maquininha, depois divida.

Taxas InfinitePay informadas para usar como base:

| Faixa de faturamento | Pix | Debito | Credito a vista | Credito 12x |
| --- | ---: | ---: | ---: | ---: |
| Plano inicial, ate R$20 mil/mes | 0,00% | 1,37% | 3,15% | 12,40% |
| Acima de R$20 mil/mes | 0,00% | 0,85% | 2,89% | 10,12% |
| Acima de R$40 mil/mes | 0,00% | 0,79% | 2,79% | 9,56% |
| Acima de R$80 mil/mes | 0,00% | 0,75% | 2,69% | 8,99% |

Para comecar, use a tabela do **plano inicial ate R$20 mil/mes**, pois e a mais conservadora. Se a empresa ja estiver em faixa melhor, a diferenca vira margem extra ou desconto negociado.

#### Tabela pronta para as ofertas recomendadas

Valores abaixo ja incluem taxa da maquininha do plano inicial:

| Oferta | Valor liquido desejado | Pix | Debito 1,37% | Credito a vista 3,15% | Credito 12x 12,40% |
| --- | ---: | ---: | ---: | ---: | ---: |
| Implantacao Plano Controle | R$1.990,00 | R$1.990,00 | R$2.017,64 | R$2.054,72 | 12x R$189,31 |
| Implantacao Plano Monitorado | R$3.990,00 | R$3.990,00 | R$4.045,42 | R$4.119,77 | 12x R$379,57 |
| Adesao Comodato Monitorado | R$1.490,00 | R$1.490,00 | R$1.510,70 | R$1.538,46 | 12x R$141,74 |

#### Mensalidade com taxa embutida

Para mensalidade, prefira Pix recorrente ou boleto/transferencia. Se o cliente pagar a mensalidade no cartao, cobre o valor ja com taxa:

| Mensalidade | Valor liquido desejado | Pix | Debito 1,37% | Credito a vista 3,15% |
| --- | ---: | ---: | ---: | ---: |
| Plano Controle | R$199,00 | R$199,00 | R$201,76 | R$205,47 |
| Plano Monitorado | R$299,00 | R$299,00 | R$303,15 | R$308,72 |
| Comodato Monitorado | R$449,00 | R$449,00 | R$455,24 | R$463,60 |

Se o cliente quiser pagar **12 mensalidades no cartao em 12x**, cobre o contrato anual ja com taxa:

| Plano | Valor anual liquido | Credito 12x com taxa 12,40% |
| --- | ---: | ---: |
| Plano Controle | R$2.388,00 | 12x R$227,17 |
| Plano Monitorado | R$3.588,00 | 12x R$341,32 |
| Comodato Monitorado | R$5.388,00 | 12x R$512,56 |

#### Texto comercial recomendado

Use este texto na proposta:

```text
Os valores em Pix representam o valor liquido da proposta. Para pagamentos em debito, credito a vista ou parcelado, o valor final ja inclui a taxa da operadora da maquininha, sem surpresa para o cliente e sem perda de margem para a implantacao.
```

#### Regra de arredondamento

Arredonde sempre para cima:

```text
R$189,31 pode virar R$189,90
R$379,57 pode virar R$379,90
R$141,74 pode virar R$141,90
```

Assim voce evita diferenca por arredondamento, antecipacao ou pequena mudanca de taxa.

Exemplo:

```text
Custo hardware: R$1.200
Materiais: R$300
Deslocamento: R$160
Horas tecnicas: 10 x R$130 = R$1.300
Risco 15%: R$444
Subtotal: R$3.404

Preco sugerido: R$3.490
Mensalidade: R$249
```

## 10. Modelo de proposta para cliente

### 10.1. Texto curto

```text
Proposta SELETO - Plano Controle

Implantacao do sistema de gestao e automacao da granja, com configuracao do aplicativo, controlador ESP32, sensores iniciais, controle de iluminacao/ventilacao e treinamento de uso.

Inclui:
- configuracao do app;
- cadastro inicial da propriedade;
- instalacao do controlador;
- integracao com ESP32;
- testes de acionamento;
- treinamento inicial;
- suporte remoto.

Investimento de implantacao: R$ X
Assinatura mensal: R$ Y
Pagamento: Pix, debito, credito a vista ou ate 12x no credito com taxa da maquininha incluida.
Prazo minimo: 12 meses
Deslocamento: incluso ate 20 km; excedente R$2,00/km.
```

### 10.2. Texto com cameras

```text
Proposta SELETO - Plano Monitorado

Implantacao do sistema de gestao, sensores e monitoramento por cameras IP, permitindo acompanhar a rotina da granja pelo aplicativo, registrar producao, controlar automacoes e acessar cameras configuradas na rede local.

Inclui:
- app SELETO configurado;
- controlador ESP32;
- sensor de ambiente;
- controle de iluminacao e/ou ventilacao;
- 2 cameras IP;
- switch PoE;
- configuracao RTSP/ONVIF;
- treinamento inicial;
- suporte remoto prioritario.

Investimento de implantacao: R$ X
Assinatura mensal: R$ Y
Camera adicional: R$ Z
Pagamento: Pix, debito, credito a vista ou ate 12x no credito com taxa da maquininha incluida.
Prazo minimo: 12 ou 18 meses
```

### 10.3. Texto de comodato

```text
Proposta SELETO - Comodato Monitorado

Nesta modalidade, os equipamentos principais sao fornecidos em comodato durante a vigencia do contrato. O produtor paga uma taxa inicial reduzida e uma mensalidade que inclui uso do sistema, suporte e direito de uso dos equipamentos enquanto o contrato estiver ativo.

Adesao/instalacao: R$ X
Mensalidade: R$ Y
Pagamento da adesao: Pix, debito, credito a vista ou ate 12x no credito com taxa da maquininha incluida.
Prazo minimo: 24 meses
Equipamentos em comodato: controlador, sensores e cameras descritos no anexo.

Em caso de cancelamento antes do prazo, os equipamentos devem ser devolvidos em bom estado e podera haver multa proporcional conforme contrato.
```

## 11. O que nao prometer

Nao prometa:

- Camera funcionando sem internet local adequada.
- Leitura perfeita de sensor barato sem calibracao.
- Precisao de balanca sem estrutura mecanica correta.
- Alertas criticos sem energia/backup.
- Suporte 24h se o plano nao paga isso.
- Gravacao em nuvem ilimitada sem cobrar armazenamento.
- Instalacao eletrica de rede 127/220 V sem eletricista habilitado.

Prometa:

- Implantacao assistida.
- Treinamento.
- Ajuste inicial.
- Suporte por canal definido.
- Evolucao gradual.
- Documentacao basica da instalacao.

## 12. Garantia e suporte sugeridos

### 12.1. Garantia

```text
Garantia de configuracao: 30 dias.
Garantia de equipamentos: conforme fabricante ou fornecedor.
Garantia de instalacao: 90 dias para defeitos de montagem feita pela equipe.
Nao cobre: raio, umidade indevida, queda, corte de cabo, alteracao por terceiros, mau uso, pragas, sobrecarga eletrica ou falta de aterramento.
```

### 12.2. SLA simples

| Plano | Resposta remota | Correcao remota | Visita |
| --- | --- | --- | --- |
| Essencial | ate 2 dias uteis | conforme fila | avulsa |
| Controle | ate 1 dia util | prioridade normal | avulsa |
| Monitorado | ate 8 horas uteis | prioridade alta | avulsa/desconto |
| Completo | ate 4 horas uteis | prioridade alta | preventiva opcional |

## 13. Estrategia para nao ficar caro demais

1. Vender primeiro o app + controle basico.
2. Deixar camera como modulo.
3. Deixar agua/pH/TDS como modulo avancado.
4. Oferecer comodato apenas para clientes com boa chance de permanencia.
5. Usar camera 2MP PoE de entrada para comecar.
6. Cobrar deslocamento fora da cidade.
7. Cobrar camera adicional.
8. Evitar suporte ilimitado barato.
9. Criar planos com horas de suporte inclusas.
10. Fazer revisao de mensalidade anual.

## 14. Plano de marketing e divulgacao

### 14.1. Oferta principal

Nome sugerido:

```text
SELETO - Gestao e monitoramento para pequenos produtores
```

Promessa:

```text
Menos anotacao perdida, mais controle da producao e mais seguranca na rotina da granja.
```

### 14.2. Canais

Use:

- WhatsApp Business.
- Instagram.
- Facebook local.
- Grupos de produtores.
- Parcerias com lojas agropecuarias.
- Parcerias com tecnicos rurais.
- Visita a produtores proximos.
- Demonstracao presencial em uma granja piloto.
- Video curto mostrando app + camera + sensor.

### 14.3. Conteudos para postar

1. Antes/depois: caderno vs app.
2. Video de coleta de ovos no app.
3. Video de camera abrindo no app.
4. Video do ESP32 ligando um rele.
5. Video do ventilador no app.
6. Print do dashboard.
7. Alerta de estoque baixo.
8. Controle de custos e vendas.
9. Depoimento de produtor piloto.
10. Post educativo: "Quanto custa nao saber sua producao diaria?"

### 14.4. Roteiro de video de 30 segundos

```text
Cena 1: produtor anotando ovos no caderno.
Texto: "Ainda controla sua granja assim?"

Cena 2: app mostrando coleta e estoque.
Texto: "Registre producao, estoque e vendas pelo celular."

Cena 3: camera/monitoramento.
Texto: "Veja a granja e acompanhe pontos criticos."

Cena 4: sensor/automacao.
Texto: "Integre sensores, luz e ventilacao."

Cena 5: chamada.
Texto: "SELETO: tecnologia acessivel para pequenos produtores."
CTA: "Chame no WhatsApp para uma avaliacao."
```

### 14.5. Abordagem comercial por WhatsApp

```text
Oi, tudo bem? Eu trabalho com uma solucao chamada SELETO, feita para pequenos produtores controlarem producao de ovos, estoque, alimentacao, vendas, cameras e sensores pelo celular.

A ideia nao e vender um sistema caro de industria, e sim comecar com um plano acessivel e ir evoluindo conforme a necessidade da granja.

Posso te mandar uma demonstracao rapida em video?
```

### 14.6. Diagnostico gratuito controlado

Ofereca:

```text
Diagnostico remoto gratuito de 15 minutos.
```

Pergunte:

1. Quantas aves?
2. Quantos galpoes?
3. Quantas coletas por dia?
4. Hoje anota onde?
5. Tem internet na propriedade?
6. Tem cameras?
7. Quer controlar luz/ventilacao?
8. Qual maior problema hoje?
9. Quanto perde por falta de controle?
10. Prefere comprar equipamento ou comodato?

Nao ofereca visita gratuita longa. Visita tecnica deve ser cobrada ou abatida se fechar contrato.

## 15. Funil de vendas

### Etapa 1: Atrair

- Conteudo curto.
- Antes/depois.
- Demonstracao real.
- Prova social.

### Etapa 2: Diagnosticar

- Conversa de 15 minutos.
- Levantar numero de galpoes, cameras, sensores e distancia.
- Identificar dor principal.

### Etapa 3: Propor plano simples

Ofereca no maximo 2 opcoes:

```text
Opcao A: Controle sem cameras.
Opcao B: Controle com 2 cameras.
```

Evite mandar 5 planos para cliente pequeno.

### Etapa 4: Fechar

- Entrada.
- Contrato.
- Agendamento.
- Checklist pre-instalacao.

### Etapa 5: Implantar

- Instalar.
- Testar.
- Treinar.
- Gravar video curto ensinando o cliente.

### Etapa 6: Reter

- Contato em 7 dias.
- Contato em 30 dias.
- Relatorio simples de uso.
- Oferta de modulo adicional.

## 16. Checklist antes de instalar

1. Confirmar internet/Wi-Fi.
2. Confirmar pontos de energia.
3. Confirmar local dos sensores.
4. Confirmar distancia ate cameras.
5. Confirmar se precisa passar cabo.
6. Confirmar se ha conduites/canaletas.
7. Confirmar se ha aterramento.
8. Confirmar se o produtor autoriza furos/fixacao.
9. Confirmar se tem tomada protegida.
10. Confirmar data sem chuva forte, se instalacao externa.
11. Levar cabos extras.
12. Levar conectores extras.
13. Levar fonte reserva.
14. Levar ESP32 reserva.
15. Levar modulo rele reserva.

## 17. Contrato: clausulas que nao podem faltar

1. Descricao dos servicos.
2. Equipamentos vendidos ou em comodato.
3. Responsabilidade por internet e energia.
4. Limites de suporte.
5. Prazos de atendimento.
6. Garantia.
7. Exclusoes de garantia.
8. Valor da mensalidade.
9. Reajuste anual.
10. Multa por cancelamento antecipado, se houver.
11. Devolucao de equipamentos em comodato.
12. Autorizacao para uso de imagem/depoimento, se desejado.
13. Termo de aceite apos instalacao.

## 18. Recomendacao final de preco

Para comecar vendendo sem assustar pequenos produtores:

### Oferta inicial recomendada

```text
Plano Controle
Implantacao Pix: R$1.990
Implantacao no debito: R$2.017,64
Implantacao no credito a vista: R$2.054,72
Implantacao no credito 12x: 12x R$189,31
Mensalidade: R$199
Sem cameras
Com ESP32 + sensor ambiente + controle luz/ventilacao simples
```

### Oferta com cameras recomendada

```text
Plano Monitorado
Implantacao Pix: R$3.990
Implantacao no debito: R$4.045,42
Implantacao no credito a vista: R$4.119,77
Implantacao no credito 12x: 12x R$379,57
Mensalidade: R$299
Inclui ate 2 cameras, app e suporte remoto
```

### Oferta comodato recomendada

```text
Comodato Monitorado
Adesao Pix: R$1.490
Adesao no debito: R$1.510,70
Adesao no credito a vista: R$1.538,46
Adesao no credito 12x: 12x R$141,74
Mensalidade: R$449
Prazo minimo: 24 meses
Inclui app, controlador e ate 2 cameras
```

Estas tres ofertas equilibram acesso para pequeno produtor e viabilidade do projeto.

## 19. Frase de venda

```text
O SELETO nao e so um aplicativo. E um jeito simples de colocar gestao, cameras e automacao dentro da granja sem precisar comprar uma solucao industrial cara.
```

## 20. Proxima evolucao comercial

Depois dos primeiros 3 clientes:

1. Criar video de demonstracao real.
2. Criar folder PDF de 1 pagina.
3. Criar contrato padrao.
4. Criar checklist de instalacao.
5. Criar tabela de adicionais.
6. Criar pagina simples de vendas.
7. Criar programa de indicacao:

```text
Indicou e fechou: 1 mensalidade com 50% de desconto ou R$100 de credito.
```
