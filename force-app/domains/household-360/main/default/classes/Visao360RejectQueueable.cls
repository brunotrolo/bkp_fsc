/**
 * @description Recusa NBO em segundo plano (T-C04, Cen 12): marca a oferta
 * como Closed Lost com o motivo rapido e devolve o feedback ao motor.
 * A UI ja removeu o card de forma otimista; falha aqui nunca reverte a tela.
 * Em mock: retorna sem DML e sem callout.
 */
public with sharing class Visao360RejectQueueable implements Queueable, Database.AllowsCallouts {

    private final String externalOfferId;
    private final String reason;

    public Visao360RejectQueueable(String externalOfferId, String reason) {
        this.externalOfferId = externalOfferId;
        this.reason = reason;
    }

    public void execute(QueueableContext ctx) {
        if (Visao360Mock.isEnabled()) {
            return;
        }
        if (String.isBlank(externalOfferId)) {
            return;
        }
        List<Opportunity> opps = [
            SELECT Id FROM Opportunity
            WHERE ExternalOfferId__c = :externalOfferId
            WITH USER_MODE LIMIT 1
        ];
        if (!opps.isEmpty()) {
            opps[0].StageName = 'Closed Lost';
            opps[0].Loss_Reason__c = String.isBlank(reason) ? 'Sem interesse' : reason;
            update opps[0];
        }
        // Feedback ao motor: melhor esforco, nunca falha o job.
        try {
            Map<String, String> payload = new Map<String, String>{
                'offerId' => externalOfferId,
                'reason' => String.isBlank(reason) ? 'SEM_INTERESSE' : reason
            };
            Visao360HttpService.post(
                Visao360NBOService.NC_NBO, 'feedback', JSON.serialize(payload), 3000);
        } catch (Exception feedbackEx) {
            // Intencional: recusa local ja registrada acima prevalece; o
            // feedback sera reenviado na proxima sincronizacao de safra.
            String detalhe = feedbackEx.getMessage();
            if (String.isBlank(detalhe)) {
                return;
            }
        }
    }
}
