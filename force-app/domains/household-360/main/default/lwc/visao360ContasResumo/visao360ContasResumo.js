import { LightningElement, api } from 'lwc';

/** Financial Accounts — faixa de totais. Somente leitura, sem eventos. */
export default class Visao360ContasResumo extends LightningElement {
    @api aum = null;
    @api patrimonio = null;
    @api ativosFora = null;
    @api total = 0;

    get temResumo() {
        return Boolean(this.aum ?? this.patrimonio ?? this.ativosFora);
    }
}
