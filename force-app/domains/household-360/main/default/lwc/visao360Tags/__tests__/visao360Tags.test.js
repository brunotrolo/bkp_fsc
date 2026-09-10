import { createElement } from '@lwc/engine-dom';
import Visao360Tags from 'c/visao360Tags';

function montar() {
    const el = createElement('c-visao360-tags', { is: Visao360Tags });
    el.segmentos = ['Exclusivo', 'Top 50'];
    el.investimentos = ['Renda fixa'];
    el.estilo = ['Viagens'];
    document.body.appendChild(el);
    return el;
}

describe('c-visao360-tags', () => {
    afterEach(() => {
        while (document.body.firstChild) document.body.removeChild(document.body.firstChild);
    });

    it('filtra por busca e remove localmente (Cen 19)', async () => {
        const el = montar();
        await Promise.resolve();
        expect(el.shadowRoot.querySelectorAll('lightning-pill').length).toBe(4);
        const busca = el.shadowRoot.querySelector('.c-tags_busca-texto');
        busca.value = 'renda';
        busca.dispatchEvent(new CustomEvent('change'));
        await Promise.resolve();
        expect(el.shadowRoot.querySelectorAll('lightning-pill').length).toBe(1);
    });

    it('mostra vazio discreto sem tags', async () => {
        const el = createElement('c-visao360-tags', { is: Visao360Tags });
        document.body.appendChild(el);
        await Promise.resolve();
        expect(el.shadowRoot.textContent).toContain('Sem tags para esta raiz');
    });
});
