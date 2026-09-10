import { createElement } from '@lwc/engine-dom';
import Visao360Header from 'c/visao360Header';

const HEADER = {
    nome: 'João da Silva',
    tipoPessoa: 'Pessoa Física',
    documentoMascarado: '***.***.***-00',
    segmento: 'Exclusivo',
    status: 'Ativo',
    telefone: '(11) 99999-1234',
    email: 'joao.silva@email.com',
    clienteDesde: '03/02/2018',
    estadoCivil: 'Casado',
    filhos: '2',
    rating: '872',
    responsavel: 'Ricardo Alves',
    necessidade: 'Investimentos',
    jornada: 'Casa própria',
    canais: ['Telefone', 'E-mail'],
    perfilEndereco: 'Rua das Flores, 123',
    perfilAgenciaConta: 'Ag 0001 • C/C 12345-6'
};

describe('c-visao360-header', () => {
    afterEach(() => {
        while (document.body.firstChild) document.body.removeChild(document.body.firstChild);
    });

    it('renderiza 3 colunas com selos e avatar (Cen 2, 18)', async () => {
        const el = createElement('c-visao360-header', { is: Visao360Header });
        el.header = HEADER;
        el.completude = '80%';
        document.body.appendChild(el);
        await Promise.resolve();
        const shadow = el.shadowRoot;
        expect(shadow.querySelector('.c-cabecalho_nome').textContent).toBe('João da Silva');
        expect(shadow.querySelector('.c-selo_ouro').textContent).toBe('Exclusivo');
        expect(shadow.querySelector('.c-selo_verde').textContent).toBe('Ativo');
        expect(shadow.querySelector('.c-avatar').textContent).toBe('RA');
        expect(shadow.textContent).toContain('80%');
    });
});
