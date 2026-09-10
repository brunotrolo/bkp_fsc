import { LightningElement, api } from 'lwc';

const ICONE_STATUS = {
    ok: 'utility:success',
    falha: 'utility:clear',
    pendente: 'utility:warning'
};

const POR_PAGINA_ACESSOS = 3;

/** Aba Inteligência — fluxo, segmentação, comportamento e campanhas. Somente leitura, sem eventos. */
export default class Visao360Inteligencia extends LightningElement {
    @api comportamento = null;
    @api campanhas = [];
    @api fluxo = null;
    @api segmentacao = null;

    canal = 'site';
    acessosExpandidos = [];
    limiteAcessos = POR_PAGINA_ACESSOS;
    secoesAbertas = ['comportamento'];

    get temComportamento() {
        return Boolean(this.comportamento);
    }

    get temCampanhas() {
        return (this.campanhas?.length ?? 0) > 0;
    }

    get campanhasApresentacao() {
        return (this.campanhas ?? []).map((c) => ({
            ...c,
            iconePrimeira: ICONE_STATUS[c.primeira] ?? ICONE_STATUS.pendente,
            iconeFinal: ICONE_STATUS[c.finalizacao] ?? ICONE_STATUS.pendente,
            iconeOportunidade: ICONE_STATUS[c.oportunidade] ?? ICONE_STATUS.pendente
        }));
    }

    get secoesAbertasLista() {
        return [...this.secoesAbertas];
    }

    aoAlternarSecao(event) {
        this.secoesAbertas = [...(event.detail?.openSections ?? [])];
    }

    get filtrosCanal() {
        const base = [
            { id: 'site', rotulo: 'Site' },
            { id: 'app', rotulo: 'Aplicativo' }
        ];
        return base.map((f) => ({
            ...f,
            ativo: this.canal === f.id,
            classe: f.id === this.canal ? 'c-subaba c-subaba_ativa' : 'c-subaba'
        }));
    }

    get acessosFiltrados() {
        return this.canal === 'app' ? (this.comportamento?.app ?? []) : (this.comportamento?.site ?? []);
    }

    get acessosVisiveis() {
        return this.acessosFiltrados.slice(0, this.limiteAcessos).map((a) => ({
            ...a,
            expandido: this.acessosExpandidos.includes(a.quando)
        }));
    }

    get temMaisAcessos() {
        return this.acessosFiltrados.length > this.limiteAcessos;
    }

    get paginadoAcessos() {
        return this.limiteAcessos > POR_PAGINA_ACESSOS;
    }

    aoFiltrarCanal(event) {
        const id = event.currentTarget?.dataset?.id;
        if (!id) return;
        this.canal = id;
        this.limiteAcessos = POR_PAGINA_ACESSOS;
    }

    aoAlternarAcesso(event) {
        const id = event.currentTarget?.dataset?.id;
        if (!id) return;
        this.acessosExpandidos = this.acessosExpandidos.includes(id)
            ? this.acessosExpandidos.filter((a) => a !== id)
            : [...this.acessosExpandidos, id];
    }

    aoVerMaisAcessos() {
        this.limiteAcessos = this.acessosFiltrados.length;
    }

    aoVerMenosAcessos() {
        this.limiteAcessos = POR_PAGINA_ACESSOS;
    }
}
