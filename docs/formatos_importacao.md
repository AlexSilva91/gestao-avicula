# Formatos de Importacao - GRANJA SELETO

Este documento descreve os arquivos aceitos pela tela **Configuracoes > Importar dados iniciais**.

A importacao substitui os dados operacionais do banco local e preserva usuarios, permissoes e auditoria. As secoes protegidas `users`, `userPermissions` e `auditLogs` sao ignoradas durante o import.

## Formatos Aceitos

- `.json`
- `.csv`
- `.xml`
- `.xlsx`
- `.xlsl`

O formato mais seguro e recomendado e **JSON**, porque preserva melhor relacionamentos entre tabelas.

## Regras Gerais

- O importador converte qualquer arquivo aceito para o formato interno `SELETO_BACKUP_V1`.
- Dinheiro sempre deve estar em centavos. Exemplo: R$ 12,50 = `1250`.
- Pesos e quantidades decimais aceitam ponto ou virgula. Exemplo: `10.5` ou `10,5`.
- Datas aceitas:
  - ISO: `2026-09-03T10:30:00`
  - Brasil: `03/09/2026`
  - Brasil com hora: `03/09/2026 10:30`
- Booleanos aceitos:
  - verdadeiro: `true`, `1`, `sim`, `yes`, `ativo`, `enabled`
  - falso: `false`, `0`, `nao`, `não`, `no`, vazio
- IDs devem ser unicos dentro de cada secao.
- Campos de relacionamento devem apontar para IDs existentes. Exemplo: `birdMovements.lotId` deve existir em `lots.id`.
- Campos opcionais podem ser omitidos ou enviados como `null`.
- No JSON, os nomes dos campos devem usar `camelCase`.
- Em CSV/XLSX, cabecalhos em `snake_case` sao convertidos para `camelCase`. Exemplo: `created_at` vira `createdAt`.

## JSON

Estrutura recomendada:

```json
{
  "format": "SELETO_BACKUP_V1",
  "exportedAt": "2026-09-03T09:30:00",
  "lots": [],
  "birdMovements": [],
  "eggCollections": [],
  "eggStockMovements": [],
  "ingredients": [],
  "prices": [],
  "ingredientLots": [],
  "ingredientStockMovements": [],
  "formulas": [],
  "formulaItems": [],
  "feedBatches": [],
  "feedBatchItems": [],
  "feedStock": [],
  "feedings": [],
  "customers": [],
  "orders": [],
  "orderItems": [],
  "orderStatusHistory": [],
  "sales": [],
  "finance": [],
  "investments": [],
  "lightingPrograms": [],
  "lightingSteps": [],
  "lotLighting": [],
  "calendarEvents": [],
  "notificationSettings": [],
  "appSettings": []
}
```

Tambem e aceito um JSON que seja uma lista simples. Nesse caso, o app interpreta a lista como `calendarEvents`.

## CSV

O CSV precisa ter cabecalho e ao menos uma linha.

Existem dois modos:

1. Um arquivo por secao, usando o nome do arquivo como secao.
   - Exemplo: `lotes.csv`, `ingredients.csv`, `alertas.csv`.
2. Um arquivo unico com coluna `section`, `table` ou `tabela`.

Exemplo:

```csv
section,id,name,strain,initialQuantity,receivedAt,arrivalAgeDays,status,createdAt,createdBy
lots,lote-001,LOTE 001,Embrapa 051,500,2026-09-01T00:00:00,30,ACTIVE,2026-09-03T09:30:00,admin
```

## XLSX / XLSL

Cada aba da planilha deve ter o nome de uma secao ou alias aceito.

Exemplos de abas:

- `lots`
- `lotes`
- `ingredients`
- `ingredientes`
- `calendarEvents`
- `alertas`

A primeira linha da aba deve conter os nomes dos campos.

## XML

O XML deve ter um elemento raiz qualquer. Dentro dele, cada filho direto representa uma secao.

Exemplo:

