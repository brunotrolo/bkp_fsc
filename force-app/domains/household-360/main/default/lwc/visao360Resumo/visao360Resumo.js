import { LightningElement, api } from 'lwc';

/** Aba Resumo — faixa de KPIs. Somente leitura, sem eventos. */
export default class Visao360Resumo extends LightningElement {
    @api patrimonio = null;
    @api aum = null;
    @api walletShare = null;
    @api scoreCredito = null;
    @api completude = null;

    get temResumo() {
        return Boolean(this.patrimonio ?? this.aum ?? this.walletShare ?? this.scoreCredito);
    }
}
