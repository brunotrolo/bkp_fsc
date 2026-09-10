/**
 * @description Fabrica compartilhada dos testes da Visao 360.
 * Cria operador com PS_Visao360_Operador, contas demo (S1 Joao, S2 Industria,
 * S3 Maria/Carlos — mesmos documentos dos fixtures), ativos por RecordType,
 * ofertas e casos. Nunca depende de dado da org (SeeAllData=false).
 */
@IsTest
public class Visao360TestFactory {

    /** Operador com o permission set da jornada atribuido. */
    public static User novoAgente() {
        String uniq = String.valueOf(Datetime.now().getTime())
            + String.valueOf(Math.abs(Crypto.getRandomInteger()));
        User agente = new User(
            Alias = 'ag' + uniq.right(6),
            Email = 'agente.visao360@teste.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'AgenteVisao360',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/Sao_Paulo',
            Username = 'agente.' + uniq + '@visao360.teste'
        );
        insert agente;
        Id psId = [SELECT Id FROM PermissionSet WHERE Name = 'PS_Visao360_Operador' LIMIT 1].Id;
        insert new PermissionSetAssignment(AssigneeId = agente.Id, PermissionSetId = psId);
        return agente;
    }

    /** Liga o modo mock no nivel org (flag propria do dominio). */
    public static void ligarMock() {
        Visao360Mock__c cs = new Visao360Mock__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            UsarMock__c = true
        );
        insert cs;
    }

    /** Conta demo com documento e campos do modelo T-A04. */
    public static Account novaConta(String nome, String doc, String tipoDoc) {
        Account acc = new Account(
            Name = nome,
            Document__c = doc,
            DocumentType__c = tipoDoc,
            CustomerSegment__c = 'EXCLUSIVO',
            Phone = '(11) 99999-1234',
            CustomerSince__c = Date.newInstance(2018, 2, 3),
            MaritalStatus__c = 'Casado',
            CreditRating__c = 872,
            ProfileCompleteness__c = 80,
            FamilySize__c = 4
        );
        insert acc;
        return acc;
    }

    /** Ativos demo por familia (1 por ProductType) vinculados a conta. */
    public static List<Asset> novosAtivos(Id accountId) {
        List<Asset> ativos = new List<Asset>{
            novoAtivo(accountId, 'Cartão Visa Infinite', 'CART-1234', 'Ativo', 'CARTAO'),
            novoAtivo(accountId, 'Conta Digital', 'CONT-0001', 'Ativo', 'CONTA_DIGITAL'),
            novoAtivo(accountId, 'Consórcio Imóvel', 'CONS-1234-045', 'Ativo', 'CONSORCIO'),
            novoAtivo(accountId, 'CDB Porto Bank', 'INV-88114', 'Ativo', 'INVESTIMENTOS')
        };
        insert ativos;
        return ativos;
    }

    public static Asset novoAtivo(Id accountId, String nome, String contrato, String situacao, String tipoProduto) {
        return new Asset(
            Name = nome,
            AccountId = accountId,
            ExternalContractId__c = contrato,
            ViaStatus__c = situacao,
            ProductType__c = tipoProduto
        );
    }

    /** Oferta NBO demo (idempotente por ExternalOfferId__c). */
    public static Opportunity novaOferta(Id accountId, String externalId, String stage) {
        Opportunity opp = new Opportunity(
            Name = 'Oferta ' + externalId,
            AccountId = accountId,
            ExternalOfferId__c = externalId,
            StageName = stage,
            CloseDate = Date.today().addDays(30),
            Propensity_Score__c = 92,
            Confidence__c = 'Alta',
            Offer_Safra__c = '2026-09'
        );
        insert opp;
        return opp;
    }

    /** Caso demo vinculado a conta. */
    public static Case novoCaso(Id accountId) {
        Case c = new Case(
            AccountId = accountId,
            Subject = 'Dúvida sobre fatura',
            Type = 'Cartões',
            Origin = 'Central',
            Status = 'New'
        );
        insert c;
        return c;
    }
}
