/**
 * @description Testes da visao consolidada: header mascarado PF/PJ, arvore
 * via ACR, casos mapeados, vazios discretos no real, fault em raiz nula.
 * Cen 2-5, 14, 26, 27, EL-08.
 * Padrao MIXED_DML: setup (agente) fora, todo DML nao-setup dentro do runAs.
 */
@IsTest
private class Visao360CustomerServiceTest {

    @IsTest
    static void shouldReturnFault_WhenNullAccount() {
        Visao360DTOs.VisaoResult result = Visao360CustomerService.getVisao(null);

        Assert.isNotNull(result.fault, 'Raiz nula vira fault');
        Assert.areEqual('INVALID_INPUT', result.fault.code, 'Codigo tipado');
    }

    @IsTest
    static void shouldReturnMockVision_WhenFlagOn() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Visao360TestFactory.ligarMock();
            Account acc = Visao360TestFactory.novaConta('João da Silva', Visao360Mock.DOC_JOAO, 'CPF');
            Test.startTest();
            Visao360DTOs.VisaoResult result = Visao360CustomerService.getVisao(acc.Id);
            Test.stopTest();

            Assert.areEqual('João da Silva', result.header.nome, 'Header via documento da conta');
            Assert.areEqual(7, result.interacoes.size(), 'Timeline rica do Joao');
            Assert.areEqual(5, result.casos.size(), 'Historico do Joao');
        }
    }

    @IsTest
    static void shouldMaskDocument_WhenRealPfAndPj() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account pf = Visao360TestFactory.novaConta('Cliente PF', '12345678901', 'CPF');
            Account pj = Visao360TestFactory.novaConta('Empresa PJ', '12345678000190', 'CNPJ');
            Test.startTest();
            Visao360DTOs.VisaoResult visaoPf = Visao360CustomerService.getVisao(pf.Id);
            Visao360DTOs.VisaoResult visaoPj = Visao360CustomerService.getVisao(pj.Id);
            Test.stopTest();

            Assert.areEqual('***.***.***-01', visaoPf.header.documentoMascarado, 'CPF mascarado (RN-15)');
            Assert.areEqual('Pessoa Física', visaoPf.header.tipoPessoa, 'Tipo PF');
            Assert.areEqual('**.***.***/000190', visaoPj.header.documentoMascarado, 'CNPJ mascarado (RN-15)');
            Assert.areEqual('Pessoa Jurídica', visaoPj.header.tipoPessoa, 'Tipo PJ');
            Assert.isTrue(visaoPf.casos.isEmpty(), 'Sem casos: vazio discreto, sem erro (EL-08)');
            Assert.isTrue(visaoPf.metas.isEmpty(), 'Sem metas no real sem data lake: vazio discreto');
        }
    }

    @IsTest
    static void shouldListRelationships_WhenAcrRoles() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = Visao360TestFactory.novaConta('Titular ARC', '44455566677', 'CPF');
            Contact conjuge = new Contact(LastName = 'Cônjuge', AccountId = acc.Id);
            insert conjuge;
            AccountContactRelation rel = [
                SELECT Id, Roles FROM AccountContactRelation
                WHERE AccountId = :acc.Id AND ContactId = :conjuge.Id LIMIT 1
            ];
            rel.Roles = 'Cônjuge';
            update rel;
            Test.startTest();
            Visao360DTOs.VisaoResult result = Visao360CustomerService.getVisao(acc.Id);
            Test.stopTest();

            Assert.areEqual(2, result.arcResumo.size(), 'Raiz + vinculo (Cen 4)');
            Assert.areEqual('Titular', result.arcResumo[0].papel, 'Raiz como titular');
            Assert.areEqual('Cônjuge', result.arcResumo[1].papel, 'Papel do ACR');
        }
    }

    @IsTest
    static void shouldMapCases_WhenAccountHasCases() {
        User agente = Visao360TestFactory.novoAgente();
        System.runAs(agente) {
            Account acc = Visao360TestFactory.novaConta('Cliente Casos', '55566677788', 'CPF');
            Visao360TestFactory.novoCaso(acc.Id);
            Test.startTest();
            Visao360DTOs.VisaoResult result = Visao360CustomerService.getVisao(acc.Id);
            Test.stopTest();

            Assert.areEqual(1, result.casos.size(), 'Caso listado (Cen 14)');
            Assert.areEqual('Dúvida sobre fatura', result.casos[0].assunto, 'Assunto mapeado');
            Assert.areEqual('Central', result.casos[0].canal, 'Canal mapeado');
        }
    }
}
