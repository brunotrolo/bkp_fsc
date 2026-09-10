/**
 * Seed da Visão 360 (household-360/001) — S1 João PF completo, S2 Indústria PJ,
 * S3 Maria (vazios) + Carlos (NBO banner+retry). Idempotente: pula o que já
 * existe por Document__c / ExternalContractId__c / ExternalOfferId__c.
 * Executar DEPOIS do deploy: sf apex run -f scripts/seed-household-360.apex -o FSC
 * Pré-requisito: ligar o mock-first criando o registro org de Visao360Mock__c
 * (UsarMock__c=true) via Setup — motor NBO e core seguem fora do ar.
 */

Map<String, Account> contas = new Map<String, Account>();
for (Account a : [SELECT Id, Document__c FROM Account WHERE Document__c IN ('12345678900','12ABC345000190','11111111111','99999999999')]) {
    contas.put(a.Document__c, a);
}

Account joao = contas.get('12345678900');
if (joao == null) {
    joao = new Account(Name = 'João da Silva', Document__c = '12345678900', DocumentType__c = 'CPF',
        CustomerSegment__c = 'EXCLUSIVO', Phone = '(11) 99999-1234',
        CustomerSince__c = Date.newInstance(2018, 2, 3), MaritalStatus__c = 'Casado',
        CreditRating__c = 872, ProfileCompleteness__c = 80, FamilySize__c = 4);
    insert joao;
    System.debug('SEED S1 conta João criada: ' + joao.Id);
} else {
    System.debug('SEED S1 conta João já existe: ' + joao.Id);
}

Account industria = contas.get('12ABC345000190');
if (industria == null) {
    industria = new Account(Name = 'Indústria Exemplo S.A.', Document__c = '12ABC345000190', DocumentType__c = 'CNPJ',
        CustomerSegment__c = 'CORPORATE', Phone = '(11) 3333-4444',
        CustomerSince__c = Date.newInstance(2021, 6, 12),
        CreditRating__c = 810, ProfileCompleteness__c = 65);
    insert industria;
    System.debug('SEED S2 conta Indústria criada: ' + industria.Id);
} else {
    System.debug('SEED S2 conta Indústria já existe: ' + industria.Id);
}

Account maria = contas.get('11111111111');
if (maria == null) {
    maria = new Account(Name = 'Maria Oliveira', Document__c = '11111111111', DocumentType__c = 'CPF',
        CustomerSegment__c = 'VAREJO', Phone = '(11) 97777-8899',
        CustomerSince__c = Date.newInstance(2024, 3, 20), MaritalStatus__c = 'Solteira',
        CreditRating__c = 640, ProfileCompleteness__c = 45, FamilySize__c = 1);
    insert maria;
    System.debug('SEED S3 conta Maria criada: ' + maria.Id);
} else {
    System.debug('SEED S3 conta Maria já existe: ' + maria.Id);
}

Account carlos = contas.get('99999999999');
if (carlos == null) {
    carlos = new Account(Name = 'Carlos Souza', Document__c = '99999999999', DocumentType__c = 'CPF',
        CustomerSegment__c = 'VAREJO', Phone = '(11) 96666-7777',
        CustomerSince__c = Date.newInstance(2023, 1, 10), MaritalStatus__c = 'Casado',
        CreditRating__c = 705, ProfileCompleteness__c = 60, FamilySize__c = 2);
    insert carlos;
    System.debug('SEED S3 conta Carlos criada: ' + carlos.Id);
} else {
    System.debug('SEED S3 conta Carlos já existe: ' + carlos.Id);
}

// --- Contatos + vínculos (árvore: cônjuge + sócio-administrador) ---
List<Contact> conjuge = [SELECT Id FROM Contact WHERE AccountId = :joao.Id AND LastName = 'Silva' LIMIT 1];
Contact conjugeJoao;
if (conjuge.isEmpty()) {
    conjugeJoao = new Contact(LastName = 'Silva', FirstName = 'Maria', AccountId = joao.Id,
        Email = 'maria.silva@email.com', Phone = '(11) 98888-5678');
    insert conjugeJoao;
    System.debug('SEED contato cônjuge criado: ' + conjugeJoao.Id);
} else {
    conjugeJoao = conjuge[0];
}
List<AccountContactRelation> acrJoao = [SELECT Id FROM AccountContactRelation WHERE AccountId = :joao.Id AND ContactId = :conjugeJoao.Id LIMIT 1];
if (!acrJoao.isEmpty()) {
    // ACR direta conta-contato já existe pelo insert acima; garante o papel.
    AccountContactRelation r = [SELECT Id, Roles FROM AccountContactRelation WHERE Id = :acrJoao[0].Id];
    if (r.Roles != 'Cônjuge') { r.Roles = 'Cônjuge'; update r; }
}

