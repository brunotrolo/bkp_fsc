# Build Report — `household-360/001-visao-360-cliente` — Visão 360° do cliente Porto Bank

| Campo | Valor |
|---|---|
| **Domínio / Capacidade** | `household-360` / `001-visao-360-cliente` |
| **Status** | **CONSTRUÍDO E DEPLOYADO — GATE VERDE** em 2026-09-08 |
| **Org alvo** | `FSC` (`00DWs00000SxIGvMAN`, `bruno.rolo_vtnf7bhgdb@portobank.com.br`) |
| **Gate de entrada** | Gate VIII APROVADO pelo dono em 2026-09-08 (vale como `pronto para build`; `BACKLOG.md` não existe neste repo — gap G-01) |
| **Modo** | **Mock-first desde o dia 1** (motor NBO e core fora do ar; flag própria `Visao360Mock__c`, default OFF) |

> Decisões do dono (2026-09-08) aplicadas como autoridade máxima; onde conflitam com `plan.md`/`tasks.md`/`architecture.md`, a decisão do dono prevaleceu e o desvio está registrado em §6.

---

## 1. O que foi construído (145 arquivos, só em `force-app/domains/household-360/main/default/`)

### fsc-data-model-developer (T-A01, T-A02, T-A04, T-B01, T-C05)
- `objects/Visao360Mock__c/` — Hierarchy Custom Setting **própria do domínio** + `fields/UsarMock__c` (default OFF). Nunca lê `BuscaClienteMock__c`.
- `objects/Account/fields/` (5, novos, deste domínio): `CustomerSince__c` (Date), `MaritalStatus__c` (picklist + formas femininas), `CreditRating__c` (Number 4,0), `ProfileCompleteness__c` (Percent), `FamilySize__c` (Number 2,0). Reuso por leitura (sem redefinir): `Document__c`, `DocumentType__c`, `CustomerSegment__c` (da busca).
- `objects/Opportunity/fields/` (7, novos): `Propensity_Score__c`, `Confidence__c` (Alta/Media/Baixa — valor API ASCII, exibição mapeada no LWC), `OmniScript_Key__c`, `ExpirationDate__c`, `Loss_Reason__c`, `Offer_Safra__c`, `Offer_Reasons__c` (LongText 4000). Reuso por leitura: `ExternalOfferId__c` (chave de idempotência `{doc}_{cod}_{periodo}`).
- `messageChannels/PortoBank360Channel__c` — LMS **interno** (`assetId`, `contractNumber`, `productFamily`, `status`; evento `ASSET_SELECTED`). Nunca assina `CustomerInteractionChannel__c`.
- `permissionsets/PS_Visao360_Operador` — Read Account/Contact/Asset/Case/AccountContactRelation, Create+Edit Opportunity, FLS dos 12 campos novos + campos reusados consultados, 9 classAccesses, principal `EC_Visao360_Barramento-Visao360_Principal`. **Criado, deployado e atribuído ao usuário corrente** (gate fase 6, evidência §4).

### fsc-integration-developer (T-C01)
- `externalCredentials/EC_Visao360_Barramento` (OAuth2 client-credentials, principal próprio `Visao360_Principal`; segredo via Setup) + `namedCredentials/NC_Visao360_Nbo` (`/nbo/elegibilidade/{doc}`, 3,0s) e `NC_Visao360_Core` (`/ativos/{contrato}/realtime`, 3,0s). Nomes próprios para não colidir nem acoplar deploy com os NCs da busca. Sem chamada real (mock-first).

