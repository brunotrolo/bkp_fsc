import { createElement } from 'lwc';
import ProductHub from 'c/productHub';
import { publish } from 'lightning/messageService';

jest.mock(
    'lightning/messageService',
    () => ({
        MessageContext: jest.fn(),
        publish: jest.fn(),
        subscribe: jest.fn(),
        unsubscribe: jest.fn(),
        createMessageContext: jest.fn(),
        releaseMessageContext: jest.fn()
    }),
    { virtual: true }
);

const PRODUTOS = [
    { tipo: 'CARTAO', nome: 'Cartão de Crédito', resumo: '4 plásticos', icone: 'utility:card_details', selecionado: false, selo: 'Disponível', classeCartao: 'c-product-card' },
    { tipo: 'CONTA_DIGITAL', nome: 'Conta Digital', resumo: 'Ativa', icone: 'custom:custom16', selecionado: false, selo: 'Disponível', classeCartao: 'c-product-card' }
];

describe('c-product-hub', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renderiza um cartão por produto com resumo (Cen 7)', async () => {
        const el = createElement('c-product-hub', { is: ProductHub });
        el.produtos = PRODUTOS;
        document.body.appendChild(el);
        await Promise.resolve();
        const botoes = el.shadowRoot.querySelectorAll('button[data-tipo]');
        expect(botoes.length).toBe(2);
        expect(el.shadowRoot.textContent).toContain('4 plásticos');
    });

    it('publica PRODUCT_SELECTED ao selecionar (P7)', async () => {
        const el = createElement('c-product-hub', { is: ProductHub });
        el.produtos = PRODUTOS;
        document.body.appendChild(el);
        await Promise.resolve();
        el.shadowRoot.querySelector('button[data-tipo="CARTAO"]').click();
        expect(publish).toHaveBeenCalledWith(
            undefined,
            expect.anything(),
            expect.objectContaining({ type: 'PRODUCT_SELECTED', productType: 'CARTAO' })
        );
    });

    it('exibe estado vazio sem erro quando sem vínculos (Cen 9)', async () => {
        const el = createElement('c-product-hub', { is: ProductHub });
        el.produtos = [];
        document.body.appendChild(el);
        await Promise.resolve();
        expect(el.shadowRoot.textContent).toContain('não possui vínculos ativos');
        expect(el.shadowRoot.querySelectorAll('button[data-tipo]').length).toBe(0);
    });
});
