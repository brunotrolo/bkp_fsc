import LightningModal from 'lightning/modal';
import { api } from 'lwc';

/**
 * Modal de posições de investimento (P8). Devolve a posição ou undefined
 * (Cancelar desfaz a seleção).
 */
export default class InvestimentoDrawer extends LightningModal {
    _investimentos = [];

    @api
    get investimentos() {
        return this._investimentos;
    }

    set investimentos(value) {
        this._investimentos = (value ?? []).map((p, idx) => ({
            ...p,
            chave: p.externalContractId || `inv-${idx}`,
            ariaLabel: `${p.classe ?? ''} ${p.produto ?? ''} ${p.valor ?? ''} risco ${p.risco ?? ''}`
        }));
    }

    aoEscolherInvestimento(event) {
        const id = event.currentTarget.dataset.id;
        const pos = (this._investimentos ?? []).find((p) => (p.externalContractId ?? p.chave) === id) ?? null;
        this.close(pos);
    }

    aoCancelar() {
        this.close(undefined);
    }
}