### fsc-apex-developer (T-C02–C04, T-C06, T-F01) — 9 classes + factory + 8 testes
- `Visao360DTOs` (ApiFaultDTO, AssetSummary/Realtime, NBOOffer com `Comparable` score-desc, Header, Evento/Wellness/Planejamento/Fluxo/Segmentação/Comportamento/Campanha/Meta/Tarefa/Interação/Ação/Caso/ArcNode + resultados compostos). **Volátil só em DTOs de memória (RN-04)**.
- `Visao360HttpService` (GET/POST via NC, fault tipada em vez de exceção — padrão copiado, não importado).
- `Visao360Mock` (espelho fiel de `prototype/data/visao360/visao360.js`: 4 docs demo, NBO estático, Carlos só-banner-até-retry, consórcio falha-1x-até-retry, visão rica do João; **zero DML**).
- `Visao360AssetService` (inventário por `ProductType__c`, detalhe volátil sob demanda, retry explícito, sem DML).
- `Visao360NBOService` (top 3 imediato + `NBOSync` em 2º plano; `rejectOffer`/`acceptOffer`; RN-12 sem último estado).
- `Visao360SyncQueueable` (upsert idempotente por `ExternalOfferId__c`; expira safra antiga com motivo; ausente-mas-válida mantida) + `Visao360RejectQueueable` (Closed Lost + motivo + feedback melhor-esforço).
- `Visao360CustomerService` (visão consolidada em ≤3 SOQL, sem N+1, vazios discretos EL-08/EL-09).
- `Visao360Controller` (fachada `@AuraEnabled`; falha parcial vira fault no DTO, exceção só para entrada inválida).
- `Visao360TestFactory` + 8 classes de teste (positivo/negativo/bulk 251+/callout-mock/async; padrão `runAs(agente)` + setup-fora/runAs-dentro contra MIXED_DML, documentado em §5).

### fsc-lwc-developer (T-D01, T-D03–D11 exceto página; cobre desvio OmniStudio §6) — 21 componentes 1:1 de `prototype/ui/` + `page/`
`visao360Shell` (recordId, 6 subabas, sidebar fixa NBO+Tags, troca de raiz volta ao Resumo) · `visao360Header` · `visao360Resumo` · `visao360Eventos` · `visao360Wellness` · `visao360Planejamento` · `visao360ContasResumo` · `visao360Ativos` (**publica** `ASSET_SELECTED` no LMS) · `visao360AtivoDetalhe` (**assina** o LMS; sub-abas paralelas máx. 2; cache client 180s em memória; retry explícito) · `visao360Metas` (donut SVG) · `visao360Nbo` (top 3, selo Melhor ação, recusa 1-clique, reserva RN-14) · `visao360Tags` (busca/filtro/remoção locais, sem Apex) · `visao360Fluxo` + `visao360Segmentacao` (SVG próprio) · `visao360Inteligencia` (acordeões + tabelas) · `visao360Arc` + `visao360ArcModal` (`lightning/modal` full, troca de raiz RN-11) · `visao360ProximaAcao` · `visao360Tarefas` · `visao360Atividades` (filtros/paginação) · `visao360Historico` (tabela 9 colunas). Filhos presentacionais (`@api` in/eventos out); correções pós-protótipo: guards `lwc:if` anti-null em shell/wellness/planejamento.

### fsc-omnistudio-developer (T-D03–D05, T-D07–D10 parcial)
**Desvio registrado (decisão do dono, item 4):** runtime OmniStudio EXISTE na org (`OmniUiCard`/`OmniProcess`/`OmniProcessElement` confirmados via EntityDefinition), mas FlexCards não foram materializados — a skill exige Integration Procedures ativas como data source e o dono proibiu IP/DataMapper ("fronteira do projeto"); FlexCard rico hand-authored em JSON, sem Designer para validar, arriscaria widget morto na página de validação, violando o critério supremo do dono (navegabilidade > fidelidade de tecnologia). Os blocos `porto*` foram implementados como LWC 1:1 (nomenclatura `visao360*`). Gap G-02: FlexCards pendentes até IPs liberados.

### fsc-declarative-developer (T-D02 parcial, T-D11 adaptado)
- `flexipages/Visao360Cliente` (Account RecordPage, template `recordHomeTemplateDesktop`, bootstrap via `sf template generate flexipage`): aba "Visão 360°" (ativa, `c:visao360Shell`) + Details/Related/Activities padrão. **Atribuída no app Porto Bank** via `actionOverrides` (Account/View/Large) — deploy `0AfWs00001c2nHZKAY`. Desvio §6 (G-04): `profileActionOverrides` na página é rejeitado pelo parser da org (reproduzido até na página padrão da org).
- ARC nativo/Compact Layout `Account_360_Header`: não materializados (sem superfície de metadados acessível aqui); cobertos pelo `visao360Arc` 1:1 + header dinâmico padrão da página (gap G-08).

### fsc-automation-developer
**Pulado com justificativa:** `plan.md`/`tasks.md` não pedem nenhum Flow para esta capacidade (NBO usa Queueable, resto é leitura). Nenhum `flows/` criado.

---

## 2. Seed + cenários de validação (decisão do dono, item 2)

