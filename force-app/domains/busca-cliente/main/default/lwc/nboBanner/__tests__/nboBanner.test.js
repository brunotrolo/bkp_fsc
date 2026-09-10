import { createElement } from 'lwc';
import NboBanner from 'c/nboBanner';

const OFERTA = {
    id: 'nbo-black',
    produto: 'Cartão Black',
    titulo: 'Oportunidade identificada: Cartão Black',
    narrativa: 'Cliente elegível para upgrade.',
    beneficio: 'Isenção de anuidade no 1º ano',
    beneficios: ['Isenção total da anuidade no 1º ano', 'Sala VIP'],
    bandeiras: [{ nome: 'Visa Infinite', logo: 'utility:card_details' }],
    limites: 'Limite pré-aprovado de R$ 15.000 a R$ 50.000',
    anuidade: '12x de R$ 98,00 — isento no 1º ano',
    estado: 'identificada'
};

describe('c-nbo-banner', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('exibe narrativa completa com ações Abordar/Dispensar (Cen 11)', async () => {
        const el = createElement('c-nbo-banner', { is: NboBanner });
        el.ofertaAtiva = OFERTA;
        document.body.appendChild(el);
        await Promise.resolve();
        expect(el.shadowRoot.textContent).toContain('Cartão Black');
        expect(el.shadowRoot.textContent).toContain('Sala VIP');
        const labels = [...el.shadowRoot.querySelectorAll('lightning-button')].map((b) => b.label);
        expect(labels).toEqual(expect.arrayContaining(['Abordar venda', 'Dispensar']));
    });

    it('emite abordar ao clicar em Abordar venda (Cen 14)', async () => {
        const el = createElement('c-nbo-banner', { is: NboBanner });
        el.ofertaAtiva = OFERTA;
        document.body.appendChild(el);
        await Promise.resolve();
        const handler = jest.fn();
        el.addEventListener('abordar', handler);
        el.shadowRoot.querySelector('lightning-button').click();
        expect(handler).toHaveBeenCalledTimes(1);
    });

    it('recolhe sem ocupar espaço quando sem oferta (Cen 12)', async () => {
        const el = createElement('c-nbo-banner', { is: NboBanner });
        el.ofertaAtiva = null;
        document.body.appendChild(el);
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('.c-nbo-card')).toBeNull();
    });

    it('informa dispensa com confirmação discreta (Cen 15)', async () => {
        const el = createElement('c-nbo-banner', { is: NboBanner });
        el.ofertaAtiva = null;
        el.mostrarOfertaDispensada = true;
        document.body.appendChild(el);
        await Promise.resolve();
        expect(el.shadowRoot.textContent).toContain('dispensada');
    });
});
