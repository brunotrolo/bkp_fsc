import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import PORTO_BANK_360_CHANNEL from '@salesforce/messageChannel/PortoBank360Channel__c';

const ABAS = [
    { valor: 'TODOS', rotulo: 'Todos' },
    { valor: 'CARTAO', rotulo: 'Cartões' },
    { valor: 'CONTA', rotulo: 'Conta' },
    { valor: 'CONSORCIO', rotulo: 'Consórcio' },
    { valor: 'INVEST', rotulo: 'Investimentos' }
];

const ICONES = {
    CARTAO: 'utility:card_details',
    CONTA: 'custom:custom16',
    CONSORCIO: 'utility:contract_doc',
    INVEST: 'standard:investment_account'
};

/**
 * Inventário de ativos — dono de P4.
 * Entrada: @api ativos (AssetSummaryDTO de todas as famílias),
 *   @api selecionadoId (dono: shell — a seleção sobrevive à troca de aba).
 * Saída: evento `selecionar` { id } + publicação ASSET_SELECTED no
 *   PortoBank360Channel__c (contrato interno do domínio p/ o detalhe).
 * Estado interno só da aba ativa (view).
 */
export default class Visao360Ativos extends LightningElement {
    @api ativos = [];
    @api selecionadoId = null;

    abaAtiva = 'TODOS';

    contextoMensagem = null;

    @wire(MessageContext)
    wiredContexto(ctx) {
        if (ctx) {
            this.contextoMensagem = ctx;
        }
    }

    get abas() {
        const todos = this.ativos ?? [];
        return ABAS.map((aba) => {
            const itensBrutos =
                aba.valor === 'TODOS' ? todos : todos.filter((a) => a.productFamily === aba.valor);
            return {
                valor: aba.valor,
                rotulo: `${aba.rotulo} (${itensBrutos.length})`,
                temItens: itensBrutos.length > 0,
                itens: itensBrutos.map((a) => ({
                    id: a.assetId,
                    rotulo: a.label,
                    identificador: a.maskedId,
                    situacao: a.status,
                    numero: a.numero,
                    valor: a.valor,
                    encerramento: a.encerramento,
                    ultimaMov: a.ultimaMov,
                    icone: ICONES[a.productFamily] ?? 'standard:account',
                    selecionado: a.assetId === this.selecionadoId,
                    classeCartao: this._classeCartao(a)
                }))
            };
        });
    }

    _classeCartao(ativo) {
        // Situação vai no badge (texto); a borda só marca seleção.
        return ativo.assetId === this.selecionadoId ? 'c-ativo c-ativo_selecionado' : 'c-ativo';
    }

    aoAtivarAba(event) {
        const valor = event.target?.value;
        if (valor) this.abaAtiva = valor;
    }

    aoSelecionar(event) {
        const id = event.currentTarget?.dataset?.id;
        if (!id) return;
        const ativo = (this.ativos ?? []).find((a) => a.assetId === id);
        if (ativo) {
            try {
                // No ar, contextoMensagem sempre vem do @wire; sem ele
                // (ex.: Jest), o publish é ignorado e o evento prevalece.
                publish(this.contextoMensagem, PORTO_BANK_360_CHANNEL, {
                    assetId: ativo.assetId,
                    contractNumber: ativo.contractNumber,
                    productFamily: ativo.productFamily,
                    status: ativo.status
                });
            } catch {
                // Sem barramento neste contexto: o evento `selecionar` basta.
            }
        }
        this.dispatchEvent(new CustomEvent('selecionar', { detail: { id } }));
    }
}
