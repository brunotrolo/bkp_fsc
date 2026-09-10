import { createElement } from 'lwc';
import CustomerSearchShell from 'c/customerSearchShell';
import identifyCadastro from '@salesforce/apex/CustomerSearchController.identifyCadastro';
import fetchNboOffers from '@salesforce/apex/CustomerSearchController.fetchNboOffers';
import getCatalog from '@salesforce/apex/CustomerSearchController.getCatalog';

jest.mock(
    '@salesforce/apex/CustomerSearchController.identifyCadastro',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/CustomerSearchController.fetchNboOffers',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/CustomerSearchController.getCatalog',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    'lightning/messageService',
    () => {
        let handler = null;
        return {
            MessageContext: jest.fn(),
            publish: jest.fn(),
            subscribe: jest.fn((ctx, ch, cb) => {
                handler = cb;
                return {};
            }),
            unsubscribe: jest.fn(),
            createMessageContext: jest.fn(),
            releaseMessageContext: jest.fn(),
            __emit: (msg) => handler && handler(msg)
        };
    },
    { virtual: true }
);

const DTO = {
    documentNormalized: '52998224725',
    documentMasked: '529.982.247-25',
    docType: 'CPF',
    demographic: { nome: 'João', tipoPessoa: 'Pessoa Física', documentoFormatado: '529.982.247-25', segmento: 'Exclusivo' },
    portoBankWallet: [{ productType: 'CONTA_DIGITAL', label: 'Conta Digital', quantidade: 1, resumo: 'Ativa', iconName: 'custom:custom16', exigeSubselecao: false }],
    holdingWallet: [],
    nboOffers: [],
    partialFaults: []
};

describe('c-customer-search-shell', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('orquestra busca paralela e libera hub sem oferta (Cen 12, 21)', async () => {
        identifyCadastro.mockResolvedValue(DTO);
        fetchNboOffers.mockResolvedValue([]);
        getCatalog.mockResolvedValue([]);
        const messageService = require('lightning/messageService');
        const el = createElement('c-customer-search-shell', { is: CustomerSearchShell });
        document.body.appendChild(el);
        messageService.__emit({ type: 'CUSTOMER_SEARCH_TRIGGERED', modo: 'PF', documentNormalized: '52998224725' });
        await new Promise((resolve) => { setTimeout(resolve, 0); });
        await Promise.resolve();
        expect(identifyCadastro).toHaveBeenCalled();
        expect(fetchNboOffers).toHaveBeenCalled();
        expect(el.shadowRoot.querySelector('c-product-hub')).not.toBeNull();
    });

    it('bloqueia hub com aviso até decidir a oferta (gate, Cen 11)', async () => {
        identifyCadastro.mockResolvedValue(DTO);
        fetchNboOffers.mockResolvedValue([
            { externalOfferId: 'nbo-1', productType: 'CARTAO', titulo: 'Black', narrativa: 'N', beneficio: 'B', beneficios: [], bandeiras: [], limites: 'L', anuidade: 'A', isPrimary: true, stage: 'Elegivel' }
        ]);
        getCatalog.mockResolvedValue([]);
        const messageService = require('lightning/messageService');
        const el = createElement('c-customer-search-shell', { is: CustomerSearchShell });
        document.body.appendChild(el);
        messageService.__emit({ type: 'CUSTOMER_SEARCH_TRIGGERED', modo: 'PF', documentNormalized: '52998224725' });
        await new Promise((resolve) => { setTimeout(resolve, 0); });
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('c-product-hub')).toBeNull();
        expect(el.shadowRoot.textContent).toContain('Abordar venda');
    });
});
