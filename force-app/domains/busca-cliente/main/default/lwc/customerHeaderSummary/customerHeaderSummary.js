import { LightningElement, api } from 'lwc';

/** Faixa de identificação, dona de P3. Somente leitura via @api, sem eventos. */
export default class CustomerHeaderSummary extends LightningElement {
    @api cliente = null;
    @api iconeTipoPessoa = 'standard:contact';
}
