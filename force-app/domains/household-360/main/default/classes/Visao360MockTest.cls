/**
 * @description Testes do provider de fixtures: flag propria OFF por default,
 * docs demo conhecidos, NBO top 3 do Joao, Carlos so banner ate o retry,
 * falha deterministica do consorcio ate o retry, visao rica completa.
 * Cen 8-12, 19, 25, EL-02/EL-03, RN-12, RN-17.
 */
@IsTest
private class Visao360MockTest {

    @IsTest
    static void shouldBeDisabled_WhenNoCustomSetting() {
        Assert.isFalse(Visao360Mock.isEnabled(), 'Sem registro, mock desligado (default OFF)');
    }

    @IsTest
    static void shouldBeEnabled_WhenOrgFlagMarked() {
        Visao360TestFactory.ligarMock();

        Assert.isTrue(Visao360Mock.isEnabled(), 'Registro org com UsarMock__c=true liga o mock');
    }

    @IsTest
    static void shouldMatchKnownDocs_WhenDemoDocuments() {
        Assert.isTrue(Visao360Mock.isKnown(Visao360Mock.DOC_JOAO), 'Joao conhecido');
        Assert.isTrue(Visao360Mock.isKnown(Visao360Mock.DOC_INDUSTRIA), 'Industria conhecida');
        Assert.isTrue(Visao360Mock.isKnown(Visao360Mock.DOC_MARIA), 'Maria conhecida');
        Assert.isTrue(Visao360Mock.isKnown(Visao360Mock.DOC_CARLOS), 'Carlos conhecido');
        Assert.isFalse(Visao360Mock.isKnown('00000000000'), 'Doc fora do demo nao e conhecido');
    }

    @IsTest
    static void shouldReturnHeader_WhenKnownDoc() {
        Visao360DTOs.HeaderDTO joao = Visao360Mock.mockHeader(Visao360Mock.DOC_JOAO);

        Assert.areEqual('João da Silva', joao.nome, 'Nome do Joao');
        Assert.areEqual('***.***.***-00', joao.documentoMascarado, 'CPF mascarado (RN-15)');
        Assert.isNull(joao.alerta, 'Sem alerta por padrao (premissa 05)');
        Assert.isNull(Visao360Mock.mockHeader('00000000000'), 'Doc desconhecido sem header');
    }

    @IsTest
    static void shouldReturnTop3_WhenJoaoOffers() {
        Visao360DTOs.NboResult result = Visao360Mock.mockOffers(Visao360Mock.DOC_JOAO, false);

        Assert.areEqual(3, result.offers.size(), 'Joao tem top 3 (Cen 10)');
        Assert.areEqual(92, result.offers[0].propensityScore, 'Ordenado por score (Black 92)');
        Assert.areEqual('2026-09', result.motor.safra, 'Safra vigente identificada');
        Assert.areEqual(3, result.offers[0].motivos.size(), 'Motivos por que esta oferta');
        Assert.isNull(result.fault, 'Joao sem fault');
    }

    @IsTest
    static void shouldReturnOnlyBanner_WhenCarlosFirstLoad() {
        Visao360DTOs.NboResult primeira = Visao360Mock.mockOffers(Visao360Mock.DOC_CARLOS, false);

        Assert.isTrue(primeira.offers.isEmpty(), 'Carlos 1a carga sem ofertas (RN-12)');
        Assert.isNotNull(primeira.fault, 'Carlos 1a carga so banner (EL-03)');

        Visao360DTOs.NboResult retry = Visao360Mock.mockOffers(Visao360Mock.DOC_CARLOS, true);

        Assert.areEqual(2, retry.offers.size(), 'Retry carrega 2 ofertas na hora');
        Assert.isNull(retry.fault, 'Retry limpa o banner');
    }

    @IsTest
    static void shouldReturnEmpty_WhenNoEligibleOffers() {
        Visao360DTOs.NboResult maria = Visao360Mock.mockOffers(Visao360Mock.DOC_MARIA, false);

        Assert.isTrue(maria.offers.isEmpty(), 'Maria sem ofertas (EL-02)');
        Assert.isNull(maria.fault, 'Sem ofertas e discreto, sem erro');
    }

    @IsTest
    static void shouldFailFirstAttempt_WhenJoaoConsorcio() {
        Visao360DTOs.RealtimeResult primeira =
            Visao360Mock.mockRealtime('CONS-1234-045', 'CONSORCIO', false);

        Assert.isNull(primeira.detail, '1a consulta do consorcio falha (Cen 9)');
        Assert.areEqual('CORE_TIMEOUT', primeira.fault.code, 'Timeout tipado para retry');

        Visao360DTOs.RealtimeResult retry =
            Visao360Mock.mockRealtime('CONS-1234-045', 'CONSORCIO', true);

        Assert.areEqual('R$ 212.400,00', retry.detail.saldoDevedor, 'Retry exibe o detalhe');
        Assert.isNotNull(retry.detail.atualizadoEm, 'Horario da consulta (EL-07)');
    }

    @IsTest
    static void shouldMaskPixKeys_WhenContaDetail() {
        Visao360DTOs.RealtimeResult conta = Visao360Mock.mockRealtime('CONT-0001', 'CONTA', false);

        Assert.areEqual(3, conta.detail.chavesPix.size(), 'Todas as chaves vinculadas');
        Assert.isTrue(conta.detail.chavesPix[0].contains('***'), 'Chave mascarada parcial (RN-15)');
    }

    @IsTest
    static void shouldReturnRichVision_WhenJoao() {
        Visao360DTOs.VisaoResult visao = Visao360Mock.mockVisao(Visao360Mock.DOC_JOAO);

        Assert.areEqual('João da Silva', visao.header.nome, 'Header do Joao');
        Assert.areEqual(6, visao.eventosVida.size(), 'Eventos da vida');
        Assert.areEqual(7, visao.interacoes.size(), 'Timeline com 7 interacoes (Cen 24)');
        Assert.areEqual(5, visao.casos.size(), 'Historico com 5 casos');
        Assert.areEqual(2, visao.metas.size(), 'Metas com donut');
        Assert.areEqual(6, visao.fluxo.meses.size(), 'Fluxo JUL-DEZ');
        Assert.areEqual(6, visao.segmentacao.itens.size(), 'Segmentacao com 6 cunhas');
        Assert.areEqual(5, visao.arcResumo.size(), 'ARC resumida 5 nos (RN-13)');
        Assert.isTrue(visao.arcCompleta.size() > 5, 'ARC completa multinivel');
        Assert.areEqual(24, visao.arcTotalVinculos, 'Contador alem dos 20 (EL-04)');
    }

    @IsTest
    static void shouldReturnSparseVision_WhenIndustria() {
        Visao360DTOs.VisaoResult visao = Visao360Mock.mockVisao(Visao360Mock.DOC_INDUSTRIA);

        Assert.isNull(visao.aum, 'Sem bloco rico: vazios discretos (EL-08)');
        Assert.isNull(visao.fluxo, 'PJ sem fluxo, sem erro');
        Assert.isTrue(visao.metas.isEmpty(), 'PJ sem metas, sem erro');
        Assert.areEqual(5, visao.arcResumo.size(), 'ARC da PJ com 5 nos');
    }

    @IsTest
    static void shouldReturnFault_WhenUnknownDoc() {
        Visao360DTOs.VisaoResult visao = Visao360Mock.mockVisao('00000000000');

        Assert.isNotNull(visao.fault, 'Doc desconhecido vira fault, nunca excecao');
        Assert.areEqual('NOT_FOUND', visao.fault.code, 'Codigo tipado');
    }
}
