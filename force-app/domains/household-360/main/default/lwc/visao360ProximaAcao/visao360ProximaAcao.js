import { LightningElement, api } from 'lwc';

/** Próxima melhor ação (NBA) — recomendações com CTA; estado local. */
export default class Visao360ProximaAcao extends LightningElement {
    @api acoes = [];

    iniciadas = [];

    get temAcoes() {
        return (this.acoes?.length ?? 0) > 0;
    }

    get acoesEstado() {
        return (this.acoes ?? []).map((a, indice) => ({
            ...a,
            ehPrimeira: indice === 0,
            iniciada: this.iniciadas.includes(a.id)
        }));
    }

    aoIniciar(event) {
        const id = event.currentTarget?.dataset?.id;
        if (!id) return;
        this.iniciadas = [...this.iniciadas, id];
    }
}
