import { createElement } from 'lwc';
import HoldingStrip from 'c/holdingStrip';

describe('c-holding-strip', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('lista vínculos informativos sem ação transacional (Cen 8, RN-06)', async () => {
        const el = createElement('c-holding-strip', { is: HoldingStrip });
        el.holding = [
            { nome: 'Seguro Auto', detalhe: 'Apólice vigente', icone: 'utility:truck' },
            { nome: 'Plano de Saúde', detalhe: 'Titular + 2 dependentes', icone: 'utility:co_insurance' }
        ];
        document.body.appendChild(el);
        await Promise.resolve();
        expect(el.shadowRoot.textContent).toContain('Seguro Auto');
        expect(el.shadowRoot.textContent).toContain('somente leitura');
        expect(el.shadowRoot.querySelectorAll('button').length).toBe(0);
    });
});