`scripts/seed-household-360.apex` (versionado; `sf apex run -f`): idempotente por `Document__c`/`ExternalContractId__c`/`ExternalOfferId__c` — **S1** João PF (conta + 8 ativos + 3 opps safra 2026-09 + 5 casos + ACR cônjuge), **S2** Indústria PJ (conta + 2 ativos + ACR sócio-administrador), **S3** Maria (conta + 1 ativo) + Carlos (conta + 1 ativo). Commitado: 4 contas, 2 contatos, 11 ativos, 3 ofertas, 5 casos. Nota: script roda em transação única — falha parcial faz rollback total; rerun é seguro. Exceção pontual em §6 (G-05).

## 3. Acoplamento (decisão do dono, itens 3 e 5)

- **Zero arquivos** de `force-app/domains/busca-cliente/` (ou da FlexiPage BuscarCliente) criados/editados/movidos; `sfdx-project.json` ganhou só o package dir `household-360`. Grep confirma: nenhuma importação de classe/LWC/canal da busca (só menções em comentários/descrições).
- Reuso só como **inspiração copiada** (DTO fault, HttpService, mock por CS, `enqueueUpsert` guard, factory de agente): `Account.Document__c`, `Asset.*`, `Opportunity.*`, NC/EC como molde.
- **Dependência reversa REGISTRADA, não implementada (gap G-09):** tornar o nome clicável no cartão da `busca-cliente/001` navegando para esta página.

---

## 4. Evidências do `fsc-deploy-gate` (tudo com comando + exit + artefato)

| Fase | Comando | Resultado |
|---|---|---|
| 1. Scan | `sf code-analyzer run --rule-selector Recommended --target force-app/domains/household-360` | **0 High/Critical** (561 violações Moderadas/Baixas/Info; as 3 High iniciais — 2× `no-unused-vars`, 1× `EmptyCatchBlock` — corrigidas; rescan em `code-analyzer-results-household360-rescan.json`) |
| 2. Dry-run | `sf project deploy start --dry-run --source-dir …/household-360/main/default --target-org FSC --test-level RunLocalTests` | **status Succeeded**, 0 erros de componente, **200/200 testes** — job **`0AfWs00001c2qvNKAQ`** |
| 3. Deploy real | `sf project deploy quick --job-id 0AfWs00001c2qvNKAQ` | **Succeeded, 59 componentes** — job **`0AfWs00001c2rBVKAY`** (+ app assignment job `0AfWs00001c2nHZKAY`) |
| 4. Testes Apex | `sf apex run test --test-level RunLocalTests --code-coverage` | **200/200 (100%)** — testRunId **`707Ws00001XLTll`**; org-wide **81%**; por classe 77–93% (min `Visao360Mock` 77%, `Visao360RejectQueueable` 79%; demais ≥81%) |
| 5. LWC | `sfdx-lwc-jest force-app/domains/household-360` | **5 suites / 14 testes verdes**; SLDS linter **0 erros** (335 warnings = padrão visual do protótipo, com hooks+fallbacks); LWS: zero sinks perigosos (`innerHTML`/`eval`/`window`/etc. — grep limpo); a11y: papéis/`aria-label`/`alternative-text` preservados do protótipo + guards anti-null |
| 6. Acesso | `sf org assign permset --name PS_Visao360_Operador` | Atribuído a `bruno.rolo_vtnf7bhgdb@portobank.com.br` (success, 0 failures) |
| 7. Smoke | `sf apex run -f` (flag mock ON no nível org, `MOCK ENABLED=true`) | **SMOKE_OK**: S1 (header João, 7 interações, 5 casos, arc 5, 8 ativos, NBO 3 BLACK-top safra 2026-09, retry fail→`R$ 212.400,00`, recusa ok) · S2 (PJ esparsa, 0 metas, arc 5, `resolveAccount` true) · S3 (Maria 0 NBO sem fault; Carlos banner→retry 2) |

Falhas encontradas no caminho e resolvidas (diagnóstico `diagnosing-bugs` aplicado, nenhuma varrida para baixo do tapete): descriptions >255 em EC/NC/PS; RecordTypes no objeto Asset padrão (sem suporte — removidos, família via `ProductType__c`); `profileActionOverrides` rejeitado (3 posições + reproduzido na página padrão); `WITH USER_MODE` exige `runAs(agente)` com FLS; `AuraHandledException.getMessage()` não expõe texto em testes (padrão booleano da busca); `Confidence__c` API `Media` vs label `Média`; `Test.startTest` único por método; **MIXED_DML**: matriz de probes provou que DML não-setup pós-User exige `runAs` e que insert de Custom Setting conta como non-setup (ordem final: agente fora → CS+dados+dentro do `runAs`); `CustomerSegment__c` restrito (valores API); quirk `sf data query` com espaços via shim `.cmd` (usar `--file`).