List<Contact> socio = [SELECT Id FROM Contact WHERE AccountId = :industria.Id AND LastName = 'Souza (sócio)' LIMIT 1];
Contact socioInd;
if (socio.isEmpty()) {
    socioInd = new Contact(LastName = 'Souza (sócio)', FirstName = 'João', AccountId = industria.Id,
        Email = 'joao.silva@email.com');
    insert socioInd;
    System.debug('SEED contato sócio criado: ' + socioInd.Id);
} else {
    socioInd = socio[0];
}
List<AccountContactRelation> acrInd = [SELECT Id, Roles FROM AccountContactRelation WHERE AccountId = :industria.Id AND ContactId = :socioInd.Id LIMIT 1];
if (!acrInd.isEmpty() && acrInd[0].Roles != 'Sócio-administrador') {
    acrInd[0].Roles = 'Sócio-administrador';
    update acrInd[0];
}

// --- Ativos (1 por contrato; pula existentes) ---
Map<String, Asset> ativosExistentes = new Map<String, Asset>();
for (Asset a : [SELECT Id, ExternalContractId__c FROM Asset WHERE ExternalContractId__c IN ('CART-1234','CART-3456','CART-9012','CONT-0001','CONS-1234-045','CONS-5678-012','INV-88114','INV-77231','CONT-9876','INV-55021','CONT-5432','CONT-7777')]) {
    ativosExistentes.put(a.ExternalContractId__c, a);
}
List<Asset> novos = new List<Asset>();
// S1 João: 8 ativos (3 cartões, conta, 2 consórcios, 2 investimentos)
if (!ativosExistentes.containsKey('CART-1234')) novos.add(new Asset(Name='Cartão Visa Infinite', AccountId=joao.Id, ExternalContractId__c='CART-1234', ViaStatus__c='Ativo', ProductType__c='CARTAO', CardBrand__c='Visa', Last4__c='1234', HolderName__c='João da Silva'));
if (!ativosExistentes.containsKey('CART-3456')) novos.add(new Asset(Name='Cartão Mastercard Black', AccountId=joao.Id, ExternalContractId__c='CART-3456', ViaStatus__c='Bloqueado', ProductType__c='CARTAO', CardBrand__c='Mastercard', Last4__c='3456', HolderName__c='João da Silva'));
if (!ativosExistentes.containsKey('CART-9012')) novos.add(new Asset(Name='Cartão Visa Gold', AccountId=joao.Id, ExternalContractId__c='CART-9012', ViaStatus__c='Cancelado', ProductType__c='CARTAO', CardBrand__c='Visa', Last4__c='9012', HolderName__c='Maria da Silva'));
if (!ativosExistentes.containsKey('CONT-0001')) novos.add(new Asset(Name='Conta Digital', AccountId=joao.Id, ExternalContractId__c='CONT-0001', ViaStatus__c='Ativo', ProductType__c='CONTA_DIGITAL'));
if (!ativosExistentes.containsKey('CONS-1234-045')) novos.add(new Asset(Name='Consórcio Imóvel', AccountId=joao.Id, ExternalContractId__c='CONS-1234-045', ViaStatus__c='Ativo', ProductType__c='CONSORCIO', ConsorcioGrupo__c='1234', ConsorcioCota__c='045'));
if (!ativosExistentes.containsKey('CONS-5678-012')) novos.add(new Asset(Name='Consórcio Veículo', AccountId=joao.Id, ExternalContractId__c='CONS-5678-012', ViaStatus__c='Cancelado', ProductType__c='CONSORCIO', ConsorcioGrupo__c='5678', ConsorcioCota__c='012'));
if (!ativosExistentes.containsKey('INV-88114')) novos.add(new Asset(Name='CDB Porto Bank', AccountId=joao.Id, ExternalContractId__c='INV-88114', ViaStatus__c='Ativo', ProductType__c='INVESTIMENTOS', InvestProduto__c='CDB Porto Bank', Rentabilidade__c='+11,2% a.a.'));
if (!ativosExistentes.containsKey('INV-77231')) novos.add(new Asset(Name='Fundo de Ações Dividendos', AccountId=joao.Id, ExternalContractId__c='INV-77231', ViaStatus__c='Ativo', ProductType__c='INVESTIMENTOS', InvestProduto__c='Fundo de Ações Dividendos', Rentabilidade__c='+18,3% em 12m'));
// S2 Indústria: conta empresarial + CDB
if (!ativosExistentes.containsKey('CONT-9876')) novos.add(new Asset(Name='Conta Empresarial', AccountId=industria.Id, ExternalContractId__c='CONT-9876', ViaStatus__c='Ativo', ProductType__c='CONTA_DIGITAL'));
if (!ativosExistentes.containsKey('INV-55021')) novos.add(new Asset(Name='CDB Empresarial', AccountId=industria.Id, ExternalContractId__c='INV-55021', ViaStatus__c='Ativo', ProductType__c='INVESTIMENTOS', InvestProduto__c='CDB Empresarial', Rentabilidade__c='+11,8% a.a.'));
// S3 Maria e Carlos: só conta
if (!ativosExistentes.containsKey('CONT-5432')) novos.add(new Asset(Name='Conta Digital', AccountId=maria.Id, ExternalContractId__c='CONT-5432', ViaStatus__c='Ativo', ProductType__c='CONTA_DIGITAL'));
if (!ativosExistentes.containsKey('CONT-7777')) novos.add(new Asset(Name='Conta Digital', AccountId=carlos.Id, ExternalContractId__c='CONT-7777', ViaStatus__c='Ativo', ProductType__c='CONTA_DIGITAL'));
if (!novos.isEmpty()) { insert novos; System.debug('SEED ativos inseridos: ' + novos.size()); } else { System.debug('SEED ativos: nada novo'); }

