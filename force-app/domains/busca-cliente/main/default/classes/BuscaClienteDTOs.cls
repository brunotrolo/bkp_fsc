/**
 * @description DTOs tipados da jornada busca-cliente/001. Contrato estavel entre
 * Apex e LWC: nenhum FinServ__* no payload, Last4 exposto apenas mascarado.
 * Usado por todos os services e pelo CustomerSearchController.
 */
public with sharing class BuscaClienteDTOs {

    /** Falha parcial de uma fonte externa: nunca lanca excecao para o LWC. */
    public class ApiFaultDTO {
        @AuraEnabled public String source;
        @AuraEnabled public String code;
        @AuraEnabled public String message;
        public ApiFaultDTO() {}
        public ApiFaultDTO(String source, String code, String message) {
            this.source = source;
            this.code = code;
            this.message = message;
        }
    }

    /** Dados demograficos para a faixa de identificacao (P3). */
    public class DemographicDTO {
        @AuraEnabled public String nome;
        @AuraEnabled public String tipoPessoa;
        @AuraEnabled public String documentoFormatado;
        @AuraEnabled public String segmento;
        @AuraEnabled public String email;
        @AuraEnabled public String telefone;
        @AuraEnabled public String celular;
        @AuraEnabled public String nascimento;
        @AuraEnabled public String endereco;
        @AuraEnabled public String cep;
        @AuraEnabled public String renda;
        @AuraEnabled public String score;
        @AuraEnabled public String agencia;
        @AuraEnabled public String conta;
        @AuraEnabled public String tempoRelacionamento;
        @AuraEnabled public String statusCadastro;
        public DemographicDTO() {}
    }

    /** Resumo quantitativo por tipo de produto para o hub (P4). */
    public class ProductSummaryDTO {
        @AuraEnabled public String productType;
        @AuraEnabled public String label;
        @AuraEnabled public Integer quantidade;
        @AuraEnabled public String resumo;
        @AuraEnabled public String iconName;
        @AuraEnabled public Boolean exigeSubselecao;
        @AuraEnabled public Boolean holdingInformativo;
        public ProductSummaryDTO() {}
    }

    /** Vinculo Holding de visibilidade informativa (P5, RN-06). */
    public class HoldingDTO {
        @AuraEnabled public String nome;
        @AuraEnabled public String detalhe;
        @AuraEnabled public String icone;
        public HoldingDTO() {}
    }

    /** Oferta NBO com narrativa completa para o banner (P6). */
    public class NboOfferDTO {
        @AuraEnabled public String externalOfferId;
        @AuraEnabled public String productType;
        @AuraEnabled public String titulo;
        @AuraEnabled public String narrativa;
        @AuraEnabled public String beneficio;
        @AuraEnabled public List<String> beneficios;
        @AuraEnabled public List<String> bandeiras;
        @AuraEnabled public String limites;
        @AuraEnabled public String anuidade;
        @AuraEnabled public Boolean isPrimary;
        @AuraEnabled public String stage;
        public NboOfferDTO() {
            this.beneficios = new List<String>();
            this.bandeiras = new List<String>();
        }
    }

    /** Via ou plastico de cartao para o modal (P8). */
    public class CardViaDTO {
        @AuraEnabled public String externalContractId;
        @AuraEnabled public String brand;
        @AuraEnabled public String category;
        @AuraEnabled public String last4Masked;
        @AuraEnabled public String holderName;
        @AuraEnabled public Boolean isTitular;
        @AuraEnabled public String limite;
        @AuraEnabled public String anuidade;
        @AuraEnabled public String status;
        public CardViaDTO() {}
    }

    /** Cota de consorcio para o modal (P8). */
    public class ConsorcioCotaDTO {
        @AuraEnabled public String externalContractId;
        @AuraEnabled public String tipo;
        @AuraEnabled public String grupo;
        @AuraEnabled public String cota;
        @AuraEnabled public String valor;
        @AuraEnabled public String contemplacao;
        @AuraEnabled public String parcela;
        @AuraEnabled public String status;
        public ConsorcioCotaDTO() {}
    }

    /** Posicao de investimento para o modal (P8). */
    public class InvestimentoPosicaoDTO {
        @AuraEnabled public String externalContractId;
        @AuraEnabled public String classe;
        @AuraEnabled public String produto;
        @AuraEnabled public String valor;
        @AuraEnabled public String rentabilidade;
        @AuraEnabled public String vencimento;
        @AuraEnabled public String risco;
        public InvestimentoPosicaoDTO() {}
    }

    /** Resultado agregado da identificacao (P2, Cen 21/22). */
    public class CustomerSearchResultDTO {
        @AuraEnabled public String documentNormalized;
        @AuraEnabled public String documentMasked;
        @AuraEnabled public String docType;
        @AuraEnabled public DemographicDTO demographic;
        @AuraEnabled public List<ProductSummaryDTO> portoBankWallet;
        @AuraEnabled public List<HoldingDTO> holdingWallet;
        @AuraEnabled public List<NboOfferDTO> nboOffers;
        @AuraEnabled public List<ApiFaultDTO> partialFaults;
        public CustomerSearchResultDTO() {
            this.portoBankWallet = new List<ProductSummaryDTO>();
            this.holdingWallet = new List<HoldingDTO>();
            this.nboOffers = new List<NboOfferDTO>();
            this.partialFaults = new List<ApiFaultDTO>();
        }
    }

    /** Contexto de interacao fixado, saida formal da jornada (RN-09). */
    public class InteractionContextDTO {
        @AuraEnabled public String accountId;
        @AuraEnabled public String contactId;
        @AuraEnabled public String productType;
        @AuraEnabled public String assetId;
        @AuraEnabled public String itemAssetId;
        @AuraEnabled public String opportunityId;
        @AuraEnabled public String resumo;
        public InteractionContextDTO() {}
    }

    /** Item do catalogo configuravel (PT). */
    public class CatalogItemDTO {
        @AuraEnabled public String productType;
        @AuraEnabled public String label;
        @AuraEnabled public String iconName;
        @AuraEnabled public Boolean requiresViaSelection;
        @AuraEnabled public Decimal displayOrder;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public Boolean holdingInformative;
        public CatalogItemDTO() {}
    }
}
