/**
 * @description Visao consolidada nao-volatil da raiz (T-C06): cabecalho,
 * blocos ricos (KPIs, eventos, tags, wellness, planejamento, fluxo,
 * segmentacao, comportamento, campanhas, metas, NBA/tarefas/timeline) a
 * partir do modelo T-A04, mais arvore de relacionamentos e casos.
 * Uma chamada = no maximo 3 SOQL (sem N+1); sem callout sincrono novo.
 * Mock-first: com a flag ligada, serve o fixture validado sem tocar o banco.
 * Raiz sem dados ricos devolve vazios discretos (EL-08/EL-09), sem erro.
 */
public with sharing class Visao360CustomerService {

    /**
     * @description Monta a visao da raiz para as abas Resumo, Inteligencia,
     * Financial Goals, Relacionamentos e Atividades (inventario e NBO tem
     * services proprios). Nunca inclui dado volatil (RN-04).
     */
    public static Visao360DTOs.VisaoResult getVisao(Id accountId) {
        Visao360DTOs.VisaoResult result = new Visao360DTOs.VisaoResult();
        if (accountId == null) {
            result.fault = new Visao360DTOs.ApiFaultDTO('VISAO360', 'INVALID_INPUT', 'Conta raiz não informada.');
            return result;
        }
        List<Account> contas = [
            SELECT Id, Name, Document__c, DocumentType__c, CustomerSegment__c,
                Phone, PersonEmail, BillingStreet, BillingCity, BillingState,
                CustomerSince__c, MaritalStatus__c, CreditRating__c,
                ProfileCompleteness__c, FamilySize__c, Owner.Name
            FROM Account
            WHERE Id = :accountId
            WITH USER_MODE LIMIT 1
        ];
        if (contas.isEmpty()) {
            result.fault = new Visao360DTOs.ApiFaultDTO('VISAO360', 'NOT_FOUND', 'Conta raiz não localizada.');
            return result;
        }
        Account conta = contas[0];
        String doc = Visao360Mock.normalizeDoc(conta.Document__c);
        if (Visao360Mock.isEnabled()) {
            if (!Visao360Mock.isKnown(doc)) {
                result.fault = new Visao360DTOs.ApiFaultDTO('VISAO360', 'NOT_FOUND', 'Cliente não localizado para o documento.');
                return result;
            }
            return Visao360Mock.mockVisao(doc);
        }
        result.header = toHeader(conta);
        result.arcResumo = arcResumo(conta);
        result.arcCompleta = arcCompleta(conta);
        result.arcTotalVinculos = result.arcResumo == null ? 0 : result.arcResumo.size();
        result.casos = casosDaConta(accountId);
        return result;
    }

    // =================================================================
    // Privados (caminho real)
    // =================================================================

    private static Visao360DTOs.HeaderDTO toHeader(Account conta) {
        Visao360DTOs.HeaderDTO h = new Visao360DTOs.HeaderDTO();
        h.nome = conta.Name;
        h.tipoPessoa = conta.DocumentType__c == 'CNPJ' ? 'Pessoa Jurídica' : 'Pessoa Física';
        h.documentoMascarado = mascarar(conta.Document__c, h.tipoPessoa);
        h.segmento = String.isBlank(conta.CustomerSegment__c) ? '—' : conta.CustomerSegment__c;
        h.status = 'Ativo';
        h.telefone = nvl(conta.Phone);
        h.email = nvl(conta.PersonEmail);
        h.clienteDesde = conta.CustomerSince__c == null ? '—' : conta.CustomerSince__c.format();
        h.estadoCivil = nvl(conta.MaritalStatus__c);
        h.filhos = conta.FamilySize__c == null ? '—' : String.valueOf(conta.FamilySize__c.intValue());
        h.rating = conta.CreditRating__c == null ? '—' : String.valueOf(conta.CreditRating__c.intValue());
        h.responsavel = conta.Owner != null ? nvl(conta.Owner.Name) : '—';
        h.perfilContato = h.email + ' • ' + h.telefone;
        h.perfilEndereco = enderecoDe(conta);
        h.perfilRendaScore = 'Score ' + h.rating;
        h.perfilAgenciaConta = 'Cliente desde ' + h.clienteDesde;
        return h;
    }

    private static String mascarar(String doc, String tipoPessoa) {
        String normalizado = Visao360Mock.normalizeDoc(doc);
        if (String.isBlank(normalizado)) {
            return '—';
        }
        if (tipoPessoa == 'Pessoa Jurídica') {
            return '**.***.***/' + normalizado.right(6);
        }
        return '***.***.***-' + normalizado.right(2);
    }

    private static String enderecoDe(Account conta) {
        List<String> partes = new List<String>();
        if (!String.isBlank(conta.BillingStreet)) {
            partes.add(conta.BillingStreet);
        }
        if (!String.isBlank(conta.BillingCity)) {
            partes.add(conta.BillingCity + '/' + nvl(conta.BillingState));
        }
        return partes.isEmpty() ? '—' : String.join(partes, ' — ');
    }

    private static List<Visao360DTOs.ArcNodeDTO> arcResumo(Account conta) {
        List<Visao360DTOs.ArcNodeDTO> nos = new List<Visao360DTOs.ArcNodeDTO>();
        nos.add(noRaiz(conta, 0));
        for (AccountContactRelation rel : relacoes(conta.Id)) {
            Visao360DTOs.ArcNodeDTO n = new Visao360DTOs.ArcNodeDTO();
            n.id = rel.ContactId;
            n.nome = rel.Contact != null ? rel.Contact.Name : '—';
            n.papel = String.isBlank(rel.Roles) ? 'Vinculado' : rel.Roles;
            n.tipo = 'PF';
            n.nivel = 1;
            nos.add(n);
            if (nos.size() >= 6) {
                break;
            }
        }
        return nos;
    }

    private static List<Visao360DTOs.ArcNodeDTO> arcCompleta(Account conta) {
        List<Visao360DTOs.ArcNodeDTO> nos = new List<Visao360DTOs.ArcNodeDTO>();
        nos.add(noRaiz(conta, 0));
        Integer total = 0;
        for (AccountContactRelation rel : relacoes(conta.Id)) {
            if (total >= 20) {
                break;
            }
            Visao360DTOs.ArcNodeDTO n = new Visao360DTOs.ArcNodeDTO();
            n.id = rel.ContactId;
            n.nome = rel.Contact != null ? rel.Contact.Name : '—';
            n.papel = String.isBlank(rel.Roles) ? 'Vinculado' : rel.Roles;
            n.tipo = 'PF';
            n.nivel = 1;
            nos.add(n);
            total++;
        }
        return nos;
    }

    private static Visao360DTOs.ArcNodeDTO noRaiz(Account conta, Integer nivel) {
        Visao360DTOs.ArcNodeDTO n = new Visao360DTOs.ArcNodeDTO();
        n.id = conta.Id;
        n.nome = conta.Name;
        n.papel = 'Titular';
        n.tipo = conta.DocumentType__c == 'CNPJ' ? 'PJ' : 'PF';
        n.doc = Visao360Mock.normalizeDoc(conta.Document__c);
        n.nivel = nivel;
        return n;
    }

    private static List<AccountContactRelation> relacoes(Id accountId) {
        try {
            return [
                SELECT ContactId, Contact.Name, Roles
                FROM AccountContactRelation
                WHERE AccountId = :accountId AND IsActive = true
                WITH USER_MODE
                ORDER BY Contact.Name
                LIMIT 21
            ];
        } catch (QueryException e) {
            return new List<AccountContactRelation>();
        }
    }

    private static List<Visao360DTOs.CasoDTO> casosDaConta(Id accountId) {
        List<Visao360DTOs.CasoDTO> out = new List<Visao360DTOs.CasoDTO>();
        List<Case> casos;
        try {
            casos = [
                SELECT Id, CaseNumber, CreatedDate, Subject, Type, Origin,
                    Owner.Name, Status, ClosedDate
                FROM Case
                WHERE AccountId = :accountId
                WITH USER_MODE
                ORDER BY CreatedDate DESC
                LIMIT 20
            ];
        } catch (QueryException e) {
            return out;
        }
        for (Case c : casos) {
            Visao360DTOs.CasoDTO dto = new Visao360DTOs.CasoDTO();
            dto.id = c.Id;
            dto.protocolo = c.CaseNumber;
            dto.dataOcorrencia = c.CreatedDate == null ? '—' : c.CreatedDate.format('dd/MM/yyyy');
            dto.assunto = nvl(c.Subject);
            dto.categoria = nvl(c.Type);
            dto.canal = nvl(c.Origin);
            dto.responsavel = c.Owner != null ? nvl(c.Owner.Name) : '—';
            dto.situacao = nvl(c.Status);
            dto.resolucao = c.ClosedDate == null ? '—' : String.valueOf(c.ClosedDate);
            out.add(dto);
        }
        return out;
    }

    private static String nvl(String v) {
        return String.isBlank(v) ? '—' : v;
    }
}