// --- Ofertas NBO do João (safra 2026-09; pula existentes) ---
Set<String> oppsExistentes = new Set<String>();
for (Opportunity o : [SELECT ExternalOfferId__c FROM Opportunity WHERE ExternalOfferId__c IN ('12345678900_BLACK_2026-09','12345678900_CONSORCIO_2026-09','12345678900_CDB_2026-09')]) {
    oppsExistentes.add(o.ExternalOfferId__c);
}
List<Opportunity> novasOpps = new List<Opportunity>();
if (!oppsExistentes.contains('12345678900_BLACK_2026-09')) novasOpps.add(new Opportunity(Name='Cartão Black 2026-09', AccountId=joao.Id, ExternalOfferId__c='12345678900_BLACK_2026-09', StageName='Prospecting', CloseDate=Date.newInstance(2026,9,30), Propensity_Score__c=92, Confidence__c='Alta', OmniScript_Key__c='osSaleCreditCard', ExpirationDate__c=Date.newInstance(2026,9,30), Offer_Safra__c='2026-09', Offer_Reasons__c='Gasto médio de R$ 8.400/mês nos últimos 6 meses\nRelacionamento de 8 anos sem atraso\nPerfil Exclusivo sem cartão premium'));
if (!oppsExistentes.contains('12345678900_CONSORCIO_2026-09')) novasOpps.add(new Opportunity(Name='Consórcio Imóvel 2026-09', AccountId=joao.Id, ExternalOfferId__c='12345678900_CONSORCIO_2026-09', StageName='Prospecting', CloseDate=Date.newInstance(2026,9,30), Propensity_Score__c=81, Confidence__c='Alta', OmniScript_Key__c='osSaleConsorcio', ExpirationDate__c=Date.newInstance(2026,9,30), Offer_Safra__c='2026-09'));
if (!oppsExistentes.contains('12345678900_CDB_2026-09')) novasOpps.add(new Opportunity(Name='CDB 102% 2026-09', AccountId=joao.Id, ExternalOfferId__c='12345678900_CDB_2026-09', StageName='Prospecting', CloseDate=Date.newInstance(2026,10,15), Propensity_Score__c=74, Confidence__c='Media', OmniScript_Key__c='osSaleInvestimento', ExpirationDate__c=Date.newInstance(2026,10,15), Offer_Safra__c='2026-09'));
if (!novasOpps.isEmpty()) { insert novasOpps; System.debug('SEED ofertas inseridas: ' + novasOpps.size()); } else { System.debug('SEED ofertas: nada novo'); }

// --- Casos do João (pula se já houver) ---
Integer casosJoao = [SELECT COUNT() FROM Case WHERE AccountId = :joao.Id];
if (casosJoao == 0) {
    insert new List<Case>{
        new Case(AccountId=joao.Id, Subject='Dúvida sobre fatura do cartão', Type='Cartões', Origin='Central', Status='Closed'),
        new Case(AccountId=joao.Id, Subject='Atualização cadastral', Type='Cadastro', Origin='Agência', Status='Closed'),
        new Case(AccountId=joao.Id, Subject='Simulação de consórcio', Type='Consórcio', Origin='App', Status='New'),
        new Case(AccountId=joao.Id, Subject='Contestação de tarifa de pacote', Type='Tarifas', Origin='App', Status='Closed'),
        new Case(AccountId=joao.Id, Subject='Aumento de limite do cartão', Type='Cartões', Origin='Agência', Status='Closed')
    };
    System.debug('SEED 5 casos do João inseridos');
} else {
    System.debug('SEED casos do João já existem: ' + casosJoao);
}

System.debug('SEED household-360 concluído: S1 João=' + joao.Id + ' S2 Indústria=' + industria.Id + ' S3 Maria=' + maria.Id + ' Carlos=' + carlos.Id);