---

## 5. Padrões de teste que viraram regra do domínio

1. Todo teste com DML: `novoAgente()` fora; **todo o resto dentro** de `System.runAs(agente)` (inclui `ligarMock()`, dados, `startTest/stopTest`, asserts).
2. `Test.startTest()` uma única vez por método (2ª passagem via `.execute(null)` direto).
3. Erro de controller em teste: flag booleana (nunca `getMessage()` de `AuraHandledException`).
4. Mock-first: com a flag ON, nenhum teste cria Opportunity/Case/Asset além do seed (asserts de contagem provam).

## 6. Gaps e desvios (ambiguidade virou gap, não chute)

| # | Item | Tipo | Situação |
|---|---|---|---|
| G-01 | `BACKLOG.md`/`docs/sdd/` não existem no repo | gap | Status `construído e deployado` não registrado; vale este report + gate VIII do dono |
| G-02 | FlexCards `porto*` como registros OmniStudio | desvio/decisão | LWC 1:1; FlexCards pendentes até IPs liberados (ver §1) |
| G-03 | RecordTypes `CreditCard/DigitalAccount/Consortium/Investment` em `Asset` (T-A01) | desvio técnico | Objeto padrão sem suporte a RT; família via `ProductType__c` |
| G-04 | `profileActionOverrides` na FlexiPage | desvio técnico | Parser da org rejeita (reproduzido na página padrão); assignment via app `Porto_Bank` deployado; snippet em `tmpref` descartado após deploy (reproduzível) |
| G-05 | Valores novos de `MaritalStatus__c` (Solteira/Casada/…) rejeitados no DML | gap plataforma | Metadado + describe OK e ativos, RTs sem escopo, mas DML valida conjunto antigo (reproduzido isolado; originais passam). `Maria.MaritalStatus__c` ficou em branco; seed mantém o valor correto para backfill futuro |
| G-06 | `CustomerSegment__c`: seed/factory usam valores API (`EXCLUSIVO/CORPORATE/VAREJO`); UI real exibe API, protótipo exibia labels | gap cosmético | Mapa label↔API futuro (mesmo padrão do `Confidence Media→Média` já aplicado no NBO) |
| G-07 | OWD `Private` re-derivado (T-B01) | config de org | Não é metadado deployável; não alterado — validar na fundação |
| G-08 | ARC nativo + Compact Layout `Account_360_Header` + `ProductCatalog__mdt` próprio | gap | Cobertos por LWC 1:1 / highlights da página / constantes por família (RN-03); sem MDT próprio para não duplicar catálogo da busca |
| G-09 | Nome clicável na busca → esta página | pendência reversa | Registrada, não implementada (proibido tocar na busca) |
| G-10 | Premissa 05 da spec (fontes KYC/fraude) | pergunta aberta herdada | Placeholder `alerta: null` mantido; sem regra inventada |
| G-11 | Stage `Identified` do plano → `Prospecting` padrão | detalhe | Stage padrão inexistente na org; mapeamento documentado |
| — | `fsc-automation-developer` pulado | justificativa | Plano não pede Flow (§1) |

## 7. Como validar (navegável fim a fim)

1. Atribuir-se o PS (já atribuído ao usuário corrente) e garantir `Visao360Mock__c` org = true (já ligado).
2. (Re)rodar `sf apex run -f scripts/seed-household-360.apex -o FSC` (idempotente).
3. Abrir no app **Porto Bank** qualquer Account com `Document__c` em (`12345678900`, `12ABC345000190`, `11111111111`, `99999999999`) — a Record Page `Visao360Cliente` abre com header 3 col, 6 subabas e sidebar NBO+Tags.
4. Roteiro: trocar subabas (sidebar persiste) → Financial Accounts → selecionar Consórcio Imóvel (banner+retry) → sidebar NBO (recusar com motivo / contratar) → Relacionamentos → "Ver árvore completa" → trocar raiz p/ Indústria (volta ao Resumo) → Maria (vazios) → Carlos (banner+retry).

*Fim de `build-report.md` — `household-360/001` (gate verde em 2026-09-08; nada declarado pronto sem evidência).*
