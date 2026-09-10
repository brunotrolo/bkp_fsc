import { LightningElement, wire } from 'lwc';
import { publish, subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import CUSTOMER_CHANNEL from '@salesforce/messageChannel/CustomerInteractionChannel__c';
import identifyCadastro from '@salesforce/apex/CustomerSearchController.identifyCadastro';
import fetchNboOffers from '@salesforce/apex/CustomerSearchController.fetchNboOffers';
import fetchVias from '@salesforce/apex/CustomerSearchController.fetchVias';
import fetchCotas from '@salesforce/apex/CustomerSearchController.fetchCotas';
import fetchPosicoes from '@salesforce/apex/CustomerSearchController.fetchPosicoes';
import approachNbo from '@salesforce/apex/CustomerSearchController.approachNbo';
import dismissNbo from '@salesforce/apex/CustomerSearchController.dismissNbo';
import fixInteractionContext from '@salesforce/apex/CustomerSearchController.fixInteractionContext';
import getCatalog from '@salesforce/apex/CustomerSearchController.getCatalog';
import CardDrawer from 'c/cardDrawer';
import ConsorcioDrawer from 'c/consorcioDrawer';
import InvestimentoDrawer from 'c/investimentoDrawer';

/**
 * Shell orquestrador, dono APENAS do estado da jornada: busca → carregando →
 * resultado/erro + gate NBO + contexto fixado. Assina CUSTOMER_SEARCH_TRIGGERED
 * e PRODUCT_SELECTED no LMS; publica CUSTOMER_IDENTIFIED, NBO_*, CARD/COTA/
 * INVESTIMENTO_SELECTED e INTERACTION_CONTEXT_FIXED. Chamadas Apex paralelas
 * via Promise.allSettled com skeletons independentes por área (Cen 21).
 */
export default class CustomerSearchShell extends LightningElement {
    estado = 'busca';
    cliente = null;
    ofertaAtiva = null;
    ofertaDispensada = false;
    produtoSelecionadoTipo = null;
    contextoFixado = null;
    ultimoNormalizado = null;
    ultimoModo = 'PF';

    carregandoCadastro = false;
    carregandoHub = false;
    carregandoNbo = false;
    avisoNboParcial = false;
    catalogo = [];
    toastVisivel = false;
    toastTitulo = '';
    toastMensagem = '';
    _toastTimer = null;

    subscription = null;

    @wire(MessageContext)
    messageContext;

    @wire(getCatalog)
    wiredCatalog({ data }) {
        if (data) {
            this.catalogo = data;
            if (this.cliente) {
                this.remontarProdutos();
            }
        }
    }

    connectedCallback() {
        this.subscription = subscribe(this.messageContext, CUSTOMER_CHANNEL, (message) =>
            this.aoMensagem(message)
        );
    }

    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
        this.esconderToast();
    }

    mostrarToast(titulo, mensagem) {
        // Toast próprio (não o padrão da plataforma, cujo auto-dismiss é
        // ignorado): sempre aparece e sempre fecha em 5s.
        this.esconderToast();
        this.toastTitulo = titulo;
        this.toastMensagem = mensagem;
        this.toastVisivel = true;
        this._toastTimer = setTimeout(() => {
            this.toastVisivel = false;
            this._toastTimer = null;
        }, 5000);
    }

    esconderToast() {
        if (this._toastTimer) {
            clearTimeout(this._toastTimer);
            this._toastTimer = null;
        }
        this.toastVisivel = false;
    }

    fecharToast() {
        this.esconderToast();
    }

    aoMensagem(message) {
        if (!message || !message.type) {
            return;
        }
        if (message.type === 'CUSTOMER_SEARCH_TRIGGERED') {
            this.ultimoModo = message.modo || 'PF';
            this._executarBusca(message.documentNormalized, this.ultimoModo);
        } else if (message.type === 'PRODUCT_SELECTED') {
            this.aoProdutoSelecionado(message.productType);
        }
    }

    get mostrarCarregamento() {
        return this.estado === 'carregando';
    }

    get mostrarNaoEncontrado() {
        return this.estado === 'nao-encontrado';
    }

    get mostrarErroTotal() {
        return this.estado === 'erro-total';
    }

    get mostrarResultado() {
        return this.estado === 'resultado';
    }

    get temHolding() {
        return (this.cliente?.holding?.length ?? 0) > 0;
    }

    get iconeTipoPessoa() {
        if (this.cliente?.tipoPessoa === 'Pessoa Jurídica') {
            return 'standard:account';
        }
        return 'standard:contact';
    }

    get temOfertaIdentificada() {
        return this.ofertaAtiva !== null && this.ofertaAtiva.estado === 'identificada';
    }

    get mostrarOfertaEmAbordagem() {
        return this.ofertaAtiva !== null && this.ofertaAtiva.estado === 'em abordagem';
    }

    get mostrarOfertaDispensada() {
        return this.ofertaDispensada && !this.mostrarOfertaEmAbordagem && this.ofertaAtiva === null;
    }

    get mostrarAvisoOfertasIndisponiveis() {
        return this.avisoNboParcial && !this.temOfertaIdentificada && !this.mostrarOfertaEmAbordagem;
    }

    get semOferta() {
        // Sem oferta = NBO já resolvido (não mais carregando) e sem oferta ativa
        // nem dispensa. ANTES lia cliente.ofertas, que o DTO nunca preenche
        // (NBO vem por chamada separada) — por isso o gate nunca engatava.
        return (
            this.mostrarResultado &&
            !this.carregandoNbo &&
            this.ofertaAtiva === null &&
            !this.ofertaDispensada
        );
    }

    get ofertaDecidida() {
        return this.mostrarOfertaEmAbordagem || this.ofertaDispensada || this.semOferta;
    }

    get mostrarGateProdutos() {
        return this.mostrarResultado && this.temOfertaIdentificada && !this.ofertaDecidida;
    }

    get mostrarHub() {
        return this.mostrarResultado && (!this.temOfertaIdentificada || this.ofertaDecidida);
    }

    publicar(type, extra) {
        publish(this.messageContext, CUSTOMER_CHANNEL, {
            type,
            documentNormalized: this.ultimoNormalizado,
            modo: this.ultimoModo,
            productType: '',
            itemId: '',
            payload: '',
            ...(extra ?? {})
        });
    }

    aoTentarNovamente() {
        if (this.ultimoNormalizado) {
            this._executarBusca(this.ultimoNormalizado, this.ultimoModo);
        }
    }

    aoLimpar() {
        this.estado = 'busca';
        this.cliente = null;
        this.ofertaAtiva = null;
        this.ofertaDispensada = false;
        this.produtoSelecionadoTipo = null;
        this.contextoFixado = null;
        this.ultimoNormalizado = null;
        this.avisoNboParcial = false;
        this.esconderToast();
        this.template.querySelector('c-customer-search-bar')?.limpar();
    }

    async _executarBusca(normalizado, modo) {
        if (!normalizado) {
            return;
        }
        this.ultimoNormalizado = normalizado;
        this.estado = 'carregando';
        this.cliente = null;
        this.ofertaAtiva = null;
        this.ofertaDispensada = false;
        this.produtoSelecionadoTipo = null;
        this.contextoFixado = null;
        this.avisoNboParcial = false;
        this.carregandoCadastro = true;
        this.carregandoHub = true;
        this.carregandoNbo = true;

        const [cadastro, nbo] = await Promise.allSettled([
            identifyCadastro({ normalizedDoc: normalizado, modo }),
            fetchNboOffers({ normalizedDoc: normalizado })
        ]);

        if (cadastro.status === 'rejected') {
            this.carregandoCadastro = false;
            this.carregandoHub = false;
            this.carregandoNbo = false;
            this.estado = 'erro-total';
            this.mostrarToast(
                'Fontes indisponíveis',
                'As fontes corporativas estão temporariamente indisponíveis. Tente novamente em instantes.'
            );
            return;
        }

        const dto = cadastro.value;
        this.carregandoCadastro = false;
        if (!dto || !dto.demographic) {
            this.carregandoHub = false;
            this.carregandoNbo = false;
            this.estado = 'nao-encontrado';
            this.mostrarToast(
                'Cliente não localizado',
                'Nenhum cadastro para este documento. Confira os dígitos e tente de novo.'
            );
            return;
        }

        this.cliente = this.mapearCliente(dto);
        this.carregandoHub = false;
        this.estado = 'resultado';
        this.publicar('CUSTOMER_IDENTIFIED');

        this.carregandoNbo = false;
        if (nbo.status === 'fulfilled' && Array.isArray(nbo.value) && nbo.value.length > 0) {
            const primeira = nbo.value[0];
            this.ofertaAtiva = {
                id: primeira.externalOfferId,
                produto: primeira.productType,
                titulo: primeira.titulo,
                narrativa: primeira.narrativa,
                beneficio: primeira.beneficio,
                beneficios: primeira.beneficios ?? [],
                bandeiras: (primeira.bandeiras ?? []).map((b) => ({ nome: b, logo: 'utility:card_details' })),
                limites: primeira.limites,
                anuidade: primeira.anuidade,
                estado: 'identificada'
            };
            this.publicar('NBO_OFFERS_AVAILABLE', { payload: String(nbo.value.length) });
        } else {
            this.avisoNboParcial = nbo.status === 'rejected';
            this.publicar('NBO_EMPTY');
        }
    }

    mapearCliente(dto) {
        const d = dto.demographic ?? {};
        const porTipo = new Map((dto.portoBankWallet ?? []).map((p) => [p.productType, p]));
        const produtos = (this.catalogo.length > 0 ? this.catalogo : (dto.portoBankWallet ?? []).map((p) => ({
            productType: p.productType,
            label: p.label,
            iconName: p.iconName,
            requiresViaSelection: p.exigeSubselecao,
            holdingInformative: false
        })))
            .filter((c) => !c.holdingInformative && porTipo.has(c.productType))
            .map((c) => {
                const w = porTipo.get(c.productType);
                return {
                    tipo: c.productType,
                    nome: c.label || w.label,
                    resumo: w.resumo || `${w.quantidade ?? ''}`.trim(),
                    icone: c.iconName || w.iconName || 'standard:account',
                    exigeSubselecao: c.requiresViaSelection ?? w.exigeSubselecao ?? false,
                    selecionado: false,
                    selo: 'Disponível',
                    classeCartao: 'c-product-card'
                };
            });
        return {
            nome: d.nome,
            tipoPessoa: d.tipoPessoa,
            documentoFormatado: d.documentoFormatado,
            segmento: d.segmento,
            dataNascimento: d.nascimento,
            email: d.email,
            telefone: d.telefone,
            celular: d.celular,
            endereco: d.endereco,
            cep: d.cep,
            agencia: d.agencia,
            conta: d.conta,
            renda: d.renda,
            tempoRelacionamento: d.tempoRelacionamento,
            statusCadastro: d.statusCadastro,
            score: d.score,
            produtos,
            holding: (dto.holdingWallet ?? []).map((h) => ({ nome: h.nome, detalhe: h.detalhe, icone: h.icone || 'utility:co_insurance' })),
            ofertas: dto.nboOffers ?? []
        };
    }

    remontarProdutos() {
        if (!this.cliente) {
            return;
        }
        const atual = this.cliente.produtos.map((p) => p.tipo);
        const porTipo = new Map(atual.map((t, i) => [t, this.cliente.produtos[i]]));
        this.cliente = {
            ...this.cliente,
            produtos: this.catalogo
                .filter((c) => !c.holdingInformative && porTipo.has(c.productType))
                .map((c) => ({ ...porTipo.get(c.productType), nome: c.label || porTipo.get(c.productType).nome }))
        };
    }

    aoAbordarOferta() {
        if (!this.ofertaAtiva) {
            return;
        }
        const id = this.ofertaAtiva.id;
        approachNbo({ externalOfferId: id }).catch(() => {});
        try {
            sessionStorage.removeItem(`nboDismissed:${this.ultimoNormalizado}`);
        } catch {
            // Armazenamento indisponível: segue sem supressão de sessão.
        }
        this.ofertaAtiva = { ...this.ofertaAtiva, estado: 'em abordagem' };
        this.publicar('NBO_APPROACHED', { payload: id });
    }

    aoDispensarOferta() {
        const id = this.ofertaAtiva?.id;
        if (id) {
            dismissNbo({ externalOfferId: id }).catch(() => {});
        }
        try {
            sessionStorage.setItem(`nboDismissed:${this.ultimoNormalizado}`, 'true');
        } catch {
            // Armazenamento indisponível: segue sem supressão de sessão.
        }
        this.ofertaAtiva = null;
        this.ofertaDispensada = true;
        this.publicar('NBO_DISMISSED', { payload: id ?? '' });
    }

    async aoProdutoSelecionado(tipo) {
        if (!this.cliente || !tipo) {
            return;
        }
        const produto = this.cliente.produtos.find((p) => p.tipo === tipo);
        if (!produto) {
            return;
        }
        this._marcarSelecionado(tipo);
        // Sem republicar PRODUCT_SELECTED: o hub já publicou e este shell
        // consome esse tipo — republicar aqui gerava recursão infinita
        // (cada eco reentrava aoProdutoSelecionado, abrindo N modais).
        if (!produto.exigeSubselecao) {
            await this.fixarContexto(produto.nome, null);
            return;
        }
        if (tipo === 'CARTAO') {
            const vias = await fetchVias({ normalizedDoc: this.ultimoNormalizado }).catch(() => []);
            let via = null;
            try {
                via = await CardDrawer.open({ label: `Vias de cartão — ${this.cliente.nome}`, size: 'medium', vias });
            } catch {
                via = null;
            }
            if (via) {
                this.publicar('CARD_SELECTED', { productType: tipo, itemId: via.externalContractId ?? '' });
                await this.fixarContexto(produto.nome, via.externalContractId ?? null, { via });
            } else {
                this._marcarSelecionado(null);
            }
            return;
        }
        if (tipo === 'CONSORCIO') {
            const cotas = await fetchCotas({ normalizedDoc: this.ultimoNormalizado }).catch(() => []);
            let cota = null;
            try {
                cota = await ConsorcioDrawer.open({ label: `Cotas de consórcio — ${this.cliente.nome}`, size: 'medium', cotas });
            } catch {
                cota = null;
            }
            if (cota) {
                this.publicar('COTA_SELECTED', { productType: tipo, itemId: cota.externalContractId ?? '' });
                await this.fixarContexto(produto.nome, cota.externalContractId ?? null, { cota });
            } else {
                this._marcarSelecionado(null);
            }
            return;
        }
        if (tipo === 'INVESTIMENTOS') {
            const posicoes = await fetchPosicoes({ normalizedDoc: this.ultimoNormalizado }).catch(() => []);
            let investimento = null;
            try {
                investimento = await InvestimentoDrawer.open({
                    label: `Investimentos — ${this.cliente.nome}`,
                    size: 'medium',
                    investimentos: posicoes
                });
            } catch {
                investimento = null;
            }
            if (investimento) {
                this.publicar('INVESTIMENTO_SELECTED', { productType: tipo, itemId: investimento.externalContractId ?? '' });
                await this.fixarContexto(produto.nome, investimento.externalContractId ?? null, { investimento });
            } else {
                this._marcarSelecionado(null);
            }
            return;
        }
        await this.fixarContexto(produto.nome, null);
    }

    async fixarContexto(produtoNome, itemExternalId, detalhe) {
        let resumo = `${this.cliente.nome} + ${produtoNome}`;
        try {
            const ctx = await fixInteractionContext({
                normalizedDoc: this.ultimoNormalizado,
                productType: this.produtoSelecionadoTipo,
                itemExternalId
            });
            if (ctx?.resumo) {
                resumo = ctx.resumo;
            }
        } catch {
            // Contexto ainda não consolidado: fixa com o resumo local.
        }
        this.contextoFixado = { produtoNome, resumo, ...(detalhe ?? {}) };
        this.publicar('INTERACTION_CONTEXT_FIXED', {
            productType: this.produtoSelecionadoTipo ?? '',
            itemId: itemExternalId ?? '',
            payload: resumo
        });
    }

    _marcarSelecionado(tipo) {
        this.produtoSelecionadoTipo = tipo;
        this.cliente = {
            ...this.cliente,
            produtos: this.cliente.produtos.map((p) => ({
                ...p,
                selecionado: p.tipo === tipo,
                selo: p.tipo === tipo ? 'Selecionado' : 'Disponível',
                classeCartao: p.tipo === tipo ? 'c-product-card c-product-card_selecionado' : 'c-product-card'
            }))
        };
        if (tipo === null) {
            this.contextoFixado = null;
        }
    }
}