```xml
<import>
  <lots>
    <row>
      <id>lote-001</id>
      <name>LOTE 001</name>
      <strain>Embrapa 051</strain>
      <initialQuantity>500</initialQuantity>
      <receivedAt>2026-09-01T00:00:00</receivedAt>
      <arrivalAgeDays>30</arrivalAgeDays>
      <status>ACTIVE</status>
      <createdAt>2026-09-03T09:30:00</createdAt>
      <createdBy>admin</createdBy>
    </row>
  </lots>
</import>
```

Tambem aceita campos como atributos:

```xml
<import>
  <lots>
    <row id="lote-001" name="LOTE 001" initialQuantity="500" receivedAt="2026-09-01T00:00:00" arrivalAgeDays="30" status="ACTIVE" createdAt="2026-09-03T09:30:00" createdBy="admin" />
  </lots>
</import>
```

## Secoes e Aliases

| Secao interna | Aliases aceitos |
|---|---|
| `lots` | `lots`, `lotes` |
| `birdMovements` | `birdmovements`, `movimentosaves` |
| `eggCollections` | `eggcollections`, `coletasovos` |
| `eggStockMovements` | `eggstockmovements`, `estoqueovos` |
| `ingredients` | `ingredients`, `ingredientes` |
| `prices` | `prices`, `precos` |
| `ingredientLots` | `ingredientlots`, `lotesinsumos`, `lotesdeinsumos` |
| `ingredientStockMovements` | `ingredientstockmovements`, `movimentosinsumos`, `estoqueinsumos` |
| `formulas` | `formulas` |
| `formulaItems` | `formulaitems` |
| `feedBatches` | `feedbatches`, `lotesracao` |
| `feedBatchItems` | `feedbatchitems` |
| `feedStock` | `feedstock`, `estoqueracao` |
| `feedings` | `feedings`, `alimentacao` |
| `customers` | `customers`, `clientes` |
| `orders` | `orders`, `pedidos` |
| `orderItems` | `orderitems` |
| `orderStatusHistory` | `orderstatushistory` |
| `sales` | `sales`, `vendas` |
| `finance` | `finance`, `financeiro` |
| `investments` | `investments`, `investimentos` |
| `lightingPrograms` | `lightingprograms`, `programasluz` |
| `lightingSteps` | `lightingsteps`, `etapasluz` |
| `lotLighting` | `lotlighting` |
| `calendarEvents` | `calendarevents`, `eventos`, `alertas` |
| `notificationSettings` | `notificationsettings`, `configuracoesalertas` |
| `appSettings` | `appsettings`, `configuracoes` |

## Campos por Secao

Legenda:

- `texto`: string
- `inteiro`: numero inteiro
- `decimal`: numero com casas decimais
- `data`: data/hora
- `booleano`: verdadeiro/falso
- `opcional`: pode ser `null` ou omitido quando o banco tiver valor padrao

### `lots` - Lotes

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `name` | texto | Obrigatorio, unico. |
| `strain` | texto | Opcional. Linhagem. |
| `initialQuantity` | inteiro | Obrigatorio. |
| `receivedAt` | data | Obrigatorio. |
| `arrivalAgeDays` | inteiro | Obrigatorio. Idade de chegada em dias. |
| `unitValueCents` | inteiro | Opcional. Valor unitario da ave em centavos. |
| `supplier` | texto | Opcional. |
| `notes` | texto | Opcional. |
| `status` | texto | Opcional. Padrao `ACTIVE`. |
| `createdAt` | data | Obrigatorio. |
| `createdBy` | texto | Obrigatorio. |

