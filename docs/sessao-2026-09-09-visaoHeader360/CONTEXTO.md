# Contexto — visaoHeader360 (FlexCard + Apex Remote)

## Runtime do org
Vlocity managed package (NÃO Standard Runtime). `sf project retrieve start -m
OmniUiCard` não funciona neste org — deploy é via REST API PATCH em
`/services/data/v68.0/sobjects/OmniUiCard/{id}`, autenticando com
`sf org auth show-access-token`. O contrato de Apex Remote correto para essa
instalação é `System.Callable` (não `VlocityOpenInterface2`).

## Fatos provados vs. hipóteses (separado por rigor de evidência)

**Provado por inspeção DOM real, no org:**
- `<lightning-formatted-rich-text>` remove o atributo `style="..."` de
  qualquer HTML que chegue via `mergeField`. A tag e a estrutura sobrevivem;
  só `style=` é cortado. É comportamento do Lightning Web Security (LWS),
  não um bug de encoding.

**Ainda NÃO confirmado com o mesmo rigor** (reivindicações do opencode que
mudaram de explicação três vezes sem prova isolada — tratar com ceticismo até
alguém rodar o teste real no org):
- Se `class="..."` também é removido.
- Se uma tag `<style>` solta dentro do mergeField é removida.
- Se `globalCSS` (campo raiz do PropertySetConfig) não é aplicado.
- Se `state.css` (campo de nível de state, diferente de `globalCSS`) não é
  aplicado — o arquivo anterior (`visaoHeader360-atual.flexcard`) usava esse
  campo para as classes `c-hdr-*`, e ele foi removido nesta correção porque,
  mesmo que funcionasse, são classes customizadas fora do padrão SLDS.

## Estratégia adotada nesta correção

Em vez de brigar com o sanitizer (tentando `class=` custom + CSS externo,
cujo funcionamento é incerto), o `visaoHeader360.flexcard` corrigido usa
**apenas classes utilitárias nativas do SLDS** (`slds-badge`,
`slds-avatar`/`slds-avatar__initials`, `slds-text-title`,
`slds-text-heading_small`, `slds-text-title_caps` + `slds-border_bottom`,
`slds-text-color_success`, `<strong>` puro). A tese é que o CSS dessas
classes já vem carregado globalmente pela plataforma (é o mesmo SLDS que
styleObject/App Builder usam) e não depende de nenhum dos canais de injeção
de CSS customizado listados acima como incertos — então o resultado não fica
refém da resposta ainda pendente sobre `class=`/`<style>`/`globalCSS`.

**Isso ainda precisa ser confirmado no org real.** Local, o `.flexcard`
corrigido foi validado assim:
1. JSON bem formado.
2. Todos os 21 `mergeField` decodificam para HTML válido, sem sobra de
   `style=` ou das classes antigas `c-hdr-*`.
3. Todo campo usado no mergeField (`{campo}`) existe no mapa que
   `Visao360FlexCardDS.buildHeader` retorna — nenhum campo órfão.
4. Renderização visual (mock local, dados de exemplo) confere com o layout
   de 3 colunas do LWC (`lwc-header.html`): pessoa/nome/selos + autenticação
   | resumo do perfil | responsável + necessidades.

Se no org o teste mostrar que `class=` também é cortado, essas classes SLDS
não vão pintar e o card volta a ficar "cru" — nesse caso a saída é abandonar
mergeField para estilização e usar blocos/elementos nativos do FlexCard
(`styleObject` por elemento, que é processado pelo motor de layout do card,
não pelo sanitizer de conteúdo) para tudo que hoje depende de classe dentro
do HTML.

## Correções aplicadas nesta rodada

1. **`visaoHeader360-atual.flexcard` → `visaoHeader360.flexcard`**: troca de
   `c-hdr-*` + `state.css` por classes SLDS nativas; remoção do `style=`
   inline que sobrava no espaçador da coluna 2 (substituído por
   `styleObject.padding` no próprio elemento, que não passa pelo sanitizer
   de mergeField); restauração do `xmlObject.targetConfigs` (estava ausente
   — regressão que tirava `recordId`/`debug` do App Builder); remoção de um
   `<a href="javascript:void(0);">` sem função real no nome do responsável
   (trocado por `<span>`, igual ao LWC).
2. **`Visao360FlexCardDS.cls`**: `Visao360Controller.getVisao(raiz)` agora
   está dentro de um `try/catch` — antes, uma exceção ali propagava sem
   tratamento e quebrava o card inteiro em vez de cair no fallback `vazio`
   já existente para "conta não encontrada".

## Pendente (precisa do org ou do opencode para fechar)

- Rodar os 4 testes isolados (SLDS carrega globalmente / classe SLDS sozinha
  no mergeField / `<style>` sozinho / `<style>` em `state.styleObject`) para
  virar "hipótese" em "fato provado ou descartado".
- Confirmar visualmente no org que o `.flexcard` corrigido bate com o
  screenshot do LWC.
- `lwc-header.js`/`.html` têm gaps conhecidos e não tocados nesta rodada
  (sem estado de loading, fault engolido silenciosamente, sem teste de
  fault/loading) — fora do escopo deste pedido, mas registrados para quando
  o usuário quiser endereçar.
