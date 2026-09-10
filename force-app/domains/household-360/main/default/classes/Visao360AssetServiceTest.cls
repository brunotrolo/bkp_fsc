/**
 * @description Testes do inventario e do detalhe volatil: caminho mock,
 * caminho real por ProductType, bulk 251+, parse e faults. Cen 6-9, 16, 20.
 * Padrao MIXED_DML: setup (agente) fora, todo DML nao-setup dentro do runAs.
 */
@IsTest
private class Visao360AssetServiceTest {

    private class CoreOkMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
            resp.setBody('{"tipo":"CONTA","saldo":"R$ 9.999,00","agenciaConta":"Ag 0001","chavesPix":["a***@x.com"]}');
            return resp;
        }
    }

    @IsTest
    static void shouldReturnFault_WhenNullAccount() {
        Visao360DTOs.AssetsResult result = Visao360AssetService.getCustomerAssets(null);

        Assert.isNotNull(result.fault, 'Conta nula vira fault');
        Assert.isTrue(result.items.isEmpty(), 'Sem itens em fault');
    }

    @IsTest
    static void shouldReturnMockAssets_WhenFlagOn() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            // Custom Setting conta como non-setup no MIXED_DML: criar dentro do runAs.
            Visao360TestFactory.ligarMock();
            Account acc = Visao360TestFactory.novaConta('João da Silva', Visao360Mock.DOC_JOAO, 'CPF');
            Test.startTest();
            Visao360DTOs.AssetsResult result = Visao360AssetService.getCustomerAssets(acc.Id);
            Test.stopTest();

            Assert.areEqual(8, result.items.size(), 'Joao tem 8 ativos no mock');
            Assert.isNull(result.fault, 'Mock sem fault');
        }
    }

    @IsTest
    static void shouldMapProductTypes_WhenRealPath() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = Visao360TestFactory.novaConta('João da Silva', '12345678900', 'CPF');
            Visao360TestFactory.novosAtivos(acc.Id);
            Test.startTest();
            Visao360DTOs.AssetsResult result = Visao360AssetService.getCustomerAssets(acc.Id);
            Test.stopTest();

            Assert.areEqual(4, result.items.size(), '4 familias no caminho real');
            Map<String, String> familiaPorContrato = new Map<String, String>();
            for (Visao360DTOs.AssetSummaryDTO item : result.items) {
                familiaPorContrato.put(item.contractNumber, item.productFamily);
            }
            Assert.areEqual('CARTAO', familiaPorContrato.get('CART-1234'), 'CARTAO vira CARTAO');
            Assert.areEqual('CONTA', familiaPorContrato.get('CONT-0001'), 'CONTA_DIGITAL vira CONTA');
            Assert.areEqual('CONSORCIO', familiaPorContrato.get('CONS-1234-045'), 'CONSORCIO vira CONSORCIO');
            Assert.areEqual('INVEST', familiaPorContrato.get('INV-88114'), 'INVESTIMENTOS vira INVEST');
        }
    }

    @IsTest
    static void shouldReturn251_WhenBulkAssets() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = Visao360TestFactory.novaConta('Carteira Bulk', '99988877766', 'CPF');
            List<Asset> lote = new List<Asset>();
            for (Integer i = 0; i < 251; i++) {
                lote.add(Visao360TestFactory.novoAtivo(acc.Id, 'Conta ' + i, 'BULK-' + i, 'Ativo', 'CONTA_DIGITAL'));
            }
            insert lote;
            Test.startTest();
            Visao360DTOs.AssetsResult result = Visao360AssetService.getCustomerAssets(acc.Id);
            Test.stopTest();

            Assert.areEqual(251, result.items.size(), 'Bulk acima do limite de batch sem N+1');
        }
    }

    @IsTest
    static void shouldReturnMockRealtime_WhenFlagOn() {
        Visao360TestFactory.ligarMock();

        Test.startTest();
        Visao360DTOs.RealtimeResult primeira =
            Visao360AssetService.fetchRealtimeData('CONS-1234-045', 'CONSORCIO', false);
        Visao360DTOs.RealtimeResult retry =
            Visao360AssetService.fetchRealtimeData('CONS-1234-045', 'CONSORCIO', true);
        Test.stopTest();

        Assert.isNotNull(primeira.fault, 'Mock falha na 1a (Cen 9)');
        Assert.areEqual('R$ 212.400,00', retry.detail.saldoDevedor, 'Retry resolve');
    }

    @IsTest
    static void shouldParseCorePayload_WhenRealPath() {
        Test.setMock(HttpCalloutMock.class, new CoreOkMock());

        Test.startTest();
        Visao360DTOs.RealtimeResult result =
            Visao360AssetService.fetchRealtimeData('CONT-0001', 'CONTA', false);
        Test.stopTest();

        Assert.isNull(result.fault, 'Core 200 sem fault');
        Assert.areEqual('R$ 9.999,00', result.detail.saldo, 'Saldo do payload');
        Assert.areEqual(1, result.detail.chavesPix.size(), 'PIX do payload');
        Assert.areEqual('a***@x.com (e-mail)', result.detail.chavesPix[0], 'PIX real mascarada (RN-15)');
        Assert.isNotNull(result.detail.atualizadoEm, 'Horario da consulta');
    }

    @IsTest
    static void shouldMaskPixKeys_WhenRealPath() {
        Visao360DTOs.RealtimeResult result = new Visao360DTOs.RealtimeResult();

        Test.startTest();
        Visao360AssetService.parseRealtime(
            '{"chavesPix":["joao.silva@email.com","(11) 98888-5678","12345678909","11222333000181","9f3a2b7c"]} ',
            'CONTA', result);
        Test.stopTest();

        Assert.isNull(result.fault, 'Payload valido sem fault');
        Assert.areEqual(5, result.detail.chavesPix.size(), 'Todas as chaves mapeadas');
        Assert.areEqual('j***@email.com (e-mail)', result.detail.chavesPix[0], 'E-mail parcial');
        Assert.areEqual('(11) *****-5678 (celular)', result.detail.chavesPix[1], 'Celular parcial');
        Assert.areEqual('***.***.***-09 (CPF)', result.detail.chavesPix[2], 'CPF parcial');
        Assert.areEqual('**.***.***/0001-81 (CNPJ)', result.detail.chavesPix[3], 'CNPJ parcial');
        Assert.areEqual('9f••••7c (chave)', result.detail.chavesPix[4], 'Aleatoria parcial');
    }

    @IsTest
    static void shouldReturnFault_WhenInvalidJson() {
        Visao360DTOs.RealtimeResult result = new Visao360DTOs.RealtimeResult();

        Test.startTest();
        Visao360AssetService.parseRealtime('nao-e-json', 'CONTA', result);
        Test.stopTest();

        Assert.areEqual('INVALID_JSON', result.fault.code, 'JSON invalido vira fault');
    }

    @IsTest
    static void shouldReturnFault_WhenBlankContract() {
        Visao360DTOs.RealtimeResult result = Visao360AssetService.fetchRealtimeData('', 'CONTA', false);

        Assert.areEqual('INVALID_INPUT', result.fault.code, 'Contrato em branco e entrada invalida');
    }
}