### `birdMovements` - Movimentacoes de aves

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `type` | texto | Obrigatorio. Ex.: `PURCHASE`, `SALE`, `MORTALITY`, `TRANSFER_IN`, `TRANSFER_OUT`, `ADJUSTMENT_IN`, `ADJUSTMENT_OUT`. |
| `occurredAt` | data | Obrigatorio. |
| `lotId` | texto | Obrigatorio. Referencia `lots.id`. |
| `relatedLotId` | texto | Opcional. |
| `quantity` | inteiro | Obrigatorio. |
| `unitValueCents` | inteiro | Opcional. |
| `totalValueCents` | inteiro | Opcional. |
| `reference` | texto | Opcional. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `eggCollections` - Coletas de ovos

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `collectedOn` | data | Obrigatorio. |
| `lotId` | texto | Obrigatorio. Referencia `lots.id`. |
| `quantity` | inteiro | Obrigatorio. Total coletado. |
| `brokenEggs` | inteiro | Opcional. Padrao `0`. |
| `discardedEggs` | inteiro | Opcional. Padrao `0`. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `eggStockMovements` - Estoque de ovos

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `type` | texto | Obrigatorio. Ex.: `COLLECTION_IN`, `SALE_OUT`, `LOSS_OUT`, `ADJUSTMENT_IN`, `ADJUSTMENT_OUT`. |
| `occurredAt` | data | Obrigatorio. |
| `quantity` | inteiro | Obrigatorio. |
| `collectionId` | texto | Opcional. Referencia `eggCollections.id`. |
| `reference` | texto | Opcional. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `ingredients` - Insumos

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `name` | texto | Obrigatorio, unico. |
| `unit` | texto | Opcional. Padrao `kg`. |
| `isActive` | booleano | Opcional. Padrao `true`. |
| `notes` | texto | Opcional. |
| `createdAt` | data | Obrigatorio. |
| `createdBy` | texto | Obrigatorio. |

### `prices` - Historico de precos dos insumos

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `ingredientId` | texto | Obrigatorio. Referencia `ingredients.id`. |
| `pricePerKgCents` | inteiro | Obrigatorio. Valor por kg em centavos. |
| `effectiveDate` | data | Obrigatorio. |
| `supplier` | texto | Opcional. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `ingredientLots` - Lotes de insumos

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `ingredientId` | texto | Obrigatorio. Referencia `ingredients.id`. |
| `code` | texto | Obrigatorio, unico. |
| `entryDate` | data | Obrigatorio. |
| `initialQuantityKg` | decimal | Obrigatorio. |
| `packageUnit` | texto | Opcional. Padrao `KG`. Ex.: `SACO`, `KG`. |
| `packageQuantity` | decimal | Opcional. Quantidade de embalagens. |
| `packageWeightKg` | decimal | Opcional. Kg por embalagem. Padrao `1`. |
| `totalCostCents` | inteiro | Obrigatorio. |
| `pricePerKgCents` | inteiro | Obrigatorio. |
| `supplier` | texto | Opcional. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `ingredientStockMovements` - Movimentacoes de estoque de insumos

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `type` | texto | Obrigatorio. Ex.: `ENTRY`, `CORRECTION_IN`, `CORRECTION_OUT`, `PRODUCTION_OUT`. |
| `occurredAt` | data | Obrigatorio. |
| `ingredientId` | texto | Obrigatorio. Referencia `ingredients.id`. |
| `ingredientLotId` | texto | Obrigatorio. Referencia `ingredientLots.id`. |
| `quantityKg` | decimal | Obrigatorio. |
| `pricePerKgCentsSnapshot` | inteiro | Obrigatorio. |
| `totalCostCents` | inteiro | Obrigatorio. |
| `referenceType` | texto | Opcional. |
| `referenceId` | texto | Opcional. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `formulas` - Formulas de racao

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `name` | texto | Obrigatorio. |
| `phase` | texto | Obrigatorio. |
| `version` | inteiro | Opcional. Padrao `1`. |
| `isActive` | booleano | Opcional. Padrao `true`. |
| `validFrom` | data | Obrigatorio. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `formulaItems` - Itens das formulas

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `formulaId` | texto | Obrigatorio. Referencia `formulas.id`. |
| `ingredientId` | texto | Obrigatorio. Referencia `ingredients.id`. |
| `baseQuantityKg` | decimal | Obrigatorio. |

