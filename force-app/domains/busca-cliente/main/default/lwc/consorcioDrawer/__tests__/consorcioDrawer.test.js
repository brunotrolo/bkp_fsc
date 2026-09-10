import { createElement } from 'lwc';
import ConsorcioDrawer from 'c/consorcioDrawer';

jest.mock('lightning/modal', () => ({ default: class {} }), { virtual: true });

describe('c-consorcio-drawer', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('lista cotas com grupo, valor e contemplação (Cen 17/18)', async () => {
        const el = createElement('c-consorcio-drawer', { is: ConsorcioDrawer });
        el.cotas = [
            { externalContractId: 'cota-1', tipo: 'Rural', grupo: '9012', cota: '007', valor: 'R$ 220.000', contemplacao: 'Não contemplada', parcela: 'R$ 980/mês', status: 'Ativa' },
            { externalContractId: 'cota-2', tipo: 'Rural', grupo: '9012', cota: '008', valor: 'R$ 220.000', contemplacao: 'Não contemplada', parcela: 'R$ 980/mês', status: 'Ativa' }
        ];
        document.body.appendChild(el);
        await Promise.resolve();
        expect(el.shadowRoot.querySelectorAll('button[data-id]').length).toBe(2);
        expect(el.shadowRoot.textContent).toContain('Grupo 9012');
    });
});
