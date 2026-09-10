/**
 * @description Testes do modo mock (BuscaClienteMock + desvios nos services).
 * Flag default OFF: sem registro de CS os services seguem o caminho real
 * (testes existentes intactos). Com registro org-level ON: fixtures.
 */
@IsTest
private class BuscaClienteMockTest {

    private static void enableMock() {
        insert new BuscaClienteMock__c(UsarMock__c = true);
    }

    @IsTest
    static void desligadoPorPadrao() {
        Assert.isFalse(BuscaClienteMock.isEnabled(), 'Sem registro, mock deve ficar OFF.');
        Assert.isFalse(BuscaClienteMock.isKnown('00000000000'), 'Doc fora da lista nao e conhecido.');
    }

    @IsTest
    static void ligaComRegistroOrg() {
        enableMock();
        Assert.isTrue(BuscaClienteMock.isEnabled(), 'Com registro org, mock deve ficar ON.');
        Assert.isTrue(BuscaClienteMock.isKnown(BuscaClienteMock.DOC_JOAO), 'Joao e conhecido.');
    }

    @IsTest
    static void cadastroJoaoCompleto() {
        enableMock();
        CadastroService.CadastroResult r = CadastroService.fetch(BuscaClienteMock.DOC_JOAO);
        Assert.areEqual(null, r.fault, 'Joao nao tem fault.');
        Assert.areEqual('João da Silva', r.demographic.nome, 'Nome deve bater.');
        Assert.areEqual('123.456.789-09', r.demographic.documentoFormatado, 'Doc formatado deve bater.');
        Assert.areEqual(4, r.wallet.size(), 'Joao tem 4 produtos.');
        Assert.areEqual('CARTAO', r.wallet[0].productType, 'Primeiro e cartao.');
    }

    @IsTest
    static void cadastroDesconhecidoViraNaoEncontrado() {
        enableMock();
        CadastroService.CadastroResult r = CadastroService.fetch('52998224725');
        Assert.areEqual('NOT_FOUND', r.fault.code, 'Doc valido desconhecido vira NOT_FOUND.');
        Assert.areEqual(null, r.demographic, 'Sem demographic.');
    }

    @IsTest
    static void cadastroPjSemOfertas() {
        enableMock();
        CadastroService.CadastroResult r = CadastroService.fetch(BuscaClienteMock.DOC_PJ);
        Assert.areEqual(null, r.fault, 'PJ nao tem fault.');
        Assert.areEqual('Indústria Exemplo S.A.', r.demographic.nome, 'Nome PJ deve bater.');
        Assert.areEqual('12.ABC.345/0001-90', r.demographic.documentoFormatado, 'Doc PJ deve bater.');
        Assert.areEqual(2, r.wallet.size(), 'PJ tem 2 produtos.');
        HoldingService.HoldingResult h = HoldingService.fetch(BuscaClienteMock.DOC_PJ);
        Assert.areEqual(2, h.items.size(), 'PJ tem 2 holdings.');
    }

    @IsTest
    static void cadastroSoHoldingESemHub() {
        enableMock();
        CadastroService.CadastroResult r = CadastroService.fetch(BuscaClienteMock.DOC_SO_HOLDING);
        Assert.areEqual(null, r.fault, 'Maria nao tem fault.');
        Assert.areEqual('Maria Oliveira', r.demographic.nome, 'Nome deve bater.');
        Assert.areEqual(0, r.wallet.size(), 'Sem hub Porto Bank.');
        HoldingService.HoldingResult h = HoldingService.fetch(BuscaClienteMock.DOC_SO_HOLDING);
        Assert.areEqual(4, h.items.size(), 'Maria tem 4 holdings.');
    }

    @IsTest
    static void cadastroNboParcialComHub() {
        enableMock();
        CadastroService.CadastroResult r = CadastroService.fetch(BuscaClienteMock.DOC_NBO_PARCIAL);
        Assert.areEqual(null, r.fault, 'Carlos nao tem fault de cadastro.');
        Assert.areEqual('Carlos Souza', r.demographic.nome, 'Nome deve bater.');
        Assert.areEqual(1, r.wallet.size(), 'Carlos tem 1 produto.');
        HoldingService.HoldingResult h = HoldingService.fetch(BuscaClienteMock.DOC_NBO_PARCIAL);
        Assert.areEqual(1, h.items.size(), 'Carlos tem 1 holding.');
    }
    @IsTest
    static void holdingJoaoSeisItens() {
        enableMock();
        HoldingService.HoldingResult r = HoldingService.fetch(BuscaClienteMock.DOC_JOAO);
        Assert.areEqual(6, r.items.size(), 'Joao tem 6 holdings.');
        Assert.areEqual('Seguro Auto', r.items[0].nome, 'Primeiro e auto.');
        HoldingService.HoldingResult vazio = HoldingService.fetch('52998224725');
        Assert.areEqual(0, vazio.items.size(), 'Desconhecido sem holding.');
    }

    @IsTest
    static void nboJoaoUmaOfertaPrimaria() {
        enableMock();
        NboService.NboResult r = NboService.fetch(BuscaClienteMock.DOC_JOAO);
        Assert.areEqual(1, r.offers.size(), 'Joao tem 1 oferta.');
        Assert.areEqual('nbo-black', r.offers[0].externalOfferId, 'Id deve bater.');
        Assert.areEqual(true, r.offers[0].isPrimary, 'Deve ser primaria.');
        Assert.areEqual(2, r.offers[0].bandeiras.size(), 'Duas bandeiras.');
    }

