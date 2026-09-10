import { createElement } from '@lwc/engine-dom';
import Visao360Shell from 'c/visao360Shell';
import getVisao from '@salesforce/apex/Visao360Controller.getVisao';
import getAssets from '@salesforce/apex/Visao360Controller.getAssets';
import getOffers from '@salesforce/apex/Visao360Controller.getOffers';

jest.mock(
    'lightning/modal',
    () => ({
        __esModule: true,
        default: class ModalMock {
            static open = jest.fn();
            close = jest.fn();
        }
    }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/Visao360Controller.getVisao',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/Visao360Controller.getAssets',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/Visao360Controller.getOffers',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/Visao360Controller.rejectOffer',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/Visao360Controller.acceptOffer',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/Visao360Controller.resolveAccount',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

const VISAO = {
    header: { nome: 'João da Silva', tipoPessoa: 'Pessoa Física', segmento: 'Exclusivo', status: 'Ativo' },
    completude: '80%',
    aum: 'R$ 127.400,00',
    patrimonioHousehold: 'R$ 214.900,00',
    ativosFora: 'R$ 67.200,00',
    walletShare: '68%',
    scoreCredito: '872 (baixo risco)',
    eventosVida: [],
    tagsSegmentos: ['Exclusivo'],
    tagsInvestimentos: [],
    tagsEstilo: [],
    wellness: null,
    planejamento: null,
    fluxo: null,
    segmentacao: null,
    comportamento: null,
    campanhas: [],
    metas: [],
    tarefas: [],
    interacoes: [],
    acoes: [],
    arcResumo: [{ id: 'r', nome: 'João da Silva', papel: 'Titular', tipo: 'PF', doc: '12345678900', nivel: 0 }],
    arcCompleta: [],
    arcTotalVinculos: 1,
    casos: []
};

function montar() {
    const el = createElement('c-visao360-shell', { is: Visao360Shell });
    el.recordId = '001000000000001AAA';
    document.body.appendChild(el);
    return el;
}

async function estabilizar() {
    for (let i = 0; i < 10; i++) {
        // eslint-disable-next-line no-await-in-loop
        await Promise.resolve();
    }
    await new Promise((resolve) => setTimeout(resolve, 0));
}

describe('c-visao360-shell', () => {
    afterEach(() => {
        while (document.body.firstChild) document.body.removeChild(document.body.firstChild);
        jest.clearAllMocks();
    });

    it('carrega visão, ativos e NBO em paralelo sem travar (Cen 15, 17)', async () => {
        getVisao.mockResolvedValue(VISAO);
        getAssets.mockResolvedValue({ items: [], fault: null });
        getOffers.mockResolvedValue({ offers: [], motor: null, fault: null });
        const el = montar();
        await estabilizar();
        const shadow = el.shadowRoot;
        expect(shadow.querySelector('c-visao360-header')).not.toBeNull();
        // Sidebar fixa visível na aba inicial (Resumo).
        expect(shadow.querySelector('c-visao360-nbo')).not.toBeNull();
        expect(shadow.querySelector('c-visao360-tags')).not.toBeNull();
        // 6 subabas navegáveis.
        expect(shadow.querySelectorAll('.slds-tabs_default__item').length).toBe(6);
    });

    it('troca de aba mantém a sidebar com o mesmo estado (RN-16)', async () => {
        getVisao.mockResolvedValue(VISAO);
        getAssets.mockResolvedValue({ items: [], fault: null });
        getOffers.mockResolvedValue({ offers: [], motor: null, fault: null });
        const el = montar();
        await estabilizar();
        const shadow = el.shadowRoot;
        const abas = shadow.querySelectorAll('.slds-tabs_default__link');
        abas[2].click();
        await Promise.resolve();
        expect(shadow.querySelector('c-visao360-nbo')).not.toBeNull();
        expect(shadow.querySelector('c-visao360-ativos')).not.toBeNull();
    });

    it('exibe fault da visão sem travar a página (RN-07)', async () => {
        getVisao.mockResolvedValue({ fault: { message: 'Conta raiz sem documento.' } });
        getAssets.mockResolvedValue({ items: [], fault: null });
        getOffers.mockResolvedValue({ offers: [], motor: null, fault: null });
        const el = montar();
        await estabilizar();
        expect(el.shadowRoot.textContent).toContain('Conta raiz sem documento');
    });
});
