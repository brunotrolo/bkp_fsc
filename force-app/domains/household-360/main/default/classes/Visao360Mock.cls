/**
 * @description Provider de fixtures do modo mock (household-360/001).
 * Espelha prototype/data/visao360/visao360.js validado com o negocio.
 * Ativo somente com Visao360Mock__c de nivel org marcado (default OFF,
 * entao testes existentes e operacao real passam longe). Flag PROPRIA deste
 * dominio: nunca le BuscaClienteMock__c.
 * Docs demo: 12345678900 (Joao PF completo + NBO top 3),
 * 12ABC345000190 (Industria PJ, sem ofertas), 11111111111 (Maria, so conta),
 * 99999999999 (Carlos, NBO fora na 1a carga -> retry); demais = nao-encontrado.
 * Em mock: NENHUM DML de fixture como dado real (só o seed versionado insere).
 */
public with sharing class Visao360Mock {

    public static final String DOC_JOAO = '12345678900';
    public static final String DOC_INDUSTRIA = '12ABC345000190';
    public static final String DOC_MARIA = '11111111111';
    public static final String DOC_CARLOS = '99999999999';

    /** Chave mestra: sem registro de CS, getInstance devolve o default (false). */
    public static Boolean isEnabled() {
        Visao360Mock__c cfg = Visao360Mock__c.getInstance();
        return cfg != null && cfg.UsarMock__c == true;
    }

    public static Boolean isKnown(String normalizedDoc) {
        return normalizedDoc == DOC_JOAO || normalizedDoc == DOC_INDUSTRIA
            || normalizedDoc == DOC_MARIA || normalizedDoc == DOC_CARLOS;
    }

    public static String normalizeDoc(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        return value.toUpperCase().replaceAll('[^A-Z0-9]', '');
    }

    // =================================================================
    // Cabecalho (P1/P2)
    // =================================================================

    public static Visao360DTOs.HeaderDTO mockHeader(String normalizedDoc) {
        if (!isKnown(normalizedDoc)) {
            return null;
        }
        Visao360DTOs.HeaderDTO h = new Visao360DTOs.HeaderDTO();
        if (normalizedDoc == DOC_JOAO) {
            h.nome = 'João da Silva';
            h.tipoPessoa = 'Pessoa Física';
            h.documentoMascarado = '***.***.***-00';
            h.segmento = 'Exclusivo';
            h.status = 'Ativo';
            h.telefone = '(11) 99999-1234';
            h.email = 'joao.silva@email.com';
            h.clienteDesde = '03/02/2018';
            h.estadoCivil = 'Casado';
            h.filhos = '2';
            h.rating = '872';
            h.responsavel = 'Ricardo Alves';
            h.necessidade = 'Investimentos';
            h.jornada = 'Casa própria';
            h.canais = new List<String>{ 'Telefone', 'E-mail' };
            h.saldoConsolidado = 'R$ 127.400,00';
            h.perfilContato = 'joao.silva@email.com • (11) 99999-1234';
            h.perfilEndereco = 'Rua das Flores, 123 — Jardins, São Paulo/SP';
            h.perfilRendaScore = 'Renda R$ 18.500 • Score 872 (baixo risco)';
            h.perfilAgenciaConta = 'Ag 0001 • C/C 12345-6 • Cliente há 8 anos';
        } else if (normalizedDoc == DOC_INDUSTRIA) {
            h.nome = 'Indústria Exemplo S.A.';
            h.tipoPessoa = 'Pessoa Jurídica';
            h.documentoMascarado = '**.***.***/0001-90';
            h.segmento = 'Empresarial';
            h.status = 'Ativo';
            h.telefone = '(11) 3333-4444';
            h.email = 'financeiro@industriaexemplo.com.br';
            h.clienteDesde = '12/06/2021';
            h.estadoCivil = '—';
            h.filhos = '—';
            h.rating = '810';
            h.responsavel = 'Paula Mendes';
            h.necessidade = 'Capital de giro';
            h.jornada = 'Expansão';
            h.canais = new List<String>{ 'E-mail' };
            h.saldoConsolidado = 'R$ 460.900,00';
            h.perfilContato = 'financeiro@industriaexemplo.com.br • (11) 3333-4444';
            h.perfilEndereco = 'Av. Industrial, 1500 — Barueri/SP';
            h.perfilRendaScore = 'Faturamento R$ 2,4 mi/ano • Score 810';
            h.perfilAgenciaConta = 'Ag 0007 • C/C 98765-4 • Cliente há 5 anos';
        } else if (normalizedDoc == DOC_MARIA) {
            h.nome = 'Maria Oliveira';
            h.tipoPessoa = 'Pessoa Física';
            h.documentoMascarado = '***.***.***-11';
            h.segmento = 'Varejo';
            h.status = 'Ativo';
            h.telefone = '(11) 97777-8899';
            h.email = 'maria.oliveira@email.com';
            h.clienteDesde = '20/03/2024';
            h.estadoCivil = 'Solteira';
            h.filhos = '0';
            h.rating = '640';
            h.responsavel = 'Paula Mendes';
            h.necessidade = 'Conta do dia a dia';
            h.jornada = 'Reserva de emergência';
            h.canais = new List<String>{ 'E-mail' };
            h.saldoConsolidado = 'R$ 2.140,00';
            h.perfilContato = 'maria.oliveira@email.com • (11) 97777-8899';
            h.perfilEndereco = 'Rua Azul, 45 — Centro, São Paulo/SP';
            h.perfilRendaScore = 'Renda R$ 4.200 • Score 640';
            h.perfilAgenciaConta = 'Ag 0001 • C/C 54321-0 • Cliente há 2 anos';
        } else if (normalizedDoc == DOC_CARLOS) {
            h.nome = 'Carlos Souza';
            h.tipoPessoa = 'Pessoa Física';
            h.documentoMascarado = '***.***.***-99';
            h.segmento = 'Varejo';
            h.status = 'Ativo';
            h.telefone = '(11) 96666-7777';
            h.email = 'carlos.souza@email.com';
            h.clienteDesde = '10/01/2023';
            h.estadoCivil = 'Casado';
            h.filhos = '1';
            h.rating = '705';
            h.responsavel = 'Ricardo Alves';
            h.necessidade = 'Cartão de crédito';
            h.jornada = 'Troca de carro';
            h.canais = new List<String>{ 'E-mail' };
            h.saldoConsolidado = 'R$ 8.020,35';
            h.perfilContato = 'carlos.souza@email.com • (11) 96666-7777';
            h.perfilEndereco = 'Rua Verde, 78 — Moema, São Paulo/SP';
            h.perfilRendaScore = 'Renda R$ 7.900 • Score 705';
            h.perfilAgenciaConta = 'Ag 0003 • C/C 77777-7 • Cliente há 3 anos';
        }
        return h;
    }

    // =================================================================
    // Inventario (P4) — contractNumber = ExternalContractId__c do seed
    // =================================================================

    private static Visao360DTOs.AssetSummaryDTO ativo(
        String assetId, String contractNumber, String family, String label,
        String maskedId, String status, String numero, String valor,
        String encerramento, String ultimaMov, String rt
    ) {
        Visao360DTOs.AssetSummaryDTO a = new Visao360DTOs.AssetSummaryDTO();
        a.assetId = assetId;
        a.contractNumber = contractNumber;
        a.productFamily = family;
        a.label = label;
        a.maskedId = maskedId;
        a.status = status;
        a.numero = numero;
        a.valor = valor;
        a.encerramento = encerramento;
        a.ultimaMov = ultimaMov;
        a.recordTypeName = rt;
        return a;
    }

    public static List<Visao360DTOs.AssetSummaryDTO> mockAssets(String normalizedDoc) {
        List<Visao360DTOs.AssetSummaryDTO> items = new List<Visao360DTOs.AssetSummaryDTO>();
        if (normalizedDoc == DOC_JOAO) {
            items.add(ativo('cartao-joao-1234', 'CART-1234', 'CARTAO', 'Cartão Visa Infinite', 'final 1234 • Titular João', 'Ativo', '0012 3456 •• 1234', 'Limite R$ 28.000', 'Vence 10/09/2026', 'Fatura R$ 3.210,45', 'CreditCard'));
            items.add(ativo('cartao-joao-3456', 'CART-3456', 'CARTAO', 'Cartão Mastercard Black', 'final 3456 • Titular João', 'Bloqueado', '0012 3456 •• 3456', 'Limite R$ 42.000', 'Vence 10/09/2026', 'Fatura R$ 1.080,20', 'CreditCard'));
            items.add(ativo('cartao-joao-9012', 'CART-9012', 'CARTAO', 'Cartão Visa Gold', 'final 9012 • Adicional Maria', 'Cancelado', '0012 3456 •• 9012', '—', 'Cancelado em 05/2026', '—', 'CreditCard'));
            items.add(ativo('conta-joao-1', 'CONT-0001', 'CONTA', 'Conta Digital', 'Ag 0001 • C/C 12345-6', 'Ativo', 'Ag 0001 • C/C 12345-6', 'R$ 12.480,90', '—', 'Pix enviado hoje', 'DigitalAccount'));
            items.add(ativo('consorcio-joao-1', 'CONS-1234-045', 'CONSORCIO', 'Consórcio Imóvel', 'Grupo 1234 • Cota 045', 'Ativo', 'Grupo 1234 • Cota 045', 'Devedor R$ 212.400', '—', 'Parcela 09/2026 paga', 'Consortium'));
            items.add(ativo('consorcio-joao-2', 'CONS-5678-012', 'CONSORCIO', 'Consórcio Veículo', 'Grupo 5678 • Cota 012', 'Encerrado', 'Grupo 5678 • Cota 012', 'Quitado', 'Encerrado em 03/2024', '—', 'Consortium'));
            items.add(ativo('invest-joao-1', 'INV-88114', 'INVEST', 'CDB Porto Bank', 'Pós-fixado • 102% do CDI', 'Ativo', 'Conta 88114-2', 'R$ 18.000 • +11,2% a.a.', 'Vence em 12/2027', 'Aplicação R$ 2.000', 'Investment'));
            items.add(ativo('invest-joao-2', 'INV-77231', 'INVEST', 'Fundo de Ações Dividendos', 'Renda variável • +18,3% em 12m', 'Ativo', 'Conta 77231-9', 'R$ 5.200 • +18,3% em 12m', 'Resgate D+2', 'Rendimento R$ 310', 'Investment'));
        } else if (normalizedDoc == DOC_INDUSTRIA) {
            items.add(ativo('conta-industria-1', 'CONT-9876', 'CONTA', 'Conta Empresarial', 'Ag 0007 • C/C 98765-4', 'Ativo', 'Ag 0007 • C/C 98765-4', 'R$ 340.900,00', '—', 'TED recebida hoje', 'DigitalAccount'));
            items.add(ativo('invest-industria-1', 'INV-55021', 'INVEST', 'CDB Empresarial', '104% do CDI', 'Ativo', 'Conta 55021-8', 'R$ 120.000 • +11,8% a.a.', 'Vence em 06/2027', 'Rendimento R$ 1.180', 'Investment'));
        } else if (normalizedDoc == DOC_MARIA) {
            items.add(ativo('conta-maria-1', 'CONT-5432', 'CONTA', 'Conta Digital', 'Ag 0001 • C/C 54321-0', 'Ativo', 'Ag 0001 • C/C 54321-0', 'R$ 2.140,00', '—', 'Débito automático hoje', 'DigitalAccount'));
        } else if (normalizedDoc == DOC_CARLOS) {
            items.add(ativo('conta-carlos-1', 'CONT-7777', 'CONTA', 'Conta Digital', 'Ag 0003 • C/C 77777-7', 'Ativo', 'Ag 0003 • C/C 77777-7', 'R$ 8.020,35', '—', 'Salário creditado dia 05', 'DigitalAccount'));
        }
        return items;
    }

    // =================================================================
    // Detalhe volatil (P5) — falha deterministica do consorcio do Joao
    // na 1a tentativa; retry=true carrega na hora (Cen 9).
    // =================================================================

    public static Visao360DTOs.RealtimeResult mockRealtime(String contractNumber, String family, Boolean retry) {
        Visao360DTOs.RealtimeResult result = new Visao360DTOs.RealtimeResult();
        Boolean retried = retry == true;
        if (contractNumber == 'CONS-1234-045' && !retried) {
            result.fault = new Visao360DTOs.ApiFaultDTO(
                'NC_Visao360_Core', 'CORE_TIMEOUT', 'Core bancário demorou a responder (timeout simulado).');
            return result;
        }
        Visao360DTOs.AssetRealtimeDTO d = new Visao360DTOs.AssetRealtimeDTO();
        if (contractNumber == 'CART-1234') {
            d.tipo = 'CARTAO';
            d.limiteTotal = 'R$ 28.000';
            d.limiteDisponivel = 'R$ 19.450';
            d.faturaAtual = 'R$ 3.210,45';
            d.vencimento = '10/09/2026';
            d.melhorDiaCompra = 'dia 02';
        } else if (contractNumber == 'CART-3456') {
            d.tipo = 'CARTAO';
            d.limiteTotal = 'R$ 42.000';
            d.limiteDisponivel = 'R$ 0,00 (bloqueado)';
            d.faturaAtual = 'R$ 1.080,20';
            d.vencimento = '10/09/2026';
            d.melhorDiaCompra = 'dia 02';
            d.aviso = 'Bloqueio preventivo — oriente o cliente a contatar a central.';
        } else if (contractNumber == 'CART-9012') {
            d.tipo = 'CARTAO';
            d.limiteTotal = '—';
            d.limiteDisponivel = '—';
            d.faturaAtual = '—';
            d.vencimento = '—';
            d.melhorDiaCompra = '—';
            d.aviso = 'Cartão cancelado — dados cadastrais em leitura reduzida.';
        } else if (contractNumber == 'CONT-0001') {
            d.tipo = 'CONTA';
            d.saldo = 'R$ 12.480,90';
            d.agenciaConta = 'Ag 0001 • C/C 12345-6';
            d.chavesPix = new List<String>{ 'j***@email.com (e-mail)', '(11) *****-1234 (celular)', '***.***.***-00 (CPF)' };
        } else if (contractNumber == 'CONS-1234-045') {
            d.tipo = 'CONSORCIO';
            d.grupoCota = 'Grupo 1234 • Cota 045 (Imóvel)';
            d.saldoDevedor = 'R$ 212.400,00';
            d.parcela = 'R$ 1.420/mês';
            d.proximaAssembleia = '18/09/2026 às 19h';
            d.contemplacao = 'Não contemplada';
        } else if (contractNumber == 'CONS-5678-012') {
            d.tipo = 'CONSORCIO';
            d.grupoCota = 'Grupo 5678 • Cota 012 (Veículo)';
            d.saldoDevedor = 'Quitado';
            d.parcela = '—';
            d.proximaAssembleia = '—';
            d.contemplacao = 'Contemplada em 03/2024';
            d.aviso = 'Cota encerrada — dados cadastrais em leitura reduzida.';
        } else if (contractNumber == 'INV-88114') {
            d.tipo = 'INVEST';
            d.produto = 'CDB Porto Bank • Pós-fixado 102% do CDI';
            d.valorAplicado = 'R$ 18.000,00';
            d.rentabilidade = '+11,2% a.a.';
            d.vencimento = 'Vence em 12/2027';
        } else if (contractNumber == 'INV-77231') {
            d.tipo = 'INVEST';
            d.produto = 'Fundo de Ações Dividendos';
            d.valorAplicado = 'R$ 5.200,00';
            d.rentabilidade = '+18,3% em 12 meses';
            d.vencimento = 'Resgate D+2';
        } else if (contractNumber == 'CONT-9876') {
            d.tipo = 'CONTA';
            d.saldo = 'R$ 340.900,00';
            d.agenciaConta = 'Ag 0007 • C/C 98765-4';
            d.chavesPix = new List<String>{ 'c***@industriaexemplo.com.br (e-mail)', '**.***.***/0001-90 (CNPJ)' };
        } else if (contractNumber == 'INV-55021') {
            d.tipo = 'INVEST';
            d.produto = 'CDB Empresarial • 104% do CDI';
            d.valorAplicado = 'R$ 120.000,00';
            d.rentabilidade = '+11,8% a.a.';
            d.vencimento = 'Vence em 06/2027';
        } else if (contractNumber == 'CONT-5432') {
            d.tipo = 'CONTA';
            d.saldo = 'R$ 2.140,00';
            d.agenciaConta = 'Ag 0001 • C/C 54321-0';
            d.chavesPix = new List<String>{ '(11) *****-8899 (celular)' };
        } else if (contractNumber == 'CONT-7777') {
            d.tipo = 'CONTA';
            d.saldo = 'R$ 8.020,35';
            d.agenciaConta = 'Ag 0003 • C/C 77777-7';
            d.chavesPix = new List<String>{ 'c***@email.com (e-mail)' };
        } else {
            result.fault = new Visao360DTOs.ApiFaultDTO(
                'NC_Visao360_Core', 'DESCONHECIDO', 'Ativo sem detalhe volátil no mock.');
            return result;
        }
        if (String.isBlank(d.tipo) && !String.isBlank(family)) {
            d.tipo = family;
        }
        d.atualizadoEm = Datetime.now().format('HH:mm:ss');
        d.doCache = false;
        result.detail = d;
        return result;
    }

    // =================================================================
    // NBO estatico (P6) — Carlos: 1a carga do dia so banner; retry na hora.
    // =================================================================

    public static Visao360DTOs.MotorInfoDTO mockMotor() {
        Visao360DTOs.MotorInfoDTO m = new Visao360DTOs.MotorInfoDTO();
        m.modelo = 'Propensão Porto v3.2';
        m.safra = '2026-09';
        m.geradoEm = '06/09/2026 às 08:00';
        return m;
    }

    private static Visao360DTOs.NBOOfferDTO oferta(
        String offerId, String productCode, String productName, String category,
        Integer priority, Decimal score, String headline, String elegibilidade,
        String confianca, List<String> motivos, String validade,
        String chaveSafra, String omniKey
    ) {
        Visao360DTOs.NBOOfferDTO o = new Visao360DTOs.NBOOfferDTO();
        o.offerId = offerId;
        o.externalOfferId = chaveSafra;
        o.productCode = productCode;
        o.productName = productName;
        o.category = category;
        o.priority = priority;
        o.propensityScore = score;
        o.headline = headline;
        o.elegibilidade = elegibilidade;
        o.confianca = confianca;
        o.motivos = motivos;
        o.validade = validade;
        o.chaveSafra = chaveSafra;
        o.omniScriptKey = omniKey;
        o.estado = 'elegivel';
        return o;
    }

    public static Visao360DTOs.NboResult mockOffers(String normalizedDoc, Boolean retry) {
        Visao360DTOs.NboResult result = new Visao360DTOs.NboResult();
        result.motor = mockMotor();
        if (normalizedDoc == DOC_JOAO) {
            result.offers.add(oferta('nbo-black', 'BLACK', 'Cartão Black', 'Cartão de Crédito', 1, 92,
                'Isenção de anuidade no 1º ano', 'Sem cartão Black + gasto médio acima de R$ 8.000/mês', 'Alta',
                new List<String>{ 'Gasto médio de R$ 8.400/mês nos últimos 6 meses', 'Relacionamento de 8 anos sem atraso', 'Perfil Exclusivo sem cartão premium' },
                '30/09/2026', '12345678900_BLACK_2026-09', 'osSaleCreditCard'));
            result.offers.add(oferta('nbo-consorcio', 'CONSORCIO', 'Consórcio Imóvel — lance embutido', 'Consórcio', 2, 81,
                'Contemplação acelerada com lance de 20%', 'Sem consórcio ativo + relacionamento acima de 5 anos', 'Alta',
                new List<String>{ 'Simulação de consórcio em andamento (PRT-2026-87531)', 'Idade e renda compatíveis com carta de R$ 350 mil', 'Sem consórcio ativo no CPF' },
                '30/09/2026', '12345678900_CONSORCIO_2026-09', 'osSaleConsorcio'));
            result.offers.add(oferta('nbo-cdb', 'CDB', 'CDB 102% do CDI', 'Investimentos', 3, 74,
                'Aplicação mínima de R$ 1.000', 'Saldo em conta acima de R$ 10.000 sem investimento', 'Média',
                new List<String>{ 'Saldo parado de R$ 12.480 sem investimento vinculado', 'Primeira aplicação há mais de 2 anos', 'Perfil conservador em 70% da carteira' },
                '15/10/2026', '12345678900_CDB_2026-09', 'osSaleInvestimento'));
        } else if (normalizedDoc == DOC_CARLOS) {
            if (retry != true) {
                result.fault = new Visao360DTOs.ApiFaultDTO(
                    'NC_Visao360_Nbo', 'NBO_FORA', 'Motor de propensão indisponível no momento.');
                result.offers.clear();
                return result;
            }
            result.offers.add(oferta('nbo-carlos-1', 'PLATINUM', 'Cartão Platinum', 'Cartão de Crédito', 1, 68,
                'Anuidade grátis por 6 meses', 'Sem cartão + score acima de 700', 'Média',
                new List<String>{ 'Score 705 em alta pelo 3º mês', 'Sem cartão no CPF', 'Gasto concentrado no débito' },
                '30/09/2026', '99999999999_PLATINUM_2026-09', 'osSaleCreditCard'));
            result.offers.add(oferta('nbo-carlos-2', 'CONSORCIO', 'Consórcio Veículo', 'Consórcio', 2, 61,
                'Primeira assembleia sem taxa', 'Sem consórcio ativo', 'Média',
                new List<String>{ 'Sem consórcio ativo no CPF', 'Idade da frota familiar acima de 6 anos', 'Visitas à página de veículos no app' },
                '30/09/2026', '99999999999_CONSORCIO_2026-09', 'osSaleConsorcio'));
        }
        return result;
    }

    // =================================================================
    // Visao rica (P7-P10) — Joao completo; demais com vazios discretos.
    // =================================================================

    public static Visao360DTOs.VisaoResult mockVisao(String normalizedDoc) {
        Visao360DTOs.VisaoResult v = new Visao360DTOs.VisaoResult();
        v.header = mockHeader(normalizedDoc);
        if (v.header == null) {
            v.fault = new Visao360DTOs.ApiFaultDTO('VISAO360', 'NOT_FOUND', 'Cliente não localizado para o documento.');
            return v;
        }
        if (normalizedDoc == DOC_JOAO) {
            v.aum = 'R$ 127.400,00';
            v.patrimonioHousehold = 'R$ 214.900,00';
            v.ativosFora = 'R$ 67.200,00';
            v.walletShare = '68%';
            v.scoreCredito = '872 (baixo risco)';
            v.completude = '80%';
            v.eventosVida = mockEventos();
            v.tagsSegmentos = new List<String>{ 'Exclusivo', 'Top 50' };
            v.tagsInvestimentos = new List<String>{ 'Renda fixa', 'Fundos imobiliários' };
            v.tagsEstilo = new List<String>{ 'Viagens', 'Gastronomia' };
            v.wellness = mockWellness();
            v.planejamento = mockPlanejamento();
            v.fluxo = mockFluxo();
            v.segmentacao = mockSegmentacao();
            v.comportamento = mockComportamento();
            v.campanhas = mockCampanhas();
            v.metas = mockMetas();
            v.tarefas = mockTarefas();
            v.interacoes = mockInteracoes();
            v.acoes = mockAcoes();
            v.arcResumo = mockArcResumoJoao();
            v.arcCompleta = mockArcCompletaJoao();
            v.arcTotalVinculos = 24;
            v.casos = mockCasosJoao();
        } else if (normalizedDoc == DOC_INDUSTRIA) {
            v.arcResumo = mockArcResumoIndustria();
            v.arcCompleta = mockArcCompletaIndustria();
            v.arcTotalVinculos = 11;
            v.casos = mockCasosPadrao();
        } else {
            Visao360DTOs.ArcNodeDTO raiz = new Visao360DTOs.ArcNodeDTO();
            raiz.id = 'no-raiz';
            raiz.nome = v.header.nome;
            raiz.papel = 'Titular';
            raiz.tipo = 'PF';
            raiz.doc = normalizedDoc;
            raiz.nivel = 0;
            v.arcResumo = new List<Visao360DTOs.ArcNodeDTO>{ raiz };
            v.arcCompleta = new List<Visao360DTOs.ArcNodeDTO>{ raiz };
            v.arcTotalVinculos = 1;
            v.casos = mockCasosPadrao2();
        }
        return v;
    }

    private static List<Visao360DTOs.EventoVidaDTO> mockEventos() {
        List<Visao360DTOs.EventoVidaDTO> out = new List<Visao360DTOs.EventoVidaDTO>();
        out.add(evento('ev-1', 'Abertura de conta', '03/02/2018', 'pessoa'));
        out.add(evento('ev-2', 'Casamento', '20/06/2020', 'alianca'));
        out.add(evento('ev-3', 'Casa nova', '10/07/2022', 'casa'));
        out.add(evento('ev-4', 'Nascimento do Pedro', '25/09/2023', 'bebe'));
        out.add(evento('ev-5', 'Promoção no trabalho', '25/05/2025', 'trofeu'));
        out.add(evento('ev-6', 'Aposentadoria (prevista)', '2038', 'local'));
        return out;
    }

    private static Visao360DTOs.EventoVidaDTO evento(String id, String titulo, String dataOcorrencia, String glifo) {
        Visao360DTOs.EventoVidaDTO e = new Visao360DTOs.EventoVidaDTO();
        e.id = id;
        e.titulo = titulo;
        e.data = dataOcorrencia;
        e.glifo = glifo;
        return e;
    }

    private static Visao360DTOs.WellnessDTO mockWellness() {
        Visao360DTOs.WellnessDTO w = new Visao360DTOs.WellnessDTO();
        w.nota = '4,8';
        w.variacao = '+0,3 no ano';
        w.nivel = 'Alto';
        w.barras = new List<Integer>{ 55, 60, 58, 66, 62, 70, 68, 75, 72, 80, 78, 88 };
        return w;
    }

    private static Visao360DTOs.PlanejamentoDTO mockPlanejamento() {
        Visao360DTOs.PlanejamentoDTO p = new Visao360DTOs.PlanejamentoDTO();
        p.nivel = 'Intermediário';
        p.etapa = 2;
        p.recomendacao = 'Recomendado concluir o plano 2026';
        p.recomendacaoDetalhe = 'Clientes com plano de longo prazo têm 8x mais valor.';
        return p;
    }

    private static Visao360DTOs.FluxoDTO mockFluxo() {
        Visao360DTOs.FluxoDTO f = new Visao360DTOs.FluxoDTO();
        f.maximo = 10000;
        f.meses = new List<Visao360DTOs.FluxoMesDTO>{
            fluxoMes('JUL', 9400, 6300), fluxoMes('AGO', 7400, 7400),
            fluxoMes('SET', 8400, 6800), fluxoMes('OUT', 8400, 6300),
            fluxoMes('NOV', 8400, 6800), fluxoMes('DEZ', 8300, 8100)
        };
        return f;
    }

    private static Visao360DTOs.FluxoMesDTO fluxoMes(String mes, Decimal entrada, Decimal saida) {
        Visao360DTOs.FluxoMesDTO m = new Visao360DTOs.FluxoMesDTO();
        m.mes = mes;
        m.entrada = entrada;
        m.saida = saida;
        return m;
    }

    private static Visao360DTOs.SegmentacaoDTO mockSegmentacao() {
        Visao360DTOs.SegmentacaoDTO s = new Visao360DTOs.SegmentacaoDTO();
        s.periodo = 'JUL – DEZ';
        s.itens = new List<Visao360DTOs.SegmentoDTO>{
            segmento('Empréstimos e financiamentos', 30, '#1f8ef1'),
            segmento('Casa e serviços', 23, '#4a5568'),
            segmento('Viagem e lazer', 18, '#e94e77'),
            segmento('Saúde', 15, '#9b7ed9'),
            segmento('Alimentação e bebidas', 7.5, '#f5a623'),
            segmento('Transporte e carro', 6.5, '#34a853')
        };
        return s;
    }

    private static Visao360DTOs.SegmentoDTO segmento(String rotulo, Decimal percentual, String cor) {
        Visao360DTOs.SegmentoDTO s = new Visao360DTOs.SegmentoDTO();
        s.rotulo = rotulo;
        s.percentual = percentual;
        s.cor = cor;
        return s;
    }

    private static Visao360DTOs.ComportamentoDTO mockComportamento() {
        Visao360DTOs.ComportamentoDTO c = new Visao360DTOs.ComportamentoDTO();
        c.site = new List<Visao360DTOs.ComportamentoItemDTO>{
            comportamento('03/09/2026 09:38', '2:48', 5, 'Link de e-mail', 'Desktop', 'Abriu a fatura do Visa Infinite e simulou parcelamento.', 'Visitou: fatura, parcelamento, ajuda'),
            comportamento('14/08/2026 17:10', '1:05', 2, 'Buscador', 'Celular', 'Pesquisou taxas do consórcio e saiu na página de grupos.', 'Visitou: consórcio, grupos'),
            comportamento('19/07/2026 16:20', '3:15', 6, 'Acesso direto', 'Desktop', 'Comparou CDB x poupança e leu o regulamento do Black.', 'Visitou: investimentos, cartões, regulamento'),
            comportamento('02/07/2026 20:02', '0:58', 2, 'Link de SMS', 'Celular', 'Abriu o boleto do consórcio e copiou o código de barras.', 'Visitou: boletos')
        };
        c.app = new List<Visao360DTOs.ComportamentoItemDTO>{
            comportamento('05/09/2026 08:12', '4:02', 9, 'Push de fatura', 'Celular', 'Pagou a fatura, ativou débito automático e avaliou o app.', 'Ações: pagamento, débito automático, CSAT 5/5'),
            comportamento('28/08/2026 19:44', '1:37', 4, 'Acesso direto', 'Celular', 'Consultou o Pix agendado e conferiu o extrato.', 'Ações: Pix, extrato'),
            comportamento('09/08/2026 12:30', '2:20', 5, 'Push de oferta', 'Celular', 'Tocou na oferta do Black, leu condições e salvou para depois.', 'Ações: oferta Black salva')
        };
        return c;
    }

    private static Visao360DTOs.ComportamentoItemDTO comportamento(
        String quando, String duracao, Integer paginas, String origem,
        String dispositivo, String detalhe, String destaque
    ) {
        Visao360DTOs.ComportamentoItemDTO c = new Visao360DTOs.ComportamentoItemDTO();
        c.quando = quando;
        c.duracao = duracao;
        c.paginas = paginas;
        c.origem = origem;
        c.dispositivo = dispositivo;
        c.detalhe = detalhe;
        c.destaque = destaque;
        return c;
    }

    private static List<Visao360DTOs.CampanhaDTO> mockCampanhas() {
        List<Visao360DTOs.CampanhaDTO> out = new List<Visao360DTOs.CampanhaDTO>();
        out.add(campanha('camp-1', '26/08/2026', 'Upgrade para cartão Black', 'ok', 'pendente', 'pendente'));
        out.add(campanha('camp-2', '18/07/2026', 'Portabilidade de salário', 'ok', 'falha', 'falha'));
        out.add(campanha('camp-3', '01/04/2026', 'Ativação do débito automático', 'ok', 'ok', 'ok'));
        return out;
    }

    private static Visao360DTOs.CampanhaDTO campanha(
        String id, String inicio, String nome, String primeira, String finalizacao, String oportunidade
    ) {
        Visao360DTOs.CampanhaDTO c = new Visao360DTOs.CampanhaDTO();
        c.id = id;
        c.inicio = inicio;
        c.nome = nome;
        c.primeira = primeira;
        c.finalizacao = finalizacao;
        c.oportunidade = oportunidade;
        return c;
    }

    private static List<Visao360DTOs.MetaDTO> mockMetas() {
        List<Visao360DTOs.MetaDTO> out = new List<Visao360DTOs.MetaDTO>();
        out.add(meta('meta-1', 'Reserva de emergência', 'Em andamento', 'R$ 30.000', 'R$ 17.500', '23/08/2027', 58));
        out.add(meta('meta-2', 'Entrada da casa própria', 'Em andamento', 'R$ 120.000', 'R$ 42.000', '15/12/2028', 35));
        return out;
    }

    private static Visao360DTOs.MetaDTO meta(
        String id, String nome, String estado, String alvo, String atual, String dataAlvo, Integer percentual
    ) {
        Visao360DTOs.MetaDTO m = new Visao360DTOs.MetaDTO();
        m.id = id;
        m.nome = nome;
        m.estado = estado;
        m.alvo = alvo;
        m.atual = atual;
        m.dataAlvo = dataAlvo;
        m.percentual = percentual;
        return m;
    }

    private static List<Visao360DTOs.TarefaDTO> mockTarefas() {
        List<Visao360DTOs.TarefaDTO> out = new List<Visao360DTOs.TarefaDTO>();
        out.add(tarefa('tar-1', 'Enviar proposta do cartão Black', 'Hoje', 'Ricardo Alves', false));
        out.add(tarefa('tar-2', 'Agendar revisão da carteira', '12/09/2026', 'Ricardo Alves', false));
        return out;
    }

    private static Visao360DTOs.TarefaDTO tarefa(String id, String titulo, String prazo, String responsavel, Boolean concluida) {
        Visao360DTOs.TarefaDTO t = new Visao360DTOs.TarefaDTO();
        t.id = id;
        t.titulo = titulo;
        t.prazo = prazo;
        t.responsavel = responsavel;
        t.concluida = concluida;
        return t;
    }

    private static List<Visao360DTOs.InteracaoDTO> mockInteracoes() {
        List<Visao360DTOs.InteracaoDTO> out = new List<Visao360DTOs.InteracaoDTO>();
        out.add(interacao('int-1', 'email', 'Proposta do consórcio imóvel', 'Enviado comparativo de grupos e assembleias.', 'Anexo com 3 grupos (1234, 5678 e 9012), estimativa de lance embutido de 20% e calendário das próximas 4 assembleias.', 'Ricardo Alves', 'João da Silva', '02/09/2026', '14:30', '—', 'E-mail', 'PRT-2026-87531'));
        out.add(interacao('int-2', 'ligacao', 'Follow-up: fatura do cartão', 'Cliente confirmou o pagamento e pediu 2ª via.', 'Fatura do Visa Infinite 3x acima da média; cliente alega compra parcelada de passagem aérea. 2ª via enviada por e-mail durante a ligação.', 'Paula Mendes', 'João da Silva', '28/08/2026', '10:12', '7:48', 'Central', 'PRT-2026-88114'));
        out.add(interacao('int-3', 'tarefa', 'Atualização cadastral concluída', 'Endereço e renda atualizados na agência.', 'Renda atualizada para R$ 18.500; novo comprovante de endereço arquivado. Pendência KYC segue aberta (validação de identidade).', 'Paula Mendes', '—', '12/08/2026', '15:40', '—', 'Agência', 'PRT-2026-87902'));
        out.add(interacao('int-4', 'chat', 'Dúvida sobre Pix agendado', 'Orientado pelo app; sem necessidade de retorno.', 'Cliente não encontrava o agendamento; era filtro de período. Enviado passo a passo com prints. CSAT 5/5.', 'Atendimento digital', 'João da Silva', '05/08/2026', '09:05', '8:45', 'App', '—'));
        out.add(interacao('int-5', 'email', 'Boleto da parcela do consórcio', '2ª via enviada com vencimento atualizado.', 'Parcela de R$ 1.420 do grupo 1234 com vencimento prorrogado para 25/08 sem multa, por solicitação do cliente.', 'Ricardo Alves', 'João da Silva', '20/08/2026', '10:05', '—', 'E-mail', '—'));
        out.add(interacao('int-6', 'ligacao', 'Oferta de portabilidade de salário', 'Cliente pediu para retornar em outubro.', 'Oferta recusada no momento por fidelidade ao banco atual; pedir retorno em 15/10 com condição de anuidade zerada.', 'Ricardo Alves', 'João da Silva', '15/07/2026', '16:40', '6:12', 'Central', '—'));
        out.add(interacao('int-7', 'chat', 'Saldo contestado no app', 'Divergência explicada; caso encerrado.', 'Diferença de R$ 180 referente a débito automático de consórcio. Extrato detalhado enviado; cliente satisfeito.', 'Atendimento digital', 'João da Silva', '30/06/2026', '11:22', '12:03', 'App', 'PRT-2026-86120'));
        return out;
    }

    private static Visao360DTOs.InteracaoDTO interacao(
        String id, String tipo, String titulo, String detalhe, String detalheLongo,
        String de, String para, String quando, String hora, String duracao,
        String canal, String protocolo
    ) {
        Visao360DTOs.InteracaoDTO i = new Visao360DTOs.InteracaoDTO();
        i.id = id;
        i.tipo = tipo;
        i.titulo = titulo;
        i.detalhe = detalhe;
        i.detalheLongo = detalheLongo;
        i.de = de;
        i.para = para;
        i.quando = quando;
        i.hora = hora;
        i.duracao = duracao;
        i.canal = canal;
        i.protocolo = protocolo;
        return i;
    }

    private static List<Visao360DTOs.AcaoDTO> mockAcoes() {
        List<Visao360DTOs.AcaoDTO> out = new List<Visao360DTOs.AcaoDTO>();
        out.add(acao('acao-1', 'Agendar revisão da carteira', 'Cliente Exclusivo sem contato há 45 dias; última revisão há 8 meses.', 'Agendar'));
        out.add(acao('acao-2', 'Ligar sobre a fatura do Black', 'Fatura 3x acima da média; risco de contestação no vencimento.', 'Ligar'));
        out.add(acao('acao-3', 'Enviar proposta do consórcio', 'Simulação em andamento (PRT-2026-87531) sem retorno há 9 dias.', 'Enviar'));
        return out;
    }

    private static Visao360DTOs.AcaoDTO acao(String id, String titulo, String descricao, String cta) {
        Visao360DTOs.AcaoDTO a = new Visao360DTOs.AcaoDTO();
        a.id = id;
        a.titulo = titulo;
        a.descricao = descricao;
        a.cta = cta;
        return a;
    }

    private static List<Visao360DTOs.CasoDTO> mockCasosJoao() {
        List<Visao360DTOs.CasoDTO> out = new List<Visao360DTOs.CasoDTO>();
        out.add(caso('caso-1', 'PRT-2026-88114', '28/08/2026', 'Dúvida sobre fatura do cartão', 'Cartões', 'Central', 'Paula Mendes', 'Encerrado', 5, '1 dia útil'));
        out.add(caso('caso-2', 'PRT-2026-87902', '12/08/2026', 'Atualização cadastral', 'Cadastro', 'Agência', 'Paula Mendes', 'Encerrado', 4, 'No mesmo dia'));
        out.add(caso('caso-3', 'PRT-2026-87531', '30/07/2026', 'Simulação de consórcio', 'Consórcio', 'App', 'Ricardo Alves', 'Em andamento', 5, '—'));
        out.add(caso('caso-4', 'PRT-2026-86120', '09/07/2026', 'Contestação de tarifa de pacote', 'Tarifas', 'App', 'Ricardo Alves', 'Encerrado', 3, '4 dias úteis'));
        out.add(caso('caso-5', 'PRT-2026-85447', '18/06/2026', 'Aumento de limite do cartão', 'Cartões', 'Agência', 'Paula Mendes', 'Encerrado', 5, '2 dias úteis'));
        return out;
    }

    private static List<Visao360DTOs.CasoDTO> mockCasosPadrao() {
        List<Visao360DTOs.CasoDTO> out = new List<Visao360DTOs.CasoDTO>();
        out.add(caso('caso-a', 'PRT-2026-87001', '20/08/2026', 'Atualização de endereço', 'Cadastro', 'Agência', 'Paula Mendes', 'Encerrado', 4, 'No mesmo dia'));
        out.add(caso('caso-b', 'PRT-2026-86612', '05/08/2026', 'Extrato para imposto de renda', 'Conta', 'App', 'Ricardo Alves', 'Encerrado', 5, 'No mesmo dia'));
        out.add(caso('caso-c', 'PRT-2026-85233', '22/07/2026', 'Contestação de tarifa', 'Tarifas', 'Central', 'Paula Mendes', 'Em andamento', 3, '—'));
        return out;
    }

    private static List<Visao360DTOs.CasoDTO> mockCasosPadrao2() {
        List<Visao360DTOs.CasoDTO> todos = mockCasosPadrao();
        return new List<Visao360DTOs.CasoDTO>{ todos[0], todos[1] };
    }

    private static Visao360DTOs.CasoDTO caso(
        String id, String protocolo, String dataOcorrencia, String assunto,
        String categoria, String canal, String responsavel, String situacao,
        Integer satisfacao, String resolucao
    ) {
        Visao360DTOs.CasoDTO c = new Visao360DTOs.CasoDTO();
        c.id = id;
        c.protocolo = protocolo;
        c.dataOcorrencia = dataOcorrencia;
        c.assunto = assunto;
        c.categoria = categoria;
        c.canal = canal;
        c.responsavel = responsavel;
        c.situacao = situacao;
        c.satisfacao = satisfacao;
        c.resolucao = resolucao;
        return c;
    }

    private static Visao360DTOs.ArcNodeDTO no(String id, String nome, String papel, String tipo, String doc, Integer nivel) {
        Visao360DTOs.ArcNodeDTO n = new Visao360DTOs.ArcNodeDTO();
        n.id = id;
        n.nome = nome;
        n.papel = papel;
        n.tipo = tipo;
        n.doc = doc;
        n.nivel = nivel;
        return n;
    }

    private static List<Visao360DTOs.ArcNodeDTO> mockArcResumoJoao() {
        return new List<Visao360DTOs.ArcNodeDTO>{
            no('no-joao', 'João da Silva', 'Titular', 'PF', DOC_JOAO, 0),
            no('no-maria', 'Maria da Silva', 'Cônjuge', 'PF', null, 1),
            no('no-pedro', 'Pedro da Silva', 'Dependente', 'PF', null, 1),
            no('no-ana', 'Ana da Silva', 'Dependente', 'PF', null, 1),
            no('no-industria', 'Indústria Exemplo S.A.', 'Empresa vinculada', 'PJ', DOC_INDUSTRIA, 1)
        };
    }

    private static List<Visao360DTOs.ArcNodeDTO> mockArcCompletaJoao() {
        List<Visao360DTOs.ArcNodeDTO> out = mockArcResumoJoao();
        out.add(no('no-coligada', 'Logística Exemplo Ltda.', 'Coligada da Indústria Exemplo', 'PJ', null, 2));
        out.add(no('no-socio1', 'Paulo Mendes', 'Sócio da Indústria Exemplo (30%)', 'PF', null, 2));
        out.add(no('no-contadora', 'Contábil Alfa', 'Representante contábil', 'PJ', null, 2));
        out.add(no('no-mae', 'Rosa da Silva', 'Mãe (2º nível)', 'PF', null, 2));
        return out;
    }

    private static List<Visao360DTOs.ArcNodeDTO> mockArcResumoIndustria() {
        return new List<Visao360DTOs.ArcNodeDTO>{
            no('no-industria', 'Indústria Exemplo S.A.', 'Titular (raiz)', 'PJ', DOC_INDUSTRIA, 0),
            no('no-joao', 'João da Silva', 'Sócio-administrador', 'PF', DOC_JOAO, 1),
            no('no-socio1', 'Paulo Mendes', 'Sócio (30%)', 'PF', null, 1),
            no('no-socia2', 'Fernanda Lima', 'Sócia (20%)', 'PF', null, 1),
            no('no-contadora', 'Contábil Alfa', 'Representante contábil', 'PJ', null, 1)
        };
    }

    private static List<Visao360DTOs.ArcNodeDTO> mockArcCompletaIndustria() {
        List<Visao360DTOs.ArcNodeDTO> out = mockArcResumoIndustria();
        out.add(no('no-coligada', 'Logística Exemplo Ltda.', 'Coligada', 'PJ', null, 2));
        out.add(no('no-maria', 'Maria da Silva', 'Cônjuge do sócio-administrador', 'PF', null, 2));
        return out;
    }
}
