/**
 * @description Sincronizacao NBO em segundo plano (T-C04, RN-06, RN-17):
 * upsert idempotente de Opportunity por ExternalOfferId__c
 * ({doc}_{cod}_{periodo}); mesma safra nunca duplica; vencidas passam a
 * Closed Lost com motivo de expiracao; ausentes-mas-validas sao mantidas.
 * Em mock: retorna sem DML (fixture nunca vira dado real).
 */
public with sharing class Visao360SyncQueueable implements Queueable {

    private final Id accountId;
    private final String safra;
    private final List<Visao360DTOs.NBOOfferDTO> offers;

    public Visao360SyncQueueable(Id accountId, String safra, List<Visao360DTOs.NBOOfferDTO> offers) {
        this.accountId = accountId;
        this.safra = safra;
        this.offers = offers == null ? new List<Visao360DTOs.NBOOfferDTO>() : offers;
    }

    public void execute(QueueableContext ctx) {
        if (Visao360Mock.isEnabled()) {
            return;
        }
        if (accountId == null || offers.isEmpty()) {
            return;
        }
        List<Opportunity> paraUpsert = new List<Opportunity>();
        for (Visao360DTOs.NBOOfferDTO o : offers) {
            if (String.isBlank(o.externalOfferId)) {
                continue;
            }
            Opportunity opp = new Opportunity();
            opp.AccountId = accountId;
            opp.ExternalOfferId__c = o.externalOfferId;
            opp.Name = nomeOferta(o);
            opp.StageName = 'Prospecting';
            opp.CloseDate = closeDateDe(o);
            opp.Propensity_Score__c = o.propensityScore;
            opp.Confidence__c = normalizarConfianca(o.confianca);
            opp.OmniScript_Key__c = o.omniScriptKey;
            opp.ExpirationDate__c = dataDe(o.validade);
            opp.Offer_Safra__c = safra;
            opp.Offer_Reasons__c = o.motivos == null ? null : String.join(o.motivos, '\n');
            paraUpsert.add(opp);
        }
        if (!paraUpsert.isEmpty()) {
            Database.upsert(paraUpsert, Opportunity.ExternalOfferId__c, false);
        }
        expirarSafraAnterior();
    }

    // =================================================================
    // Privados
    // =================================================================

    private void expirarSafraAnterior() {
        List<Opportunity> abertas = [
            SELECT Id, ExternalOfferId__c, ExpirationDate__c, Offer_Safra__c
            FROM Opportunity
            WHERE AccountId = :accountId
                AND ExternalOfferId__c != null
                AND StageName NOT IN ('Closed Won', 'Closed Lost')
            WITH USER_MODE
            LIMIT 200
        ];
        Set<String> safraAtual = new Set<String>();
        for (Visao360DTOs.NBOOfferDTO o : offers) {
            safraAtual.add(o.externalOfferId);
        }
        List<Opportunity> paraExpirar = new List<Opportunity>();
        for (Opportunity opp : abertas) {
            Boolean ausenteNaResposta = !safraAtual.contains(opp.ExternalOfferId__c);
            Boolean outraSafra = !String.isBlank(safra)
                && !String.isBlank(opp.Offer_Safra__c)
                && opp.Offer_Safra__c != safra;
            Boolean vencida = opp.ExpirationDate__c != null && opp.ExpirationDate__c < Date.today();
            if (ausenteNaResposta && (outraSafra || vencida)) {
                opp.StageName = 'Closed Lost';
                opp.Loss_Reason__c = 'Safra expirada';
                paraExpirar.add(opp);
            }
        }
        if (!paraExpirar.isEmpty()) {
            update paraExpirar;
        }
    }

    private static String nomeOferta(Visao360DTOs.NBOOfferDTO o) {
        String base = String.isBlank(o.productName) ? 'Oferta NBO' : o.productName;
        return (base + ' ' + String.valueOf(safraDe(o))).left(120);
    }

    private static String safraDe(Visao360DTOs.NBOOfferDTO o) {
        if (!String.isBlank(o.chaveSafra)) {
            return o.chaveSafra;
        }
        return String.isBlank(o.externalOfferId) ? '' : o.externalOfferId;
    }

    private static Date closeDateDe(Visao360DTOs.NBOOfferDTO o) {
        Date validade = dataDe(o.validade);
        return validade == null ? Date.today().addDays(30) : validade;
    }

    /** Aceita dd/MM/yyyy (motor) ou yyyy-MM-dd; fora disso, nulo. */
    public static Date dataDe(String texto) {
        if (String.isBlank(texto)) {
            return null;
        }
        try {
            if (Pattern.matches('[0-9]{2}/[0-9]{2}/[0-9]{4}', texto)) {
                List<String> p = texto.split('/');
                return Date.newInstance(Integer.valueOf(p[2]), Integer.valueOf(p[1]), Integer.valueOf(p[0]));
            }
            if (Pattern.matches('[0-9]{4}-[0-9]{2}-[0-9]{2}', texto)) {
                return Date.valueOf(texto);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    /** Normaliza para os valores API do picklist (Alta/Media/Baixa). */
    private static String normalizarConfianca(String confianca) {
        if (confianca == 'Alta') {
            return 'Alta';
        }
        if (confianca == 'Media' || confianca == 'Média') {
            return 'Media';
        }
        if (confianca == 'Baixa') {
            return 'Baixa';
        }
        return null;
    }
}
