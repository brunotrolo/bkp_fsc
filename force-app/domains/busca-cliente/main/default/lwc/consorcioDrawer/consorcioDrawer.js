import LightningModal from 'lightning/modal';
import { api } from 'lwc';

/**
 * Modal de cotas de consórcio (P8). Múltiplas cotas no mesmo grupo são itens
 * independentes. Devolve a cota ou undefined (Cancelar desfaz a seleção).
 */
export default class ConsorcioDrawer extends LightningModal {
    _cotas = [];

    @api
    get cotas() {
        return this._cotas;
    }

    set cotas(value) {
        this._cotas = (value ?? []).map((c, idx) => ({
            ...c,
            chave: c.externalContractId || `cota-${idx}`,
            ariaLabel: `${c.tipo ?? ''} grupo ${c.grupo ?? ''} cota ${c.cota ?? ''} ${c.valor ?? ''} ${c.status ?? ''}`
        }));
    }

    aoEscolherCota(event) {
        const id = event.currentTarget.dataset.id;
        const cota = (this._cotas ?? []).find((c) => (c.externalContractId ?? c.chave) === id) ?? null;
        this.close(cota);
    }

    aoCancelar() {
        this.close(undefined);
    }
}
