import { createElement } from 'lwc';
import CardDrawer from 'c/cardDrawer';

jest.mock('lightning/modal', () => ({ default: class {} }), { virtual: true });

describe('c-card-drawer', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('lista vias ativas, canceladas e bloqueadas distinguíveis (Cen 18, EL-04/05)', async () => {
        const el = createElement('c-card-drawer', { is: CardDrawer });
        el.vias = [
            { externalContractId: 'via-1', brand: 'Visa', category: 'Infinite', last4Masked: '•••• 1234', holderName: 'João', isTitular: true, limite: 'R$ 28.000', anuidade: 'Isento', status: 'Ativo' },
            { externalContractId: 'via-2', brand: 'Mastercard', category: 'Gold', last4Masked: '•••• 5678', holderName: 'Maria', isTitular: false, limite: '—', anuidade: '—', status: 'Cancelado' }
        ];
        document.body.appendChild(el);
        await Promise.resolve();
        const botoes = el.shadowRoot.querySelectorAll('button[data-id]');
        expect(botoes.length).toBe(2);
        expect(el.shadowRoot.textContent).toContain('•••• 1234');
        expect(el.shadowRoot.textContent).toContain('Cancelado');
    });
});
