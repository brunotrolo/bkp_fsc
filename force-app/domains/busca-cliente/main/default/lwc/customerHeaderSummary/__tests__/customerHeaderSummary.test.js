import { createElement } from 'lwc';
import CustomerHeaderSummary from 'c/customerHeaderSummary';

const CLIENTE = {
    nome: 'João da Silva',
    tipoPessoa: 'Pessoa Física',
    documentoFormatado: '123.456.789-00',
    segmento: 'Exclusivo',
    email: 'joao@email.com',
    telefone: '(11) 99999-1234',
    celular: '(11) 98888-5678',
    endereco: 'Rua das Flores, 123',
    cep: '01234-567',
    renda: 'R$ 18.500',
    score: 'Score 872 — Baixo risco',
    agencia: '0001',
    conta: '12345-6',
    tempoRelacionamento: 'Cliente há 8 anos',
    statusCadastro: 'Cadastro atualizado'
};

describe('c-customer-header-summary', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renderiza cartão enriquecido com contato, endereço e renda (Cen 6)', async () => {
        const el = createElement('c-customer-header-summary', { is: CustomerHeaderSummary });
        el.cliente = CLIENTE;
        document.body.appendChild(el);
        await Promise.resolve();
        const texto = el.shadowRoot.textContent;
        expect(texto).toContain('João da Silva');
        expect(texto).toContain('123.456.789-00');
        expect(texto).toContain('joao@email.com');
        expect(texto).toContain('R$ 18.500');
        expect(texto).toContain('01234-567');
    });
});
