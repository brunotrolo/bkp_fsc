import { createElement } from '@lwc/engine-dom';
import Visao360Nbo from 'c/visao360Nbo';

const OFERTAS = [
    {
        externalOfferId: 'DOC_BLACK_2026-09',
        productName: 'Cartão Black',
        headline: 'Isenção de anuidade no 1º ano',
        propensityScore: 92,
        confianca: 'Alta',
        motivos: ['Gasto médio alto', 'Relacionamento longo'],
        validade: '30/09/2026',
        chaveSafra: 'DOC_BLACK_2026-09',
        elegibilidade: 'Sem Black',
        estado: 'elegivel'
    },
    {
        externalOfferId: 'DOC_CDB_2026-09',
        productName: 'CDB 102%',
        headline: 'Aplicação mínima',
        propensityScore: 74,
        confianca: 'Média',
        motivos: ['Saldo parado'],
        validade: '15/10/2026',
        chaveSafra: 'DOC_CDB_2026-09',
        elegibilidade: 'Saldo parado',
        estado: 'elegivel'
    }
];

const MOTOR = { modelo: 'Propensão Porto v3.2', safra: '2026-09', geradoEm: '06/09/2026 às 08:00' };

function montar(props = {}) {
    const el = createElement('c-visao360-nbo', { is: Visao360Nbo });
    el.ofertas = props.ofertas ?? OFERTAS;
    el.erro = props.erro ?? null;
    el.motor = props.motor ?? MOTOR;
    document.body.appendChild(el);
    return el;
}

describe('c-visao360-nbo', () => {
    afterEach(() => {
        while (document.body.firstChild) document.body.removeChild(document.body.firstChild);
    });

    it('exibe top 3 com selo Melhor ação na 1ª e barra de score', async () => {
        const el = montar();
        await Promise.resolve();
        const shadow = el.shadowRoot;
        expect(shadow.querySelector('.c-nbo-oferta_produto').textContent).toBe('Cartão Black');
        const rotulos = [...shadow.querySelectorAll('lightning-badge')].map((b) => b.label);
        expect(rotulos).toContain('Melhor ação');
        expect(rotulos).toContain('Score 92');
        expect(shadow.querySelector('.c-nbo-oferta_meta').textContent).toContain('2026-09');
    });

    it('mostra só banner + retry quando o motor falha (EL-03/RN-12)', async () => {
        const el = montar({ ofertas: [], erro: 'Motor de propensão indisponível no momento.' });
        await Promise.resolve();
        const shadow = el.shadowRoot;
        expect(shadow.querySelector('[role="alert"]').textContent).toContain('Motor de propensão');
        expect(shadow.querySelectorAll('.c-nbo-oferta').length).toBe(0);
        const handler = jest.fn();
        el.addEventListener('tentar', handler);
        const retry = [...shadow.querySelectorAll('lightning-button')].find((b) => b.label === 'Tentar Novamente');
        retry.click();
        expect(handler).toHaveBeenCalledTimes(1);
    });

    it('informa discretamente quando não há ofertas (EL-02)', async () => {
        const el = montar({ ofertas: [], erro: null });
        await Promise.resolve();
        expect(el.shadowRoot.textContent).toContain('Sem ofertas elegíveis');
    });

    it('emite recusar com motivo rápido e contratar com id', async () => {
        const el = montar();
        await Promise.resolve();
        const recusas = [];
        const contratos = [];
        el.addEventListener('recusar', (e) => recusas.push(e.detail));
        el.addEventListener('contratar', (e) => contratos.push(e.detail));
        const botoes = el.shadowRoot.querySelectorAll('lightning-button');
        const recusar = [...botoes].find((b) => b.label === 'Recusar');
        recusar.click();
        await Promise.resolve();
        const confirmar = [...el.shadowRoot.querySelectorAll('lightning-button')].find(
            (b) => b.label === 'Confirmar recusa'
        );
        confirmar.click();
        expect(recusas).toEqual([{ ofertaId: 'DOC_BLACK_2026-09', motivo: 'SEM_INTERESSE' }]);
        await Promise.resolve();
        const contratar = [...el.shadowRoot.querySelectorAll('lightning-button')].find(
            (b) => b.label === 'Contratar'
        );
        contratar.click();
        expect(contratos).toEqual([{ ofertaId: 'DOC_BLACK_2026-09' }]);
    });

    it('exibe aviso de reserva quando a oferta está em negociação (RN-14)', async () => {
        const emNegociacao = [{ ...OFERTAS[0], estado: 'negociacao' }];
        const el = montar({ ofertas: emNegociacao });
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('.c-nbo-oferta_reserva').textContent).toContain(
            'Oferta reservada'
        );
    });
});