    @IsTest
    static void nboPjSemOfertasESemFault() {
        enableMock();
        NboService.NboResult r = NboService.fetch(BuscaClienteMock.DOC_PJ);
        Assert.areEqual(0, r.offers.size(), 'PJ sem ofertas.');
        Assert.areEqual(null, r.fault, 'PJ sem fault.');
    }

    @IsTest
    static void nboParcialViraFault() {
        enableMock();
        NboService.NboResult r = NboService.fetch(BuscaClienteMock.DOC_NBO_PARCIAL);
        Assert.areEqual('NBO_UNAVAILABLE', r.fault.code, 'Carlos tem fault de NBO.');
        Assert.areEqual(0, r.offers.size(), 'Sem ofertas no parcial.');
    }

    @IsTest
    static void lazyListasFixtures() {
        enableMock();
        Assert.areEqual(4, CardService.fetchVias('x').vias.size(), '4 vias.');
        Assert.areEqual('Ativo', CardService.fetchVias('x').vias[0].status, 'Primeira ativa.');
        Assert.areEqual('•••• 1234', CardService.fetchVias('x').vias[0].last4Masked, 'Mascara deve bater.');
        Assert.areEqual(6, ConsorcioService.fetchCotas('x').cotas.size(), '6 cotas.');
        Assert.areEqual('9012', ConsorcioService.fetchCotas('x').cotas[2].grupo, 'Grupo rural deve bater.');
        Assert.areEqual(5, InvestimentoService.fetchPosicoes('x').posicoes.size(), '5 posicoes.');
    }

    @IsTest
    static void contextoComViaSelecionada() {
        enableMock();
        Test.startTest();
        BuscaClienteDTOs.InteractionContextDTO ctx =
            InteractionContextService.build(BuscaClienteMock.DOC_JOAO, 'CARTAO', 'via-1234');
        Test.stopTest();
        Assert.areEqual(
            'João da Silva + Cartão de Crédito + Visa Infinite •••• 1234 (João da Silva)',
            ctx.resumo, 'Resumo deve nomear cliente, produto e via.'
        );
        Assert.areEqual('CARTAO', ctx.productType, 'Tipo deve ser preservado.');
    }

    @IsTest
    static void contextoComCotaEPosicao() {
        enableMock();
        Test.startTest();
        BuscaClienteDTOs.InteractionContextDTO cota =
            InteractionContextService.build(BuscaClienteMock.DOC_JOAO, 'CONSORCIO', 'cota-rural-003');
        BuscaClienteDTOs.InteractionContextDTO pos =
            InteractionContextService.build(BuscaClienteMock.DOC_JOAO, 'INVESTIMENTOS', 'inv-rf-001');
        BuscaClienteDTOs.InteractionContextDTO direta =
            InteractionContextService.build(BuscaClienteMock.DOC_JOAO, 'CONTA_DIGITAL', null);
        BuscaClienteDTOs.InteractionContextDTO desconhecido =
            InteractionContextService.build('52998224725', 'CARTAO', 'via-1234');
        Test.stopTest();
        Assert.areEqual(
            'João da Silva + Consórcio + Consórcio Rural grupo 9012 cota 007',
            cota.resumo, 'Resumo da cota deve bater.'
        );
        Assert.areEqual(
            'João da Silva + Investimentos + CDB Porto Bank R$ 18.000',
            pos.resumo, 'Resumo da posição deve bater.'
        );
        Assert.areEqual(
            'João da Silva + Conta Digital', direta.resumo, 'Sem item fecha só com produto.'
        );
        Assert.areEqual(
            'Cliente ainda nao consolidado para o documento informado.',
            desconhecido.resumo, 'Doc desconhecido mantém o fallback.'
        );
    }
    @IsTest
    static void interacaoNaoPersisteEmMock() {
        enableMock();
        Test.startTest();
        NboInteractionService.approach(new List<String>{ 'nbo-black' });
        NboInteractionService.dismiss(new List<String>{ 'nbo-black' });
        Test.stopTest();
        Assert.areEqual(0, [SELECT COUNT() FROM Opportunity], 'Mock nao cria Opportunity.');
        Assert.areEqual(0, [SELECT COUNT() FROM Task], 'Mock nao cria Task.');
    }

    @IsTest
    static void controllerNaoEnfileiraEmMock() {
        enableMock();
        Test.startTest();
        BuscaClienteDTOs.CustomerSearchResultDTO dto =
            CustomerSearchController.identifyCadastro(BuscaClienteMock.DOC_JOAO, 'PF');
        Test.stopTest();
        Assert.areEqual('João da Silva', dto.demographic.nome, 'Controller resolve Joao no mock.');
        Assert.areEqual(4, dto.portoBankWallet.size(), 'Hub com 4.');
        Assert.areEqual(6, dto.holdingWallet.size(), 'Holding com 6.');
        Assert.areEqual(0, [SELECT COUNT() FROM Account], 'Mock nao cria Account.');
    }
}
