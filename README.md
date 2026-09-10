# bkp_fsc — Backup 100% FSC (2026-09-09)

Backup completo do projeto **Salesforce Journey Developer / FSC** (`00DWs00000SxIGvMAN` / `bruno.rolo_vtnf7bhgdb@portobank.com.br`) — inclui código, FlexCard `visaoHeader360`, `Visao360FlexCardDS` e diagnóstico de `lightning-formatted-rich-text`.

## O que está aqui (100%)

```
bkp_fsc/
├── force-app/                          # código fonte completo (household-360 + busca-cliente)
│   └── domains/household-360/main/default/
│       ├── classes/Visao360FlexCardDS.cls   # DataSource Apex Remote (Callable) — versão repo-atual SEM try/catch
│       ├── omniui/visaoHeader360/visaoHeader360.flexcard  # versão ATIVA no org (style= inline, 19513 bytes)
│       └── lwc/visao360Header/             # LWC de referência (header idêntico alvo)
├── config/ .claude/ specs/ manifest/ scripts/  # configuração do projeto
├── sfdx-project.json / package.json / jest.config.js
├── README_FSC.md                       # README original do FSC
└── docs/sessao-2026-09-09-visaoHeader360/  # export da sessão (Claude Code + testes manuais)
    ├── CONTEXTO.md                     # fatos vs hipóteses, estratégia SLDS, runtime Vlocity
    ├── visaoHeader360.claude.flexcard  # versão Claude Code — SLDS-only (sem style=), 14KB
    ├── Visao360FlexCardDS.cls.claude   # versão Claude Code COM try/catch em getVisao()
    ├── visaoHeader360_identical_psc.json # SLDS + globalCSS idêntico ao LWC (15685 bytes, quebrou)
    ├── rollback_v6_psc.json            # backup do OmniUiCard 0koWs000000UvqTIAS deletado (style= inline, 19513)
    ├── visaoHeader360.repo-atual.flexcard # snapshot do repo após último rollback (style= inline, 38KB pretty)
    └── Visao360FlexCardDS.repo-atual.cls  # snapshot DS sem try/catch
```

**Org:** alias `FSC`, `https://portoseguro3.my.salesforce.com`, `Enterprise Edition`, `API 68.0`. FlexCard `visaoHeader360` está em `OmniUiCard 0koWs000000UvX7IAK v5.0 IsActive=true` (único ativo; v6 `0koWs000000UvqTIAS` deletado mas salvo em `rollback_v6_psc.json` e recuperável via `queryAll`).

## Fato provado no org (DevTools)

`lightning-formatted-rich-text` sanitiza o HTML do `mergeField`: a tag sobrevive, o conteúdo também, mas `style="..."` é cortado. É LWS, não bug de encoding. `class=`, `<style>` e `globalCSS`/`state.css` ainda são hipóteses (testado 5x, sem prova isolada completa) — por isso `visaoHeader360.claude.flexcard` usa só SLDS (`slds-badge`, `slds-avatar`, `slds-text-title` etc.) que já vem carregado globalmente.

Prova prática: `styleObject.style` no wrapper `data-style-id` funciona e cascateia para o texto interno — teste `nome` azul `font-size:20px;color:#032d60` em `visaoHeader360.flexcard:130` (`block0.el1` `style="font-size:20px;font-weight:400;color:#032d60"`) validado em `Ctrl+Shift+R` → `Elements` → `state0element0block_element1` com `style=`.

## Como abrir em outro PC

### Pré-requisitos

- Node 20+, `npm`, `git`, `sf` CLI 2.x, `Python 3.10+`

### 1) Clonar e instalar

```bash
git clone https://github.com/brunotrolo/bkp_fsc.git
cd bkp_fsc
npm install
```

### 2) Autenticar no org FSC

```bash
sf org login web --alias FSC --instance-url https://portoseguro3.my.salesforce.com
# ou com SFDX auth url:
# sf org login sfdx-url --sfdx-url-file <arquivo> --alias FSC
sf org display --target-org FSC --verbose
sf config set target-org=FSC
```

### 3) Deploy Apex (único que vai via metadata)

```bash
# DS atual (sem try/catch) — para versão COM try/catch use docs/.../Visao360FlexCardDS.cls.claude
sf project deploy start --source-dir force-app/domains/household-360/main/default/classes/Visao360FlexCardDS.cls --target-org FSC --ignore-warnings

# ou projeto completo:
sf project deploy start --source-dir force-app --target-org FSC --ignore-warnings
```

### 4) Deploy FlexCard (NÃO vai via `sf project deploy` — Vlocity)

O org usa **Vlocity managed package** (não Standard Runtime). `sf project retrieve -m OmniUiCard` retorna vazio. Deploy é via **REST PATCH** em `OmniUiCard`:

