import { LightningElement, api } from 'lwc';
import getVisao from '@salesforce/apex/Visao360Controller.getVisao';
import getAssets from '@salesforce/apex/Visao360Controller.getAssets';
import getOffers from '@salesforce/apex/Visao360Controller.getOffers';
import rejectOffer from '@salesforce/apex/Visao360Controller.rejectOffer';
import acceptOffer from '@salesforce/apex/Visao360Controller.acceptOffer';
import resolveAccount from '@salesforce/apex/Visao360Controller.resolveAccount';

const ABAS = [
    { id: 'resumo', rotulo: 'Resumo' },
    { id: 'inteligencia', rotulo: 'Inteligência' },
    { id: 'accounts', rotulo: 'Financial Accounts' },
    { id: 'goals', rotulo: 'Financial Goals' },
    { id: 'relacionamentos', rotulo: 'Relacionamentos' },
    { id: 'atividades', rotulo: 'Atividades' }
];

/**
 * Shell da Visão 360° — dono APENAS do estado/roteamento da página:
 * raiz (recordId da Account), aba ativa, cargas por área (Cen 15),
 * ofertas NBO estáticas + retry (EL-03) e troca de raiz vinda da árvore
 * (RN-11 — volta ao Resumo). Detalhe volátil vive no
 * c-visao360-ativo-detalhe via LMS (não há estado de detalhe aqui).
 * Toda UI de domínio mora nos filhos. O shell nunca renderiza dado
 * cadastral, ativo, oferta ou caso diretamente.
 */
export default class Visao360Shell extends LightningElement {
    @api recordId;

    visao = null;
    ativos = [];
    ofertas = [];
    nboMotor = null;

    abaAtiva = 'resumo';
    carregandoVisao = true;
    carregandoAtivos = true;
    nboPronto = false;
    nboErro = null;
    nboTentado = false;
    erroVisao = null;
    erroAtivos = null;

    selecionadoId = null;

    connectedCallback() {
        this._carregarTudo();
    }

    _carregarTudo() {
        this.carregandoVisao = true;
        this.carregandoAtivos = true;
        this.nboPronto = false;
        this.nboErro = null;
        this.erroVisao = null;
        this.erroAtivos = null;
        this.abaAtiva = 'resumo';
        this.selecionadoId = null;
        this._carregarVisao();
        this._carregarAtivos();
        this._carregarNbo(false);
    }

    _carregarVisao() {
        getVisao({ accountId: this.recordId })
            .then((result) => {
                if (result?.fault) {
                    this.erroVisao = result.fault.message;
                    this.visao = null;
                } else {
                    this.visao = result;
                }
            })
            .catch((e) => {
                this.erroVisao = e?.body?.message ?? 'Visão indisponível no momento.';
                this.visao = null;
            })
            .finally(() => {
                this.carregandoVisao = false;
            });
    }

    _carregarAtivos() {
        getAssets({ accountId: this.recordId })
            .then((result) => {
                if (result?.fault) {
                    this.erroAtivos = result.fault.message;
                    this.ativos = [];
                } else {
                    this.ativos = result?.items ?? [];
                }
            })
            .catch((e) => {
                this.erroAtivos = e?.body?.message ?? 'Inventário indisponível no momento.';
                this.ativos = [];
            })
            .finally(() => {
                this.carregandoAtivos = false;
            });
    }

    _carregarNbo(retry) {
        // NBO estático: entra com a raiz, sem spinner (RN-17).
        getOffers({ accountId: this.recordId, retry })
            .then((result) => {
                if (result?.fault) {
                    this.ofertas = [];
                    this.nboErro = result.fault.message;
                    this.nboMotor = result?.motor ?? null;
                } else {
                    this.ofertas = result?.offers ?? [];
                    this.nboMotor = result?.motor ?? null;
                    this.nboErro = null;
                }
            })
            .catch((e) => {
                this.ofertas = [];
                this.nboErro = e?.body?.message ?? 'Motor de propensão indisponível no momento.';
            })
            .finally(() => {
                this.nboPronto = true;
            });
    }

    // --- Leitura para os filhos (props IN) ---

    get abas() {
        return ABAS.map((a) => ({
            ...a,
            ativa: a.id === this.abaAtiva,
            classe: a.id === this.abaAtiva ? 'slds-tabs_default__item slds-is-active' : 'slds-tabs_default__item'
        }));
    }

    get ehAbaResumo() {
        return this.abaAtiva === 'resumo';
    }

    get ehAbaInteligencia() {
        return this.abaAtiva === 'inteligencia';
    }

    get ehAbaAccounts() {
        return this.abaAtiva === 'accounts';
    }

    get ehAbaGoals() {
        return this.abaAtiva === 'goals';
    }

    get ehAbaRelacionamentos() {
        return this.abaAtiva === 'relacionamentos';
    }

    get ehAbaAtividades() {
        return this.abaAtiva === 'atividades';
    }

    get header() {
        return this.visao?.header ?? null;
    }

    get completude() {
        return this.visao?.completude ?? null;
    }

    get docAtual() {
        return this.visao?.arcResumo?.[0]?.doc ?? null;
    }

    get raizNome() {
        return this.visao?.header?.nome ?? '';
    }

    get totalAtivos() {
        return this.ativos?.length ?? 0;
    }

    // --- Eventos dos filhos (OUT → estado do shell) ---

    aoTrocarAba(event) {
        const id = event.currentTarget?.dataset?.id;
        if (id && ABAS.some((a) => a.id === id)) this.abaAtiva = id;
    }

    aoTrocarRaiz(event) {
        const doc = event.detail?.doc;
        if (!doc) return;
        resolveAccount({ document: doc })
            .then((novoId) => {
                if (novoId && novoId !== this.recordId) {
                    this.recordId = novoId;
                    this.nboTentado = false;
                    this._carregarTudo();
                }
            })
            .catch(() => {
                // Sem troca: mantém a raiz atual navegável (RN-07).
            });
    }

    aoSelecionarAtivo(event) {
        // Só o destaque visual; o detalhe assina o LMS (T-C05).
        this.selecionadoId = event.detail?.id ?? null;
    }

    aoRecusarOferta(event) {
        const { ofertaId, motivo } = event.detail ?? {};
        if (!ofertaId) return;
        // Cenário 12 — some na hora; o registro em 2º plano é assíncrono.
        this.ofertas = this.ofertas.filter((o) => o.externalOfferId !== ofertaId);
        rejectOffer({ externalOfferId: ofertaId, reason: motivo }).catch(() => {
            // Otimista: falha em 2º plano nunca reverte a tela.
        });
    }

    aoContratarOferta(event) {
        const { ofertaId } = event.detail ?? {};
        if (!ofertaId) return;
        // Cenário 13 / RN-14 — marca negociação; a venda guiada é futura.
        acceptOffer({ externalOfferId: ofertaId })
            .then(() => {
                this.ofertas = this.ofertas.map((o) =>
                    o.externalOfferId === ofertaId ? { ...o, estado: 'negociacao' } : o
                );
            })
            .catch(() => {
                // Mantém a tela navegável; operador pode tentar de novo.
            });
    }

    aoTentarNbo() {
        this.nboTentado = true;
        this.nboPronto = false;
        this._carregarNbo(true);
    }
}