### `feedBatches` - Fabricacoes de racao

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `code` | texto | Obrigatorio, unico. |
| `phase` | texto | Obrigatorio. |
| `formulaId` | texto | Obrigatorio. Referencia `formulas.id`. |
| `producedAt` | data | Obrigatorio. |
| `producedQuantityKg` | decimal | Obrigatorio. |
| `totalCostCents` | inteiro | Obrigatorio. |
| `costPerKgCents` | decimal | Obrigatorio. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `feedBatchItems` - Itens da fabricacao

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `batchId` | texto | Obrigatorio. Referencia `feedBatches.id`. |
| `ingredientId` | texto | Obrigatorio. Referencia `ingredients.id`. |
| `quantityKg` | decimal | Obrigatorio. |
| `pricePerKgCentsSnapshot` | inteiro | Obrigatorio. |
| `itemCostCents` | inteiro | Obrigatorio. |

### `feedStock` - Movimentacoes de estoque de racao

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `type` | texto | Obrigatorio. Ex.: `PRODUCTION_IN`, `FEEDING_OUT`, `ADJUSTMENT_IN`, `ADJUSTMENT_OUT`. |
| `occurredAt` | data | Obrigatorio. |
| `batchId` | texto | Obrigatorio. Referencia `feedBatches.id`. |
| `quantityKg` | decimal | Obrigatorio. |
| `feedingId` | texto | Opcional. Referencia `feedings.id`. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `feedings` - Alimentacao diaria

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `feedingDate` | data | Obrigatorio. |
| `lotId` | texto | Obrigatorio. Referencia `lots.id`. |
| `batchId` | texto | Obrigatorio. Referencia `feedBatches.id`. |
| `quantityKg` | decimal | Obrigatorio. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `customers` - Clientes

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `name` | texto | Obrigatorio. |
| `phone` | texto | Opcional. |
| `address` | texto | Opcional. |
| `notes` | texto | Opcional. |
| `isActive` | booleano | Opcional. Padrao `true`. |
| `createdAt` | data | Obrigatorio. |
| `createdBy` | texto | Obrigatorio. |

