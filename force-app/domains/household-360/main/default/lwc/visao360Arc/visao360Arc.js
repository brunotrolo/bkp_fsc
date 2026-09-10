import { LightningElement, api } from 'lwc';
import Visao360ArcModal from 'c/visao360ArcModal';

/**
 * Árvore de relacionamentos — dono de P3.
 * Entrada: @api nos (resumida 1º nível), @api arvore (multinível p/ o modal),
 *   @api totalVinculos, @api docAtual, @api raizNome.
 * Saída: evento `trocarraiz` { doc } — clique em nó vinculado troca a
 *   raiz da 360° sem voltar à busca (RN-11/EL-05). O modal é aberto aqui e
 *   devolve a troca via close() — repassada no mesmo evento.
 */
export default class Visao360Arc extends LightningElement {
    @api nos = [];
    @api arvore = [];
    @api totalVinculos = 0;
    @api docAtual = null;
    @api raizNome = '';

    noSelecionadoId = null;
    recolhidos = [];

    get temNos() {
        return (this.nos?.length ?? 0) > 0;
    }

    get nosApresentacao() {
        return (this.nos ?? []).map((n) => ({
            ...n,
            icone: n.tipo === 'PJ' ? 'standard:account' : 'standard:contact',
            selecionado: n.id === this.noSelecionadoId,
            classeNo: n.id === this.noSelecionadoId ? 'c-arc-no c-arc-no_selecionado' : 'c-arc-no',
            dica: n.doc && n.doc !== this.docAtual ? 'Abrir Visão 360° desta empresa/pessoa' : n.papel
        }));
    }

    get noSelecionado() {
        return (this.nos ?? []).find((n) => n.id === this.noSelecionadoId) ?? null;
    }

    get iconeRaiz() {
        const raiz = (this.nos ?? [])[0];
        return raiz?.tipo === 'PJ' ? 'standard:account' : 'standard:contact';
    }

    get grupos() {
        const lista = this.nosApresentacao;
        if (!lista.length) return [];
        const raiz = lista[0];
        const doTipoRaiz = lista.filter((n) => n.tipo === raiz.tipo);
        const outroTipo = lista.filter((n) => n.tipo !== raiz.tipo);
        const barraPrincipal = 'c-arc-membro_barra c-arc-membro_barra_principal';
        const barraVinculo = 'c-arc-membro_barra c-arc-membro_barra_vinculo';
        const grupos = [
            {
                id: 'grupo-principal',
                titulo: this._tituloPrincipal(raiz, doTipoRaiz.length),
                subtitulo: raiz.tipo === 'PJ' ? 'Empresa' : 'Núcleo familiar',
                principal: true,
                expandido: !this.recolhidos.includes('grupo-principal'),
                tituloRecolher: 'Recolher/expandir grupo principal',
                membros: doTipoRaiz.map((n, i) => ({ ...n, classeBarra: barraPrincipal, ehMembroPrincipal: i === 0 }))
            }
        ];
        if (outroTipo.length) {
            grupos.push({
                id: 'grupo-vinculados',
                titulo: `${raiz.tipo === 'PJ' ? 'Pessoas vinculadas' : 'Empresas vinculadas'} (${outroTipo.length})`,
                subtitulo: 'Vínculo',
                principal: false,
                expandido: !this.recolhidos.includes('grupo-vinculados'),
                tituloRecolher: 'Recolher/expandir vínculos',
                membros: outroTipo.map((n) => ({ ...n, classeBarra: barraVinculo, ehMembroPrincipal: false }))
            });
        }
        return grupos;
    }

    _tituloPrincipal(raiz, total) {
        if (raiz.tipo === 'PJ') return `${raiz.nome} (${total})`;
        const sobrenome = (raiz.nome ?? '').trim().split(/\s+/).slice(-1)[0] ?? '';
        return `Família ${sobrenome} (${total})`;
    }

    get notaLimite() {
        return `Resumida limitada a 5 nós de 1º nível — ${this.totalVinculos} vínculo(s) no total (RN-13).`;
    }

    aoAlternarGrupo(event) {
        const id = event.currentTarget?.dataset?.id;
        if (!id) return;
        this.recolhidos = this.recolhidos.includes(id)
            ? this.recolhidos.filter((r) => r !== id)
            : [...this.recolhidos, id];
    }

    aoClicarNo(event) {
        const id = event.currentTarget?.dataset?.id;
        const no = (this.nos ?? []).find((n) => n.id === id);
        if (!no) return;
        // RN-11 — nó com documento vinculado troca a raiz na hora.
        if (no.doc && no.doc !== this.docAtual) {
            this.dispatchEvent(new CustomEvent('trocarraiz', { detail: { doc: no.doc } }));
            return;
        }
        this.noSelecionadoId = this.noSelecionadoId === id ? null : id;
    }

    async aoVerArvoreCompleta() {
        const resultado = await Visao360ArcModal.open({
            size: 'full',
            titulo: `Árvore completa — ${this.raizNome}`,
            raizNome: this.raizNome,
            nos: this.arvore,
            docAtual: this.docAtual,
            totalVinculos: this.totalVinculos
        });
        if (resultado?.trocarRaiz && resultado.trocarRaiz !== this.docAtual) {
            this.dispatchEvent(new CustomEvent('trocarraiz', { detail: { doc: resultado.trocarRaiz } }));
        }
    }
}
