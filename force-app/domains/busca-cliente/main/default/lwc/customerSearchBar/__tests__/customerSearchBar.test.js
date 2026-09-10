import { createElement } from 'lwc';
import CustomerSearchBar from 'c/customerSearchBar';
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

function typeInto(input, value) {
    input.value = value;
    input.dispatchEvent(new CustomEvent('keyup', { key: 'x' }));
}

describe('c-customer-search-bar', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('mantém Localizar desabilitado com CPF inválido (Cen 4, EL-01)', async () => {
        const el = createElement('c-customer-search-bar', { is: CustomerSearchBar });
        document.body.appendChild(el);
        const input = el.shadowRoot.querySelector('lightning-input');
        typeInto(input, '1234567899');
        await Promise.resolve();
        const btn = el.shadowRoot.querySelector('lightning-button');
        expect(btn.disabled).toBe(true);
    });

    it('habilita com CPF válido e publica CUSTOMER_SEARCH_TRIGGERED', async () => {
        const el = createElement('c-customer-search-bar', { is: CustomerSearchBar });
        document.body.appendChild(el);
        const input = el.shadowRoot.querySelector('lightning-input');
        typeInto(input, '52998224725');
        await Promise.resolve();
        const btn = el.shadowRoot.querySelector('lightning-button');
        expect(btn.disabled).toBe(false);
        btn.click();
        expect(publish).toHaveBeenCalledWith(
            undefined,
            expect.anything(),
            expect.objectContaining({ type: 'CUSTOMER_SEARCH_TRIGGERED', documentNormalized: '52998224725' })
        );
    });

    it('aceita CNPJ alfanumérico BACEN no modo PJ (Cen 3)', async () => {
        const el = createElement('c-customer-search-bar', { is: CustomerSearchBar });
        document.body.appendChild(el);
        el.tipoPessoa = 'PJ';
        await Promise.resolve();
        const input = el.shadowRoot.querySelector('lightning-input');
        typeInto(input, '12ABC34501DE35');
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('lightning-button').disabled).toBe(false);
    });

    it('exige 5+ caracteres no modo Protocolo (Cen 4)', async () => {
        const el = createElement('c-customer-search-bar', { is: CustomerSearchBar });
        document.body.appendChild(el);
        el.tipoPessoa = 'PROTOCOLO';
        await Promise.resolve();
        const input = el.shadowRoot.querySelector('lightning-input');
        typeInto(input, '1234');
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('lightning-button').disabled).toBe(true);
        typeInto(input, '12345');
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('lightning-button').disabled).toBe(false);
    });

    it('limpar() esvazia o campo e devolve o foco', async () => {
        const el = createElement('c-customer-search-bar', { is: CustomerSearchBar });
        document.body.appendChild(el);
        const input = el.shadowRoot.querySelector('lightning-input');
        typeInto(input, '52998224725');
        await Promise.resolve();
        el.limpar();
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('lightning-input').value).toBe('');
    });
});