```bash
# Linux/macOS/Git Bash (Windows ajuste aspas):
python3 - << 'PY'
import pathlib, json, subprocess, urllib.request, urllib.parse

def sf_json(args):
    import subprocess, json
    r = subprocess.run(["sf"] + args + ["--json"], capture_output=True, text=True, shell=True)
    txt = r.stdout
    txt = txt[txt.find("{"):]
    return json.loads(txt)

iu = sf_json(["org","display","--target-org","FSC","--verbose"])["result"]["instanceUrl"]
at = sf_json(["org","auth","show-access-token","--target-org","FSC"])["result"]["accessToken"]

# escolha o arquivo que quer publicar:
psc_str = pathlib.Path("force-app/domains/household-360/main/default/omniui/visaoHeader360/visaoHeader360.flexcard").read_text(encoding="utf-8")
# ou: docs/sessao-2026-09-09-visaoHeader360/visaoHeader360.claude.flexcard
# ou: docs/sessao-2026-09-09-visaoHeader360/visaoHeader360_identical_psc.json
# ou: docs/sessao-2026-09-09-visaoHeader360/rollback_v6_psc.json

import json
psc_json = json.loads(psc_str)
psc_str = json.dumps(psc_json)  # normaliza

active_id = "0koWs000000UvX7IAK"
url = f"{iu}/services/data/v68.0/sobjects/OmniUiCard/{active_id}"
h = {"Authorization": f"Bearer {at}", "Content-Type": "application/json"}
# desativa → patch → reativa
import urllib.request
urllib.request.urlopen(urllib.request.Request(url, data=json.dumps({"IsActive": False}).encode(), method="PATCH", headers=h), timeout=20)
urllib.request.urlopen(urllib.request.Request(url, data=json.dumps({"PropertySetConfig": psc_str, "IsActive": True}).encode(), method="PATCH", headers=h), timeout=20)
print("FlexCard deploy OK", active_id)

# verifique: sf data query não funciona bem no Windows — use REST queryAll se precisar de deletados
PY
```

**Windows PowerShell (mesmo script, salve como `deploy_flex.py` e rode `python deploy_flex.py`):** idem acima.

### 5) Validar

```bash
sf apex run test --target-org FSC --test-level RunLocalTests --wait 10
# esperado: 201 passing, 0 failing

# FlexCard: abra a Record Page Visao360Cliente, Ctrl+Shift+R, Elements → buscar state0element0block_element1 e conferir style/class
```

### 6) Teste isolado `styleObject` (nome azul)

Para validar um campo antes de aplicar em todos (prova que funciona):

```bash
python3 - << 'PY'
import pathlib, json, subprocess, urllib.request, urllib.parse
def sf_json(a):
    import subprocess, json
    r = subprocess.run(["sf"]+a+["--json"], capture_output=True, text=True, shell=True)
    return json.loads(r.stdout[r.stdout.find("{"):])
iu = sf_json(["org","display","--target-org","FSC","--verbose"])["result"]["instanceUrl"]
at = sf_json(["org","auth","show-access-token","--target-org","FSC"])["result"]["accessToken"]
url = f"{iu}/services/data/v68.0/sobjects/OmniUiCard/0koWs000000UvX7IAK"
h = {"Authorization": f"Bearer {at}", "Content-Type": "application/json"}
import urllib.request, json, pathlib
psc = json.loads(json.loads(urllib.request.urlopen(urllib.request.Request(url, headers={"Authorization": f"Bearer {at}"})).read().decode())["PropertySetConfig"])
el = psc["states"][0]["components"]["layer-0"]["children"][0]["children"][1]
el["styleObject"]["style"] = "font-size:20px;font-weight:400;color:#032d60;margin:2px 0 8px 0"
el["property"]["mergeField"] = urllib.parse.quote("{nome}")
# PATCH
import json as js
s = js.dumps(psc)
urllib.request.urlopen(urllib.request.Request(url, data=js.dumps({"IsActive": False}).encode(), method="PATCH", headers=h))
urllib.request.urlopen(urllib.request.Request(url, data=js.dumps({"PropertySetConfig": s, "IsActive": True}).encode(), method="PATCH", headers=h))
print("campo nome azul aplicado")
PY
```

## Comandos rápidos (copiar e colar no outro PC)

```bash
git clone https://github.com/brunotrolo/bkp_fsc.git && cd bkp_fsc && npm install && sf org login web --alias FSC && sf project deploy start --source-dir force-app --target-org FSC --ignore-warnings && sf apex run test --target-org FSC --test-level RunLocalTests --wait 10
```

## Diferenças entre versões

| Versão | Arquivo | `mergeField` | `globalCSS`/`state.css` | DS `try/catch` |
|---|---|---|---|---|
| repo-atual (ativa no org) | `visaoHeader360.repo-atual.flexcard` / `rollback_v6_psc.json` | `<div style="...">` (será cortado) | `""` | não |
| claude SLDS | `visaoHeader360.claude.flexcard` | `<p class="slds-text-title">` etc. | `""` | sim |
| identical (quebrou) | `visaoHeader360_identical_psc.json` | idem SLDS | `1342` bytes com overrides `#f5a623` `#1f9e6e` etc. | sim |

---
Gerado em 2026-09-09 a partir da sessão `opencode` + `Claude Code` — para retomar, copie `docs/sessao-2026-09-09-visaoHeader360/CONTEXTO.md` para o novo agente.
