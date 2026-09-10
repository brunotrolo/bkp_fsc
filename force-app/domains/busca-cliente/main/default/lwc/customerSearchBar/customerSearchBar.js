import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CUSTOMER_CHANNEL from '@salesforce/messageChannel/CustomerInteractionChannel__c';

const MODES = [
    { label: 'PF', value: 'PF' },
    { label: 'PJ', value: 'PJ' },
    { label: 'Protocolo', value: 'PROTOCOLO' },
    { label: 'Não cliente', value: 'NAO_CLIENTE' }
];

/**
 * Barra de busca, dona de P1. Validação de formato local (DV fica no servidor),
 * máscara dinâmica só em PF/PJ, Enter/F2 e foco automático. Publica
 * CUSTOMER_SEARCH_TRIGGERED no LMS; nunca toca em resultado, hub ou oferta.
 */
export default class CustomerSearchBar extends LightningElement {
    tipoPessoa = 'PF';
    documentoDigitado = '';
    _f2Handler = null;

    opcoesTipoPessoa = MODES;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this._f2Handler = (event) => {
            if (event.key === 'F2') {
                event.preventDefault();
                this.focusInput();
            }
        };
        window.addEventListener('keydown', this._f2Handler);
        setTimeout(() => this.focusInput(), 0);
    }

    disconnectedCallback() {
        if (this._f2Handler) {
            window.removeEventListener('keydown', this._f2Handler);
        }
    }

    @api
    focusInput() {
        const el = this.template.querySelector('lightning-input');
        if (el) {
            el.focus();
        }
    }

    @api
    limpar() {
        this.documentoDigitado = '';
        setTimeout(() => this.focusInput(), 0);
    }

    get documentoNormalizado() {
        return (this.documentoDigitado ?? '').toUpperCase().replace(/[^A-Z0-9]/g, '');
    }

    get buscaDesabilitada() {
        const doc = this.documentoNormalizado;
        if (this.tipoPessoa === 'PF') {
            return !/^[0-9]{11}$/.test(doc);
        }
        if (this.tipoPessoa === 'PJ') {
            return !/^[A-Z0-9]{14}$/.test(doc);
        }
        if (this.tipoPessoa === 'PROTOCOLO') {
            return doc.length < 5;
        }
        if (this.tipoPessoa === 'NAO_CLIENTE') {
            return doc.length === 0;
        }
        return !doc;
    }

    get dicaBusca() {
        if (!this.documentoDigitado) {
            return 'Digite o valor e pressione Enter.';
        }
        if (this.buscaDesabilitada) {
            return 'Formato inválido — confira o valor.';
        }
        return 'Formato válido — pressione Enter ou clique em Localizar.';
    }

    get labelCampo() {
        if (this.tipoPessoa === 'PROTOCOLO') {
            return 'Protocolo';
        }
        if (this.tipoPessoa === 'NAO_CLIENTE') {
            return 'CPF ou CNPJ (não cliente)';
        }
        return 'CPF ou CNPJ';
    }

    get placeholderDocumento() {
        if (this.tipoPessoa === 'PROTOCOLO') {
            return '0000000000';
        }
        if (this.tipoPessoa === 'NAO_CLIENTE') {
            return '000.000.000-00';
        }
        return this.tipoPessoa === 'PF' ? '000.000.000-00' : '00.000.000/0000-00 ou alfanumérico BACEN';
    }

    aoTrocarTipoPessoa(event) {
        this.tipoPessoa = event.detail.value;
        if (this.tipoPessoa === 'PF' || this.tipoPessoa === 'PJ') {
            this.documentoDigitado = this.aplicarMascara(this.documentoDigitado);
        }
    }

    aoDigitarDocumento(event) {
        const bruta = event.target.value ?? '';
        this.documentoDigitado =
            this.tipoPessoa === 'PF' || this.tipoPessoa === 'PJ'
                ? this.aplicarMascara(bruta)
                : bruta;
        if (event.key === 'Enter' && !this.buscaDesabilitada) {
            this.aoBuscar();
        }
    }

    aplicarMascara(valor) {
        const limpo = (valor ?? '').toUpperCase().replace(/[^A-Z0-9]/g, '');
        if (this.tipoPessoa === 'PJ') {
            const p = [limpo.slice(0, 2), limpo.slice(2, 5), limpo.slice(5, 8), limpo.slice(8, 12), limpo.slice(12, 14)];
            let out = p[0];
            if (p[1]) {
                out += `.${p[1]}`;
            }
            if (p[2]) {
                out += `.${p[2]}`;
            }
            if (p[3]) {
                out += `/${p[3]}`;
            }
            if (p[4]) {
                out += `-${p[4]}`;
            }
            return out;
        }
        const p = [limpo.slice(0, 3), limpo.slice(3, 6), limpo.slice(6, 9), limpo.slice(9, 11)];
        let out = p[0];
        if (p[1]) {
            out += `.${p[1]}`;
        }
        if (p[2]) {
            out += `.${p[2]}`;
        }
        if (p[3]) {
            out += `-${p[3]}`;
        }
        return out;
    }

    aoBuscar() {
        if (this.buscaDesabilitada) {
            return;
        }
        publish(this.messageContext, CUSTOMER_CHANNEL, {
            type: 'CUSTOMER_SEARCH_TRIGGERED',
            modo: this.tipoPessoa,
            documentNormalized: this.documentoNormalizado,
            payload: ''
        });
    }
}
