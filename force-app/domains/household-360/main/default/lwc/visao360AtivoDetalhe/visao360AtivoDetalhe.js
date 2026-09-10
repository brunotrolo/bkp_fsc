import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import getRealtime from '@salesforce/apex/Visao360Controller.getRealtime';
import PORTO_BANK_360_CHANNEL from '@salesforce/messageChannel/PortoBank360Channel__c';

const CACHE_TTL_MS = 180 * 1000;
const MAX_ABAS = 2;

/**
 * Detalhe volátil do ativo — dono de P5 (apresentação + busca sob demanda).
 * Assina ASSET_SELECTED no PortoBank360Channel__c (contrato interno do
 * domínio): cada seleção abre sub-aba paralela (máx. 2, Cen 16/RN-10).
 * Cache client-side 180s em memória (Cen 8); retry explícito (Cen 9);
 * falha parcial = banner + leitura reduzida, resto navegável (RN-07).
 * Volátil nunca persiste (RN-04): só memória + DTOs.
 */
export default class Visao360AtivoDetalhe extends LightningElement {
    abasDetalhe = [];
    abaDetalheAtivaId = null;

    cache = new Map();
    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        if (this.messageContext) {
            this.subscribe();
        }
    }

    renderedCallback() {
        if (!this.subscription && this.messageContext) {
            this.subscribe();
        }
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    subscribe() {
        this.subscription = subscribe(
            this.messageContext,
            PORTO_BANK_360_CHANNEL,
            (message) => this.aoMensagemAtivo(message),
            { scope: APPLICATION_SCOPE }
        );
    }

    get temDetalhes() {
        return this.abasDetalhe.length > 0;
    }

    get tamanhoPainelDetalhe() {
        return this.abasDetalhe.length > 1
            ? 'slds-col slds-size_1-of-1 slds-large-size_1-of-2'
            : 'slds-col slds-size_1-of-1';
    }

    get mostrarPlaceholder() {
        return this.abasDetalhe.length === 0;
    }

    aoMensagemAtivo(message) {
        const contractNumber = message?.contractNumber;
        if (!contractNumber) return;
        const chave = `${message.productFamily}:${contractNumber}`;
        const aberta = this.abasDetalhe.find((a) => a.chave === chave);
        if (aberta) {
            this.abaDetalheAtivaId = aberta.chave;
            this._sincronizarAbaAtiva();
            return;
        }
        const proxima = [
            ...this.abasDetalhe,
            {
                chave,
                contractNumber,
                productFamily: message.productFamily,
                status: message.status,
                rotulo: `${message.productFamily} • ${contractNumber}`,
                detalhe: null,
                horaAtualizacao: '',
                carregando: true,
                erro: null,
                ativa: true,
                classeAba: ''
            }
        ];
        while (proxima.length > MAX_ABAS) proxima.shift();
        this.abasDetalhe = proxima;
        this.abaDetalheAtivaId = chave;
        this._sincronizarAbaAtiva();
        this._carregarDetalhe(chave, false);
    }

    aoFocarDetalhe(event) {
        const chave = event.currentTarget?.dataset?.id;
        if (!chave) return;
        this.abaDetalheAtivaId = chave;
        this._sincronizarAbaAtiva();
    }

    aoFecharDetalhe(event) {
        const chave = event.currentTarget?.dataset?.id;
        if (!chave) return;
        this.abasDetalhe = this.abasDetalhe.filter((a) => a.chave !== chave);
        if (this.abaDetalheAtivaId === chave) {
            this.abaDetalheAtivaId = this.abasDetalhe.length
                ? this.abasDetalhe[this.abasDetalhe.length - 1].chave
                : null;
        }
        this._sincronizarAbaAtiva();
    }

    aoRecarregarDetalhe(event) {
        const chave = event.currentTarget?.dataset?.id;
        if (chave) this._carregarDetalhe(chave, true);
    }

    _sincronizarAbaAtiva() {
        this.abasDetalhe = this.abasDetalhe.map((a) => ({
            ...a,
            ativa: a.chave === this.abaDetalheAtivaId,
            classeAba:
                a.chave === this.abaDetalheAtivaId
                    ? 'slds-tabs_scoped__item slds-is-active c-subaba-cab'
                    : 'slds-tabs_scoped__item c-subaba-cab'
        }));
    }

    _carregarDetalhe(chave, forcar) {
        const aba = this.abasDetalhe.find((a) => a.chave === chave);
        if (!aba) return;
        if (!forcar) {
            const emCache = this.cache.get(chave);
            if (emCache && Date.now() - emCache.ts < CACHE_TTL_MS) {
                this._aplicarDetalhe(chave, { ...emCache.dados, doCache: true });
                return;
            }
        }
        this._marcarCarregando(chave);
        getRealtime({ contractNumber: aba.contractNumber, family: aba.productFamily, retry: forcar })
            .then((result) => {
                if (result?.fault) {
                    this._aplicarErro(chave, result.fault.message);
                    return;
                }
                const dados = result?.detail;
                if (dados) {
                    this.cache.set(chave, { dados, ts: Date.now() });
                }
                this._aplicarDetalhe(chave, { ...dados, doCache: false });
            })
            .catch((e) => {
                const mensagem =
                    e?.body?.message ?? 'Falha ao consultar o core bancário.';
                this._aplicarErro(chave, mensagem);
            });
    }

    _marcarCarregando(chave) {
        this.abasDetalhe = this.abasDetalhe.map((a) =>
            a.chave === chave ? { ...a, carregando: true, erro: null } : a
        );
    }

    _aplicarDetalhe(chave, dados) {
        this.abasDetalhe = this.abasDetalhe.map((a) =>
            a.chave === chave
                ? {
                      ...a,
                      detalhe: dados,
                      horaAtualizacao: this._formatarHora(new Date()),
                      carregando: false,
                      erro: null
                  }
                : a
        );
    }

    _aplicarErro(chave, mensagem) {
        this.abasDetalhe = this.abasDetalhe.map((a) =>
            a.chave === chave ? { ...a, carregando: false, erro: mensagem } : a
        );
    }

    _formatarHora(data) {
        try {
            return data.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
        } catch {
            return '';
        }
    }

    get abasApresentacao() {
        return this.abasDetalhe.map((a) => ({
            ...a,
            mostrarCarregando: a.carregando === true,
            mostrarErro: a.carregando !== true && Boolean(a.erro),
            mostrarDetalhe: a.carregando !== true && !a.erro && a.detalhe !== null,
            ehCartao: a.detalhe?.tipo === 'CARTAO',
            ehConta: a.detalhe?.tipo === 'CONTA',
            ehConsorcio: a.detalhe?.tipo === 'CONSORCIO',
            ehInvest: a.detalhe?.tipo === 'INVEST',
            veioDoCache: a.detalhe?.doCache === true
        }));
    }
}
