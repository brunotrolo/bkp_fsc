import { createElement } from 'lwc';
import InvestimentoDrawer from 'c/investimentoDrawer';

jest.mock('lightning/modal', () => ({ default: class {} }), { virtual: true });

describe('c-investimento-drawer', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('lista posições com rentabilidade, vencimento e risco (Cen 17/18)', async () => {
        const el = createElement('c-investimento-drawer', { is: InvestimentoDrawer });
        el.investimentos = [
            { externalContractId: 'inv-1', classe: 'Renda Fixa', produto: 'CDB Porto Bank', valor: 'R$ 18.000', rentabilidade: '+11,2% a.a.', vencimento: 'Vence em 12/2027', risco: 'Baixo' }
        ];
        document.body.appendChild(el);
        await Promise.resolve();
        expect(el.shadowRoot.querySelectorAll('button[data-id]').length).toBe(1);
        expect(el.shadowRoot.textContent).toContain('Risco: Baixo');
    });
});
