import { LightningElement, api } from 'lwc';

const OPCOES_MOTIVO = [
    { label: 'Sem interesse', value: 'SEM_INTERESSE' },
    { label: 'Achou caro', value: 'ACHOU_CARO' },
    { label: 'Já possui', value: 'JA_POSSUI' }
];

/**
 * Painel NBO top 3 — dono de P6 (apresentação).
 * Entrada: @api ofertas (NBOOfferDTO ordenadas por score), @api erro
 * (motor fora), @api motor (modelo/safra/geração).
 * Saída: `recusar` { ofertaId, motivo }, `contratar` { ofertaId },
 *   `tentar` (retry do motor). O estado da lista é do shell; aqui só o
 *   motivo rápido em edição (view).
 */
export default class Visao360Nbo extends LightningElement {
    @api ofertas = [];
    @api erro = null;
    @api motor = null;

    recusaOfertaId = null;
    motivoSelecionado = 'SEM_INTERESSE';
    opcoesMotivo = OPCOES_MOTIVO;

    get temErro() {
        return Boolean(this.erro);
    }

    get temOfertas() {
        return !this.temErro && (this.ofertas?.length ?? 0) > 0;
    }

    get mostrarVazio() {
        return !this.temErro && (this.ofertas?.length ?? 0) === 0;
    }

    get ofertasApresentacao() {
        // A 1ª da lista (maior score) leva o selo "Melhor ação" — após uma
        // recusa, a próxima herda o selo automaticamente.
        return (this.ofertas ?? []).map((o, indice) => ({
            id: o.externalOfferId,
            produto: o.productName,
            condicao: o.headline,
            score: o.propensityScore ?? 0,
            confianca: o.confianca === 'Media' ? 'Média' : o.confianca,
            motivos: o.motivos ?? [],
            validade: o.validade,
            chaveSafra: o.chaveSafra,
            elegibilidade: o.elegibilidade,
            emNegociacao: o.estado === 'negociacao',
            recusando: o.externalOfferId === this.recusaOfertaId,
            rotuloScore: `Score ${o.propensityScore ?? 0}`,
            ehMelhorAcao: indice === 0 && o.estado === 'elegivel'
        }));
    }

    get podeConfirmarRecusa() {
        return Boolean(this.recusaOfertaId && this.motivoSelecionado);
    }

    aoIniciarRecusa(event) {
        const id = event.currentTarget?.dataset?.id;
        if (!id) return;
        this.recusaOfertaId = id;
        this.motivoSelecionado = 'SEM_INTERESSE';
    }

    aoCancelarRecusa() {
        this.recusaOfertaId = null;
    }

    aoTrocarMotivo(event) {
        this.motivoSelecionado = event.detail?.value ?? 'SEM_INTERESSE';
    }

    aoConfirmarRecusa() {
        if (!this.podeConfirmarRecusa) return;
        this.dispatchEvent(
            new CustomEvent('recusar', {
                detail: { ofertaId: this.recusaOfertaId, motivo: this.motivoSelecionado }
            })
        );
        this.recusaOfertaId = null;
    }

    aoContratar(event) {
        const id = event.currentTarget?.dataset?.id;
        if (id) this.dispatchEvent(new CustomEvent('contratar', { detail: { ofertaId: id } }));
    }

    aoTentar() {
        this.dispatchEvent(new CustomEvent('tentar'));
    }
}