### `orders` - Pedidos

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `orderNumber` | inteiro | Obrigatorio, unico. |
| `customerId` | texto | Opcional. Referencia `customers.id`. |
| `requestedDate` | data | Obrigatorio. |
| `expectedDeliveryDate` | data | Opcional. |
| `status` | texto | Opcional. Padrao `DRAFT`. |
| `subtotalCents` | inteiro | Obrigatorio. |
| `discountCents` | inteiro | Opcional. Padrao `0`. |
| `totalCents` | inteiro | Obrigatorio. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `updatedBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |
| `updatedAt` | data | Obrigatorio. |

### `orderItems` - Itens dos pedidos

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `orderId` | texto | Obrigatorio. Referencia `orders.id`. |
| `productType` | texto | Obrigatorio. |
| `quantity` | decimal | Obrigatorio. |
| `unitPriceCents` | inteiro | Obrigatorio. |
| `totalCents` | inteiro | Obrigatorio. |

### `orderStatusHistory` - Historico dos pedidos

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `orderId` | texto | Obrigatorio. Referencia `orders.id`. |
| `oldStatus` | texto | Opcional. |
| `newStatus` | texto | Obrigatorio. |
| `changedAt` | data | Obrigatorio. |
| `changedBy` | texto | Obrigatorio. |
| `notes` | texto | Opcional. |

### `sales` - Vendas

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `soldAt` | data | Obrigatorio. |
| `customerId` | texto | Opcional. Referencia `customers.id`. |
| `orderId` | texto | Opcional, unico. Referencia `orders.id`. |
| `dozens` | inteiro | Opcional. Padrao `0`. |
| `looseEggs` | inteiro | Opcional. Padrao `0`. |
| `dozenPriceCents` | inteiro | Obrigatorio. |
| `totalCents` | inteiro | Obrigatorio. |
| `paymentMethod` | texto | Obrigatorio. |
| `status` | texto | Opcional. Padrao `CONFIRMED`. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `finance` - Financeiro

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `occurredAt` | data | Obrigatorio. |
| `type` | texto | Obrigatorio. Ex.: `INCOME`, `EXPENSE`. |
| `category` | texto | Obrigatorio. |
| `description` | texto | Obrigatorio. |
| `amountCents` | inteiro | Obrigatorio. |
| `referenceType` | texto | Opcional. |
| `referenceId` | texto | Opcional. |
| `paymentMethod` | texto | Opcional. |
| `status` | texto | Opcional. Padrao `CONFIRMED`. |
| `notes` | texto | Opcional. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `investments` - Investimentos

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `description` | texto | Obrigatorio. |
| `category` | texto | Obrigatorio. |
| `investmentDate` | data | Obrigatorio. |
| `amountCents` | inteiro | Obrigatorio. |
| `lotId` | texto | Opcional. Referencia `lots.id`. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `lightingPrograms` - Programas de luz

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `name` | texto | Obrigatorio. |
| `description` | texto | Opcional. |
| `isDefault` | booleano | Opcional. Padrao `false`. |
| `isActive` | booleano | Opcional. Padrao `true`. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `lightingSteps` - Etapas dos programas de luz

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `programId` | texto | Obrigatorio. Referencia `lightingPrograms.id`. |
| `startAgeDays` | inteiro | Obrigatorio. |
| `endAgeDays` | inteiro | Opcional. |
| `totalLightMinutes` | inteiro | Obrigatorio. |
| `startTime` | texto | Opcional. Ex.: `05:00`. |
| `endTime` | texto | Opcional. Ex.: `21:00`. |
| `weeklyIncrementMinutes` | inteiro | Opcional. Padrao `0`. |
| `relatedPhase` | texto | Opcional. |
| `notes` | texto | Opcional. |

### `lotLighting` - Programa de luz por lote

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `lotId` | texto | Obrigatorio, unico. Referencia `lots.id`. |
| `programId` | texto | Obrigatorio. Referencia `lightingPrograms.id`. |
| `assignedAt` | data | Obrigatorio. |
| `createdBy` | texto | Obrigatorio. |

### `calendarEvents` - Eventos e alertas

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `title` | texto | Obrigatorio. |
| `type` | texto | Obrigatorio. Ex.: `EVENT`, `ALERT`, `FEED`, `LIGHTING`, `PHASE_CHANGE`, `ORDER`, `DELIVERY`. |
| `startsAt` | data | Obrigatorio. Data inicial do evento. |
| `endsAt` | data | Opcional. |
| `lotId` | texto | Opcional. Referencia `lots.id`. |
| `referenceType` | texto | Opcional. |
| `referenceId` | texto | Opcional. |
| `notes` | texto | Opcional. |
| `alertEnabled` | booleano | Opcional. Padrao `true`. |
| `alertMessage` | texto | Opcional. |
| `alertTime` | texto | Opcional. Padrao `08:00`. Formato `HH:mm`. |
| `recurrence` | texto | Opcional. Padrao `ONCE`. Aceita `ONCE`, `DAILY`, `WEEKLY`, `MONTHLY`. |
| `repeatUntil` | data | Opcional. |
| `weekdays` | texto | Opcional. Dias separados por virgula para recorrencia semanal. Segunda=1 ... Domingo=7. Ex.: `1,3,5`. |
| `createdBy` | texto | Obrigatorio. |
| `createdAt` | data | Obrigatorio. |

### `notificationSettings` - Configuracoes de alertas

| Campo | Tipo | Observacao |
|---|---|---|
| `id` | texto | Obrigatorio. |
| `type` | texto | Obrigatorio, unico. Ex.: `PHASE_CHANGE`, `LIGHTING`, `LOW_STOCK`, `ORDER`, `DELIVERY`, `FEED`. |
| `isEnabled` | booleano | Opcional. Padrao `true`. |
| `daysBefore` | inteiro | Opcional. Padrao `1`. |
| `notificationTime` | texto | Opcional. Padrao `08:00`. Formato `HH:mm`. |
| `defaultMessage` | texto | Opcional. |
| `defaultRecurrence` | texto | Opcional. Padrao `ONCE`. |

### `appSettings` - Configuracoes gerais

| Campo | Tipo | Observacao |
|---|---|---|
| `key` | texto | Obrigatorio. Chave unica. |
| `value` | texto | Obrigatorio. |
| `updatedAt` | data | Obrigatorio. |
| `updatedBy` | texto | Opcional. |

## Exemplo Completo Minimo

```json
{
  "format": "SELETO_BACKUP_V1",
  "exportedAt": "2026-09-03T09:30:00",
  "lots": [
    {
      "id": "lote-001",
      "name": "LOTE 001",
      "strain": "Embrapa 051",
      "initialQuantity": 500,
      "receivedAt": "2026-09-01T00:00:00",
      "arrivalAgeDays": 30,
      "unitValueCents": 1200,
      "supplier": "Fornecedor A",
      "notes": "Entrada inicial",
      "status": "ACTIVE",
      "createdAt": "2026-09-03T09:30:00",
      "createdBy": "admin"
    }
  ],
  "birdMovements": [
    {
      "id": "mov-aves-001",
      "type": "PURCHASE",
      "occurredAt": "2026-09-01T00:00:00",
      "lotId": "lote-001",
      "quantity": 500,
      "unitValueCents": 1200,
      "totalValueCents": 600000,
      "createdBy": "admin",
      "createdAt": "2026-09-03T09:30:00"
    }
  ],
  "ingredients": [
    {
      "id": "milho",
      "name": "Milho",
      "unit": "kg",
      "isActive": true,
      "createdAt": "2026-09-03T09:30:00",
      "createdBy": "admin"
    }
  ],
  "prices": [
    {
      "id": "preco-milho-001",
      "ingredientId": "milho",
      "pricePerKgCents": 120,
      "effectiveDate": "2026-09-03T00:00:00",
      "supplier": "Fornecedor A",
      "createdBy": "admin",
      "createdAt": "2026-09-03T09:30:00"
    }
  ],
  "ingredientLots": [
    {
      "id": "lote-milho-001",
      "ingredientId": "milho",
      "code": "MILHO-001",
      "entryDate": "2026-09-03T00:00:00",
      "initialQuantityKg": 600,
      "packageUnit": "SACO",
      "packageQuantity": 12,
      "packageWeightKg": 50,
      "totalCostCents": 72000,
      "pricePerKgCents": 120,
      "supplier": "Fornecedor A",
      "createdBy": "admin",
      "createdAt": "2026-09-03T09:30:00"
    }
  ],
  "ingredientStockMovements": [
    {
      "id": "mov-insumo-001",
      "type": "ENTRY",
      "occurredAt": "2026-09-03T00:00:00",
      "ingredientId": "milho",
      "ingredientLotId": "lote-milho-001",
      "quantityKg": 600,
      "pricePerKgCentsSnapshot": 120,
      "totalCostCents": 72000,
      "createdBy": "admin",
      "createdAt": "2026-09-03T09:30:00"
    }
  ],
  "calendarEvents": [
    {
      "id": "alerta-001",
      "title": "Tratar aves",
      "type": "FEED",
      "startsAt": "2026-09-03T00:00:00",
      "lotId": "lote-001",
      "notes": "Alimentacao da manha",
      "alertEnabled": true,
      "alertMessage": "Hora de tratar as aves",
      "alertTime": "10:30",
      "recurrence": "DAILY",
      "repeatUntil": "2026-09-30T23:59:00",
      "weekdays": null,
      "createdBy": "admin",
      "createdAt": "2026-09-03T09:30:00"
    }
  ],
  "appSettings": [
    {
      "key": "production_feed_grams_per_bird",
      "value": "115",
      "updatedAt": "2026-09-03T09:30:00",
      "updatedBy": "admin"
    }
  ]
}
```

