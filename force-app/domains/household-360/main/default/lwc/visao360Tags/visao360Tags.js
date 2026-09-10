import { LightningElement, api } from 'lwc';

/** Tags de interesse — busca, filtro e remoção locais. Sem Apex, sem eventos. */
export default class Visao360Tags extends LightningElement {
    @api segmentos = [];
    @api investimentos = [];
    @api estilo = [];

    categoria = 'todas';
    busca = '';
    removidas = [];

    get temTags() {
        return (
            (this.segmentos?.length ?? 0) +
            (this.investimentos?.length ?? 0) +
            (this.estilo?.length ?? 0)
        ) > 0;
    }

    get opcoesCategoria() {
        return [
            { label: 'Todas as categorias', value: 'todas' },
            { label: 'Segmento', value: 'segmentos' },
            { label: 'Investimentos', value: 'investimentos' },
            { label: 'Estilo de vida', value: 'estilo' }
        ];
    }

    get gruposVisiveis() {
        const termo = (this.busca ?? '').trim().toLowerCase();
        const todos = [
            { id: 'segmentos', rotulo: 'Segmento do cliente', icone: 'standard:groups', lista: this.segmentos ?? [] },
            { id: 'investimentos', rotulo: 'Investimentos', icone: 'utility:moneybag', lista: this.investimentos ?? [] },
            { id: 'estilo', rotulo: 'Estilo de vida', icone: 'utility:target', lista: this.estilo ?? [] }
        ];
        return todos
            .filter((g) => this.categoria === 'todas' || g.id === this.categoria)
            .map((g) => ({
                ...g,
                tags: (g.lista ?? []).filter(
                    (t) => !this.removidas.includes(`${g.id}:${t}`) && (!termo || t.toLowerCase().includes(termo))
                )
            }))
            .filter((g) => g.tags.length > 0);
    }

    aoTrocarCategoria(event) {
        this.categoria = event.detail?.value ?? 'todas';
    }

    aoBuscar(event) {
        this.busca = event.target?.value ?? '';
    }

    aoRemover(event) {
        const grupo = event.currentTarget?.dataset?.grupo;
        const tag = event.currentTarget?.dataset?.tag;
        if (grupo && tag) this.removidas = [...this.removidas, `${grupo}:${tag}`];
    }
}
