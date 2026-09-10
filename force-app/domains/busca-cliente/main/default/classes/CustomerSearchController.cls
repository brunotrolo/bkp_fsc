/**
 * @description Fachada AuraEnabled da jornada, sem logica de negocio (T-C08).
 * Valida via DocumentValidator, orquestra Cadastro/Holding/NBO e enfileira o
 * upsert progressivo sem DML sincrono. O LWC chama identifyCadastro e
 * fetchNboOffers em Promise.allSettled para o paralelismo de P2/Cen 21.
 */
public with sharing class CustomerSearchController {

    /** Cadastro + carteira + holding para faixa, hub e holding (P3/P4/P5). */
    @AuraEnabled
    public static BuscaClienteDTOs.CustomerSearchResultDTO identifyCadastro(String normalizedDoc, String modo) {
        DocumentValidator.ValidationResult validation = DocumentValidator.validate(normalizedDoc, modo);
        if (!validation.valid) {
            throw new AuraHandledException(validation.message);
        }
        BuscaClienteDTOs.CustomerSearchResultDTO dto = new BuscaClienteDTOs.CustomerSearchResultDTO();
        dto.documentNormalized = validation.normalized;
        dto.documentMasked = DocumentValidator.mask(validation.normalized, validation.docType);
        dto.docType = validation.docType;
        CadastroService.CadastroResult cadastro = CadastroService.fetch(validation.normalized);
        dto.demographic = cadastro.demographic;
        dto.portoBankWallet = cadastro.wallet;
        if (cadastro.fault != null) {
            dto.partialFaults.add(cadastro.fault);
        }
        HoldingService.HoldingResult holding = HoldingService.fetch(validation.normalized);
        dto.holdingWallet = holding.items;
        if (holding.fault != null) {
            dto.partialFaults.add(holding.fault);
        }
        enqueueUpsert(dto);
        return dto;
    }

    /** Ofertas NBO para o banner com gate (P6). Chamada separada e paralela. */
    @AuraEnabled
    public static List<BuscaClienteDTOs.NboOfferDTO> fetchNboOffers(String normalizedDoc) {
        String doc = DocumentValidator.normalizeDoc(normalizedDoc);
        if (String.isBlank(doc)) {
            throw new AuraHandledException('Informe o documento para consultar ofertas.');
        }
        NboService.NboResult result = NboService.fetch(doc);
        if (result.fault != null && result.offers.isEmpty()) {
            throw new AuraHandledException(result.fault.message);
        }
        return result.offers;
    }

    /** Vias de cartao, lazy apos PRODUCT_SELECTED=CARTAO (P8). */
    @AuraEnabled
    public static List<BuscaClienteDTOs.CardViaDTO> fetchVias(String normalizedDoc) {
        String doc = DocumentValidator.normalizeDoc(normalizedDoc);
        if (String.isBlank(doc)) {
            throw new AuraHandledException('Informe o documento para consultar vias.');
        }
        CardService.CardResult result = CardService.fetchVias(doc);
        if (result.fault != null && result.vias.isEmpty()) {
            throw new AuraHandledException(result.fault.message);
        }
        return result.vias;
    }

    /** Cotas de consorcio, lazy apos PRODUCT_SELECTED=CONSORCIO (P8). */
    @AuraEnabled
    public static List<BuscaClienteDTOs.ConsorcioCotaDTO> fetchCotas(String normalizedDoc) {
        String doc = DocumentValidator.normalizeDoc(normalizedDoc);
        if (String.isBlank(doc)) {
            throw new AuraHandledException('Informe o documento para consultar cotas.');
        }
        ConsorcioService.ConsorcioResult result = ConsorcioService.fetchCotas(doc);
        if (result.fault != null && result.cotas.isEmpty()) {
            throw new AuraHandledException(result.fault.message);
        }
        return result.cotas;
    }

    /** Posicoes de investimento, lazy apos PRODUCT_SELECTED=INVESTIMENTOS (P8). */
    @AuraEnabled
    public static List<BuscaClienteDTOs.InvestimentoPosicaoDTO> fetchPosicoes(String normalizedDoc) {
        String doc = DocumentValidator.normalizeDoc(normalizedDoc);
        if (String.isBlank(doc)) {
            throw new AuraHandledException('Informe o documento para consultar posicoes.');
        }
        InvestimentoService.InvestimentoResult result = InvestimentoService.fetchPosicoes(doc);
        if (result.fault != null && result.posicoes.isEmpty()) {
            throw new AuraHandledException(result.fault.message);
        }
        return result.posicoes;
    }

    /** Abordar venda: registra em abordagem e libera o hub (Cen 14). */
    @AuraEnabled
    public static void approachNbo(String externalOfferId) {
        if (String.isBlank(externalOfferId)) {
            throw new AuraHandledException('Oferta nao informada.');
        }
        NboInteractionService.approach(new List<String>{ externalOfferId });
    }

    /** Dispensar: registra encerramento e libera o hub (Cen 15). */
    @AuraEnabled
    public static void dismissNbo(String externalOfferId) {
        if (String.isBlank(externalOfferId)) {
            throw new AuraHandledException('Oferta nao informada.');
        }
        NboInteractionService.dismiss(new List<String>{ externalOfferId });
    }

    /** Fixa o contexto de interacao apos a selecao (P7/P8, RN-09). */
    @AuraEnabled
    public static BuscaClienteDTOs.InteractionContextDTO fixInteractionContext(
        String normalizedDoc, String productType, String itemExternalId
    ) {
        return InteractionContextService.build(
            DocumentValidator.normalizeDoc(normalizedDoc), productType, itemExternalId);
    }

    /** Catalogo configuravel para o hub (PT). Cacheable: raramente muda. */
    @AuraEnabled(cacheable=true)
    public static List<BuscaClienteDTOs.CatalogItemDTO> getCatalog() {
        return ProductCatalogService.getCatalog();
    }

    private static void enqueueUpsert(BuscaClienteDTOs.CustomerSearchResultDTO dto) {
        // Mock: nao persiste fixture como dado real.
        if (BuscaClienteMock.isEnabled()) {
            return;
        }
        if (dto == null || dto.demographic == null) {
            return;
        }
        // Fire-and-forget por RN-10: o guard de limite e a unica condicao de
        // enfileiramento. Sem try/catch propositalmente: falha aqui deve
        // aparecer nos testes, nunca silenciar em producao (a busca segue).
        if (Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs()) {
            return;
        }
        System.enqueueJob(new CustomerUpsertQueueable(JSON.serialize(dto)));
    }
}
