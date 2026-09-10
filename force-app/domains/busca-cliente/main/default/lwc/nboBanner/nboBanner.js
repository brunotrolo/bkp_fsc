import { LightningElement, api } from 'lwc';

/**
 * Banner NBO, dono de P6. Recebe a oferta via @api e emite
 * abordar/dispensar; o shell registra no servidor e publica no LMS.
 */
export default class NboBanner extends LightningElement {
    @api ofertaAtiva = null;
    @api mostrarOfertaEmAbordagem = false;
    @api mostrarOfertaDispensada = false;
    @api mostrarAvisoOfertasIndisponiveis = false;

    get temOfertaIdentificada() {
        return this.ofertaAtiva !== null && this.ofertaAtiva.estado === 'identificada';
    }

    aoAbordar() {
        this.dispatchEvent(new CustomEvent('abordar'));
    }

    aoDispensar() {
        this.dispatchEvent(new CustomEvent('dispensar'));
    }
}
