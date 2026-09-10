import { createElement } from '@lwc/engine-dom';
import Visao360Ativos from 'c/visao360Ativos';

jest.mock(
    'lightning/messageService',
    () => ({
        publish: jest.fn(),
        MessageContext: jest.fn(),
        subscribe: jest.fn(),
        unsubscribe: jest.fn(),
        APPLICATION_SCOPE: {}
    }),
    { virtual: true }
);

const ATIVOS = [
    {
        assetId: 'a1',
        contractNumber: 'CART-1234',
        productFamily: 'CARTAO',
        label: 'Cartão Visa Infinite',
        maskedId: 'final 1234',
        status: 'Ativo',
        numero: '0012 •• 1234',
        valor: 'Limite R$ 28.000',
        encerramento: 'Vence 10/09/2026',
        ultimaMov: 'Fatura R$ 3.210,45'
    },
    {
        assetId: 'a2',
        contractNumber: 'CONT-0001',
        productFamily: 'CONTA',
        label: 'Conta Digital',
        maskedId: 'Ag 0001',
        status: 'Ativo',
        numero: 'Ag 0001',
        valor: 'R$ 12.480,90',
        encerramento: '—',
        ultimaMov: 'Pix hoje'
    }
];

function montar(ativos = ATIVOS, selecionadoId = null) {
    const el = createElement('c-visao360-ativos', { is: Visao360Ativos });
    el.ativos = ativos;
    el.selecionadoId = selecionadoId;
    document.body.appendChild(el);
    return el;
}

describe('c-visao360-ativos', () => {
    afterEach(() => {
        while (document.body.firstChild) document.body.removeChild(document.body.firstChild);
        jest.clearAllMocks();
    });

    it('filtra cartões por aba mantendo a seleção (Cen 6)', async () => {
        const el = montar(ATIVOS, 'a1');
        await Promise.resolve();
        const abas = el.shadowRoot.querySelectorAll('lightning-tab');
        expect(abas.length).toBe(5);
        expect(abas[0].label).toBe('Todos (2)');
    });

    it('publica no LMS e emite selecionar ao clicar (T-C05)', async () => {
        const { publish } = jest.requireMock('lightning/messageService');
        const el = montar();
        await Promise.resolve();
        const handler = jest.fn();
        el.addEventListener('selecionar', handler);
        el.shadowRoot.querySelector('button.c-ativo').click();
        expect(handler).toHaveBeenCalledWith(
            expect.objectContaining({ detail: { id: 'a1' } })
        );
        expect(publish).toHaveBeenCalledTimes(1);
        expect(publish.mock.calls[0][1]).toBe('PortoBank360Channel__c');
        expect(publish.mock.calls[0][2]).toEqual(
            expect.objectContaining({ contractNumber: 'CART-1234', productFamily: 'CARTAO' })
        );
    });

    it('mostra vazio discreto em família sem vínculo (EL-01)', async () => {
        const el = montar([ATIVOS[1]]);
        await Promise.resolve();
        expect(el.shadowRoot.textContent).toContain('Nenhum vínculo nesta família');
    });
});
