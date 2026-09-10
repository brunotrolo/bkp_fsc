import LightningModal from 'lightning/modal';
import { api } from 'lwc';

/**
 * Modal de vias de cartão (P8). Recebe as vias via @api, devolve a via
 * escolhida ou undefined (Cancelar desfaz a seleção, Cen 19).
 */
export default class CardDrawer extends LightningModal {
    _vias = [];

    @api
    get vias() {
        return this._vias;
    }

    set vias(value) {
        this._vias = (value ?? []).map((v, idx) => ({
            ...v,
            chave: v.externalContractId || v.id || `via-${idx}`,
            estiloCartao: `background:#ffffff;color:#2e2e2e;border:1px solid #c9c9c9;border-left:4px solid ${this.corSituacao(v.status)}`,
            ariaLabel: `${v.brand ?? ''} ${v.category ?? ''} final ${v.last4Masked ?? ''} ${v.status ?? ''} ${v.holderName ?? ''}`
        }));
    }

    corSituacao(status) {
        if (status === 'Ativo') {
            return '#2e844a';
        }
        if (status === 'Cancelado') {
            return '#c9c9c9';
        }
        return '#dd7a01';
    }

    aoEscolherVia(event) {
        const id = event.currentTarget.dataset.id;
        const via = (this._vias ?? []).find((v) => (v.externalContractId ?? v.id ?? v.chave) === id) ?? null;
        this.close(via);
    }

    aoCancelar() {
        this.close(undefined);
    }
}
