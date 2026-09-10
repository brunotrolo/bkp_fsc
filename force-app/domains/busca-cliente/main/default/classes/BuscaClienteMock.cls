/**
 * @description Provider de fixtures do modo mock (busca-cliente/001).
 * Espelha prototype/data/buscaCliente/buscaCliente.js validado com o negocio.
 * Ativo somente com BuscaClienteMock__c de nivel org marcado (default OFF,
 * entao testes existentes e operacao real passam longe).
 * Docs demo: 12345678900 (Joao, full+NBO), 12ABC345000190 (PJ sem ofertas),
 * 11111111111 (só Holding), 99999999999 (NBO parcial); demais docs = nao-encontrado.
 */
public with sharing class BuscaClienteMock {

    public static final String DOC_JOAO = '12345678909';
    public static final String DOC_PJ = '12ABC345000190';
    public static final String DOC_SO_HOLDING = '98765432100';
    public static final String DOC_NBO_PARCIAL = '11144477735';

    /** Chave mestra: sem registro de CS, getInstance devolve o default (false). */
    public static Boolean isEnabled() {
        BuscaClienteMock__c cfg = BuscaClienteMock__c.getInstance();
        return cfg != null && cfg.UsarMock__c == true;
    }

    public static Boolean isKnown(String normalizedDoc) {
        return normalizedDoc == DOC_JOAO || normalizedDoc == DOC_PJ
            || normalizedDoc == DOC_SO_HOLDING || normalizedDoc == DOC_NBO_PARCIAL;
    }

    // =================================================================
    // Cadastro + Holding
    // =================================================================

    public static CadastroService.CadastroResult mockCadastro(String normalizedDoc) {
        CadastroService.CadastroResult result = new CadastroService.CadastroResult();
        if (!isKnown(normalizedDoc)) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(
                'MOCK', 'NOT_FOUND', 'Nenhum cadastro localizado para o documento.');
            return result;
        }
        result.demographic = mockDemographic(normalizedDoc);
        result.wallet = mockWallet(normalizedDoc);
        return result;
    }

    public static HoldingService.HoldingResult mockHolding(String normalizedDoc) {
        HoldingService.HoldingResult result = new HoldingService.HoldingResult();
        for (HoldingRow row : holdingRows(normalizedDoc)) {
            BuscaClienteDTOs.HoldingDTO h = new BuscaClienteDTOs.HoldingDTO();
            h.nome = row.nome;
            h.detalhe = row.detalhe;
            h.icone = row.icone;
            result.items.add(h);
        }
        return result;
    }

    private static BuscaClienteDTOs.DemographicDTO mockDemographic(String doc) {
        BuscaClienteDTOs.DemographicDTO d = new BuscaClienteDTOs.DemographicDTO();
        if (doc == DOC_JOAO) {
            d.nome = 'João da Silva';
            d.tipoPessoa = 'Pessoa Física';
            d.documentoFormatado = '123.456.789-09';
            d.segmento = 'Exclusivo';
            d.email = 'joao.silva@email.com';
            d.telefone = '(11) 99999-1234';
            d.celular = '(11) 98888-5678';
            d.nascimento = '12/03/1985 • 40 anos';
            d.endereco = 'Rua das Flores, 123 — Jardins, São Paulo/SP';
            d.cep = '01234-567';
            d.renda = 'R$ 18.500';
            d.agencia = '0001 — Jardins';
            d.conta = '12345-6';
            d.tempoRelacionamento = 'Cliente há 8 anos';
            d.statusCadastro = 'Cadastro atualizado em 15/08/2026';
            d.score = 'Score interno 872 — Baixo risco';
        } else if (doc == DOC_PJ) {
            d.nome = 'Indústria Exemplo S.A.';
            d.tipoPessoa = 'Pessoa Jurídica';
            d.documentoFormatado = '12.ABC.345/0001-90';
            d.segmento = 'Empresarial';
        } else if (doc == DOC_SO_HOLDING) {
            d.nome = 'Maria Oliveira';
            d.tipoPessoa = 'Pessoa Física';
            d.documentoFormatado = '987.654.321-00';
            d.segmento = 'Varejo';
        } else if (doc == DOC_NBO_PARCIAL) {
            d.nome = 'Carlos Souza';
            d.tipoPessoa = 'Pessoa Física';
            d.documentoFormatado = '111.444.777-35';
            d.segmento = 'Varejo';
        }
        return d;
    }

    private static List<BuscaClienteDTOs.ProductSummaryDTO> mockWallet(String doc) {
        List<BuscaClienteDTOs.ProductSummaryDTO> wallet = new List<BuscaClienteDTOs.ProductSummaryDTO>();
        if (doc == DOC_JOAO) {
            wallet.add(summary('CARTAO', 'Cartão de Crédito', 4, '4 plásticos', 'utility:card_details', true));
            wallet.add(summary('CONTA_DIGITAL', 'Conta Digital', 1, 'Ativa • Ag 0001', 'custom:custom16', false));
            wallet.add(summary('CONSORCIO', 'Consórcio', 6, '6 cotas • Imóvel, Veículo e Rural', 'utility:contract_doc', true));
            wallet.add(summary('INVESTIMENTOS', 'Investimentos', 5, '5 posições • Renda fixa, CDB e fundos', 'standard:investment_account', true));
        } else if (doc == DOC_PJ) {
            wallet.add(summary('CONTA_DIGITAL', 'Conta Digital', 1, 'Ativa', 'custom:custom16', false));
            wallet.add(summary('INVESTIMENTOS', 'Investimentos', 1, 'R$ 120.000', 'standard:investment_account', false));
        } else if (doc == DOC_NBO_PARCIAL) {
            wallet.add(summary('CONTA_DIGITAL', 'Conta Digital', 1, 'Ativa', 'custom:custom16', false));
        }
        return wallet;
    }

    private static BuscaClienteDTOs.ProductSummaryDTO summary(
        String type, String label, Integer qtd, String resumo, String icone, Boolean subselecao
    ) {
        BuscaClienteDTOs.ProductSummaryDTO s = new BuscaClienteDTOs.ProductSummaryDTO();
        s.productType = type;
        s.label = label;
        s.quantidade = qtd;
        s.resumo = resumo;
        s.iconName = icone;
        s.exigeSubselecao = subselecao;
        s.holdingInformativo = false;
        return s;
    }

    private class HoldingRow {
        String nome;
        String detalhe;
        String icone;
        HoldingRow(String nome, String detalhe, String icone) {
            this.nome = nome;
            this.detalhe = detalhe;
            this.icone = icone;
        }
    }

    private static List<HoldingRow> holdingRows(String doc) {
        List<HoldingRow> rows = new List<HoldingRow>();
        if (doc == DOC_JOAO) {
            rows.add(new HoldingRow('Seguro Auto', 'Apólice vigente • Cobertura completa', 'utility:truck'));
            rows.add(new HoldingRow('Seguro Residencial', 'Apólice vigente • Incêndio e roubo', 'utility:home'));
            rows.add(new HoldingRow('Seguro de Vida', 'Capital segurado R$ 250.000', 'utility:people'));
            rows.add(new HoldingRow('Plano de Saúde', 'Titular + 2 dependentes • Rede premium', 'utility:co_insurance'));
            rows.add(new HoldingRow('Plano Odontológico', 'Titular • Cobertura nacional', 'utility:like'));
            rows.add(new HoldingRow('Previdência Privada', 'PGBL • Aporte mensal R$ 800', 'utility:money'));
        } else if (doc == DOC_PJ) {
            rows.add(new HoldingRow('Seguro Auto', 'Apólice vigente • Cobertura completa • PJ', 'utility:truck'));
            rows.add(new HoldingRow('Seguro Residencial', 'Apólice vigente • Incêndio e roubo • PJ', 'utility:home'));
        } else if (doc == DOC_SO_HOLDING) {
            rows.add(new HoldingRow('Seguro Auto', 'Apólice vigente • Cobertura completa', 'utility:truck'));
            rows.add(new HoldingRow('Seguro Residencial', 'Apólice vigente • Incêndio e roubo', 'utility:home'));
            rows.add(new HoldingRow('Seguro de Vida', 'Capital segurado R$ 250.000', 'utility:people'));
            rows.add(new HoldingRow('Plano de Saúde', 'Titular + 2 dependentes • Rede premium', 'utility:co_insurance'));
        } else if (doc == DOC_NBO_PARCIAL) {
            rows.add(new HoldingRow('Seguro Auto', 'Apólice vigente • Cobertura completa', 'utility:truck'));
        }
        return rows;
    }

    // =================================================================
    // NBO
    // =================================================================

    public static NboService.NboResult mockNbo(String normalizedDoc) {
        NboService.NboResult result = new NboService.NboResult();
        if (normalizedDoc == DOC_NBO_PARCIAL) {
            result.fault = new BuscaClienteDTOs.ApiFaultDTO(
                'MOCK', 'NBO_UNAVAILABLE', 'Motor de ofertas indisponível no cenário mock.');
            return result;
        }
        if (normalizedDoc == DOC_JOAO) {
            BuscaClienteDTOs.NboOfferDTO offer = new BuscaClienteDTOs.NboOfferDTO();
            offer.externalOfferId = 'nbo-black';
            offer.productType = 'CARTAO';
            offer.titulo = 'Oportunidade identificada: Cartão Black Porto Bank';
            offer.narrativa = 'Cliente elegível para upgrade para o Cartão Black — isento de anuidade no 1º ano e com benefícios exclusivos de concierge, sala VIP e cashback ampliado.';
            offer.beneficio = 'Isenção de anuidade no 1º ano';
            offer.beneficios = new List<String>{
                'Isenção total da anuidade no 1º ano',
                'Acesso a salas VIP LoungeKey + concierge 24h',
                'Cashback de 1,5% em todas as compras'
            };
            offer.bandeiras = new List<String>{ 'Visa Infinite', 'Mastercard Black' };
            offer.limites = 'Limite pré-aprovado de R$ 15.000 a R$ 50.000 (sujeito a análise)';
            offer.anuidade = '12x de R$ 98,00 — isento no 1º ano';
            offer.isPrimary = true;
            offer.stage = 'Elegivel';
            result.offers.add(offer);
        }
        return result;
    }

    // =================================================================
    // Contexto de interação (sem banco: compõe o resumo dos fixtures)
    // =================================================================

    public static String mockContextResumo(String normalizedDoc, String productType, String itemExternalId) {
        CadastroService.CadastroResult cadastro = mockCadastro(normalizedDoc);
        if (cadastro.demographic == null) {
            return 'Cliente ainda nao consolidado para o documento informado.';
        }
        String resumo = cadastro.demographic.nome + ' + ' + labelProduto(productType);
        String detalhe = detalheItem(productType, itemExternalId);
        if (!String.isBlank(detalhe)) {
            resumo += ' + ' + detalhe;
        }
        return resumo;
    }

    private static String labelProduto(String productType) {
        if (productType == 'CARTAO') {
            return 'Cartão de Crédito';
        }
        if (productType == 'CONTA_DIGITAL') {
            return 'Conta Digital';
        }
        if (productType == 'CONSORCIO') {
            return 'Consórcio';
        }
        if (productType == 'INVESTIMENTOS') {
            return 'Investimentos';
        }
        return String.isBlank(productType) ? 'produto' : productType;
    }

    private static String detalheItem(String productType, String itemExternalId) {
        if (String.isBlank(itemExternalId)) {
            return '';
        }
        if (productType == 'CARTAO') {
            for (BuscaClienteDTOs.CardViaDTO v : mockVias().vias) {
                if (v.externalContractId == itemExternalId) {
                    return v.brand + ' ' + v.category + ' ' + v.last4Masked + ' (' + v.holderName + ')';
                }
            }
        } else if (productType == 'CONSORCIO') {
            for (BuscaClienteDTOs.ConsorcioCotaDTO c : mockCotas().cotas) {
                if (c.externalContractId == itemExternalId) {
                    return 'Consórcio ' + c.tipo + ' grupo ' + c.grupo + ' cota ' + c.cota;
                }
            }
        } else if (productType == 'INVESTIMENTOS') {
            for (BuscaClienteDTOs.InvestimentoPosicaoDTO p : mockPosicoes().posicoes) {
                if (p.externalContractId == itemExternalId) {
                    return p.produto + ' ' + p.valor;
                }
            }
        }
        return itemExternalId;
    }

    // =================================================================
    // Lazy: vias, cotas, posições (independem do doc no mock)
    // =================================================================

    public static CardService.CardResult mockVias() {
        CardService.CardResult result = new CardService.CardResult();
        result.vias.add(via('via-1234', 'Visa', 'Infinite', '•••• 1234', 'João da Silva', true, 'R$ 28.000', 'Isento', 'Ativo'));
        result.vias.add(via('via-5678', 'Mastercard', 'Platinum', '•••• 5678', 'João da Silva', true, '—', '—', 'Cancelado'));
        result.vias.add(via('via-9012', 'Visa', 'Gold', '•••• 9012', 'Maria da Silva', false, 'R$ 8.000', '12x R$ 32,00', 'Ativo'));
        result.vias.add(via('via-3456', 'Mastercard', 'Black', '•••• 3456', 'João da Silva', true, 'R$ 42.000', '12x R$ 98,00', 'Bloqueado'));
        return result;
    }

    private static BuscaClienteDTOs.CardViaDTO via(
        String id, String brand, String category, String last4, String holder,
        Boolean titular, String limite, String anuidade, String status
    ) {
        BuscaClienteDTOs.CardViaDTO v = new BuscaClienteDTOs.CardViaDTO();
        v.externalContractId = id;
        v.brand = brand;
        v.category = category;
        v.last4Masked = last4;
        v.holderName = holder;
        v.isTitular = titular;
        v.limite = limite;
        v.anuidade = anuidade;
        v.status = status;
        return v;
    }

    public static ConsorcioService.ConsorcioResult mockCotas() {
        ConsorcioService.ConsorcioResult result = new ConsorcioService.ConsorcioResult();
        result.cotas.add(cota('cota-imovel-001', 'Imóvel', '1234', '045', 'R$ 350.000', 'Não contemplada', 'R$ 1.420/mês', 'Ativa'));
        result.cotas.add(cota('cota-veiculo-002', 'Veículo', '5678', '012', 'R$ 85.000', 'Contemplada', 'R$ 680/mês', 'Ativa'));
        result.cotas.add(cota('cota-rural-003', 'Rural', '9012', '007', 'R$ 220.000', 'Não contemplada', 'R$ 980/mês', 'Ativa'));
        result.cotas.add(cota('cota-rural-004', 'Rural', '9012', '008', 'R$ 220.000', 'Não contemplada', 'R$ 980/mês', 'Ativa'));
        result.cotas.add(cota('cota-imovel-005', 'Imóvel', '1234', '089', 'R$ 500.000', 'Contemplada', 'R$ 2.100/mês', 'Ativa'));
        result.cotas.add(cota('cota-veiculo-006', 'Veículo', '5678', '034', 'R$ 120.000', '—', '—', 'Cancelada'));
        return result;
    }

    private static BuscaClienteDTOs.ConsorcioCotaDTO cota(
        String id, String tipo, String grupo, String cota, String valor, String contemplacao, String parcela, String status
    ) {
        BuscaClienteDTOs.ConsorcioCotaDTO c = new BuscaClienteDTOs.ConsorcioCotaDTO();
        c.externalContractId = id;
        c.tipo = tipo;
        c.grupo = grupo;
        c.cota = cota;
        c.valor = valor;
        c.contemplacao = contemplacao;
        c.parcela = parcela;
        c.status = status;
        return c;
    }

    public static InvestimentoService.InvestimentoResult mockPosicoes() {
        InvestimentoService.InvestimentoResult result = new InvestimentoService.InvestimentoResult();
        result.posicoes.add(posicao('inv-rf-001', 'Renda Fixa', 'CDB Porto Bank', 'R$ 18.000', '+11,2% a.a.', 'Vence em 12/2027', 'Baixo'));
        result.posicoes.add(posicao('inv-rf-002', 'Renda Fixa', 'Tesouro Direto Selic 2029', 'R$ 9.500', 'Selic + 0,1% a.a.', 'Vence em 03/2029', 'Baixo'));
        result.posicoes.add(posicao('inv-cdb-003', 'CDB', 'CDB Prefixado 2 anos', 'R$ 6.000', '12,4% a.a.', 'Vence em 06/2027', 'Baixo'));
        result.posicoes.add(posicao('inv-rv-004', 'Renda Variável', 'Fundo de Ações Dividendos', 'R$ 5.200', '+18,3% em 12m', 'Resgate D+2', 'Alto'));
        result.posicoes.add(posicao('inv-fundo-005', 'Fundos', 'Fundo Multimercado Equilíbrio', 'R$ 3.300', '+9,6% em 12m', 'Resgate D+1', 'Moderado'));
        return result;
    }

    private static BuscaClienteDTOs.InvestimentoPosicaoDTO posicao(
        String id, String classe, String produto, String valor, String rentabilidade, String vencimento, String risco
    ) {
        BuscaClienteDTOs.InvestimentoPosicaoDTO p = new BuscaClienteDTOs.InvestimentoPosicaoDTO();
        p.externalContractId = id;
        p.classe = classe;
        p.produto = produto;
        p.valor = valor;
        p.rentabilidade = rentabilidade;
        p.vencimento = vencimento;
        p.risco = risco;
        return p;
    }
}
