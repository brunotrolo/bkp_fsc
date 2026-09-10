import { LightningElement, api } from 'lwc';

/** Histórico de atendimentos — tabela 9 colunas, somente leitura. */
export default class Visao360Historico extends LightningElement {
    @api casos = [];

    get temCasos() {
        return (this.casos?.length ?? 0) > 0;
    }

    get casosApresentacao() {
        return (this.casos ?? []).map((c) => {
            const nota = c.satisfacao ?? 0;
            return {
                ...c,
                data: c.dataOcorrencia,
                motivo: c.assunto,
                estrelas: '★'.repeat(nota) + '☆'.repeat(5 - nota)
            };
        });
    }
}
