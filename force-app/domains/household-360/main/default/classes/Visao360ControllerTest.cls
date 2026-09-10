/**
 * @description Testes da fachada: validacoes de entrada viram
 * AuraHandledException tratavel no LWC; caminhos felizes delegam aos services.
 * Cen 1 (entrada pela raiz), 8, 10.
 * Padrao MIXED_DML: setup (agente) fora, todo DML nao-setup dentro do runAs.
 */
@IsTest
private class Visao360ControllerTest {

    @IsTest
    static void shouldResolve_WhenDocumentExists() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = Visao360TestFactory.novaConta('João Resolve', '66677788899', 'CPF');
            Test.startTest();
            Id resolvido = Visao360Controller.resolveAccount('666.777.888-99');
            Test.stopTest();

            Assert.areEqual(acc.Id, resolvido, 'Documento com mascara resolve a raiz (Cen 1)');
        }
    }

    @IsTest
    static void shouldThrow_WhenDocumentUnknown() {
        User agente = Visao360TestFactory.novoAgente();
        Boolean threw = false;
        System.runAs(agente) {
            try {
                Visao360Controller.resolveAccount('00000000000');
            } catch (AuraHandledException e) {
                threw = true;
            }
        }
        Assert.isTrue(threw, 'Doc desconhecido deve falhar com erro tratavel no LWC');
    }

    @IsTest
    static void shouldThrow_WhenInputsBlank() {
        // Nota: em testes, getMessage() de AuraHandledException nao expoe o
        // texto amigavel (vai serializado para o LWC); aqui vale o padrao da
        // busca — afirmar apenas que o erro e tratavel (flag booleana).
        assertAuraThrows('resolveAccount');
        assertAuraThrows('getVisao');
        assertAuraThrows('getAssets');
        assertAuraThrows('getRealtime');
        assertAuraThrows('getOffers');
        assertAuraThrows('rejectOffer');
        assertAuraThrows('acceptOffer');
    }

    private static void assertAuraThrows(String metodo) {
        Boolean threw = false;
        try {
            if (metodo == 'resolveAccount') {
                Visao360Controller.resolveAccount('   ');
            } else if (metodo == 'getVisao') {
                Visao360Controller.getVisao(null);
            } else if (metodo == 'getAssets') {
                Visao360Controller.getAssets(null);
            } else if (metodo == 'getRealtime') {
                Visao360Controller.getRealtime('', 'CONTA', false);
            } else if (metodo == 'getOffers') {
                Visao360Controller.getOffers(null, false);
            } else if (metodo == 'rejectOffer') {
                Visao360Controller.rejectOffer('', 'SEM_INTERESSE');
            } else if (metodo == 'acceptOffer') {
                Visao360Controller.acceptOffer(null);
            }
        } catch (AuraHandledException e) {
            threw = true;
        }
        Assert.isTrue(threw, 'Entrada em branco deve falhar: ' + metodo);
    }

    @IsTest
    static void shouldDelegate_WhenMockPaths() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Visao360TestFactory.ligarMock();
            Account acc = Visao360TestFactory.novaConta('João da Silva', Visao360Mock.DOC_JOAO, 'CPF');
            Test.startTest();
            Visao360DTOs.VisaoResult visao = Visao360Controller.getVisao(acc.Id);
            Visao360DTOs.AssetsResult ativos = Visao360Controller.getAssets(acc.Id);
            Visao360DTOs.NboResult nbo = Visao360Controller.getOffers(acc.Id, false);
            Visao360DTOs.RealtimeResult detalhe = Visao360Controller.getRealtime('CONT-0001', 'CONTA', false);
            Visao360Controller.rejectOffer('12345678900_BLACK_2026-09', 'SEM_INTERESSE');
            Visao360DTOs.NBOOfferDTO aceite = Visao360Controller.acceptOffer('12345678900_BLACK_2026-09');
            Test.stopTest();

            Assert.areEqual('João da Silva', visao.header.nome, 'Visao delegada');
            Assert.areEqual(8, ativos.items.size(), 'Inventario delegado');
            Assert.areEqual(3, nbo.offers.size(), 'NBO delegado');
            Assert.areEqual('R$ 12.480,90', detalhe.detail.saldo, 'Volatil delegado');
            Assert.areEqual('negociacao', aceite.estado, 'Aceite delegado (RN-14)');
        }
    }
}
