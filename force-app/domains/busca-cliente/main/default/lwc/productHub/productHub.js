import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CUSTOMER_CHANNEL from '@salesforce/messageChannel/CustomerInteractionChannel__c';

/**
 * Hub de produtos, dono de P4/P7. Renderiza um cartão por tipo do catálogo
 * com contagem agregada e estado selecionado reversível. Publica
 * PRODUCT_SELECTED no LMS; não abre modal nem fixa contexto.
 */
export default class ProductHub extends LightningElement {
    @api produtos = [];

    @wire(MessageContext)
    messageContext;

    get temProdutos() {
        return (this.produtos?.length ?? 0) > 0;
    }

    aoSelecionar(event) {
        const tipo = event.currentTarget.dataset.tipo;
        publish(this.messageContext, CUSTOMER_CHANNEL, {
            type: 'PRODUCT_SELECTED',
            documentNormalized: '',
            modo: '',
            productType: tipo,
            itemId: '',
            payload: ''
        });
    }
}
