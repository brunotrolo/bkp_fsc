import { LightningElement, api } from 'lwc';

/** Faixa Holding, dona de P5. Somente leitura, sem seleção transacional. */
export default class HoldingStrip extends LightningElement {
    @api holding = [];
}
