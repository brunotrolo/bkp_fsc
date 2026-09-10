Jornada Service Cloud Salesforce
https://share.gemini.google/maN502anA59D
Criado com 3.8 Flash 5 de setembro de 2026 às 17:27
Publicada em 6 de setembro de 2026 às 23:13
Preciso de ajuda para descrever uma jornada de desenvolvimento no meu novo sistema Salesforce Service Cloud



Se eu narrar o problema atual, jornada esperada e demais informações, voce tem como ir fazendo perguntas e ao final aprensentar um documento de referência?



Como podemos garantir que vc não esqueca ou desconsidere o que te informei?

Podemos conduzir exatamente dessa forma: você traz os relatos em blocos, eu faço perguntas direcionadas de arquitetura, processos e regras de negócio e, ao final, consolido tudo em um documento de especificação funcional e técnica pronto para o time de desenvolvimento.

Para garantir que nenhum detalhe seja perdido, esquecido ou desconsiderado ao longo da conversa, adotaremos este método de trabalho:

Quadro de Memória Progressivo: A cada nova rodada de perguntas, manterei uma seção compacta de síntese registrando os pontos já acordados (personas, regras, canais, integrações e objetos envolvidos). Se algo parecer impreciso, você corrige imediatamente.

Tópicos Modulares: Dividiremos a narrativa em partes lógicas (ex.: Cenário Atual e Dores, Jornada Desejada do Operador/Cliente, Automações e SLAs, Integrações e Dados), evitando ruído em mensagens excessivamente longas.

Documento Final Estruturado: O entregável final será gerado com base estrita no quadro consolidado, mapeando:

Histórias de usuário e critérios de aceite.

Modelo de dados e objetos (padrão como Case, Contact, Account ou customizados).

Automações de Service Cloud (Omni-Channel, Entitlements/Milestones, Flows, Quick Actions, Console).

Pontos de integração e requisitos de governança.

Pode começar narrando o problema atual e a dor central que motiva a criação ou reformulação dessa jornada no Service Cloud.

Falo tudo de uma vez em um audio de alguns minitos ou falo parte por parte?

Mande tudo de uma vez.

Despeje todo o contexto sem se preocupar com ordem, formatação ou termos técnicos perfeitos. Fale livremente sobre:

As dores do processo atual.

Como você imagina o fluxo ideal.

Quais áreas, sistemas ou regras participam.

Vou processar o relato completo, extrair a espinha dorsal da arquitetura, montar a primeira versão do nosso Quadro de Memória e devolver perguntas cirúrgicas apenas sobre as lacunas ou pontos que precisarem de aprofundamento. Pode enviar.

Hoje eu tenho um sistema de atendimento a produtos financeiros na Porto Bank. É, ele é um sistema que foi construído tem cerca de cinco ou seis anos e ele não foi construído sob a ótica de um consultor Salesforce ou algum especialista em atendimento. Ele foi construído sob a ótica de uma área de negócio, cujas pessoas que declaravam, a jornada, as jornadas tinham baixíssimo conhecimento de como se desenvolve uma jornada no sistema, como que se desenvolve uma jornada dentro do Salesforce. Então, existem muitos débitos técnicos e problemas de arquitetura de solução, desde a arquitetura funcional até a arquitetura técnica. É, se se esse cenário tiver claro para você, eu posso te mandar outro áudio. A, a ideia a partir de agora é a gente pegar o que funcionou e o que precisa respeitar a arquitetura desse sistema, mas reconstruir para um sistema novo, né? A gente vai sair do modelo de Salesforce Service Cloud para Salesforce Financial Service Cloud. Mas as APIs serão as mesmas. É, o que a gente vai ter que redesenhar é o fluxo de integrações para otimização e melhor sustentação do sistema. Hoje o sistema ele tem muitas, muitos débitos técnicos e é difícil de dar sustentação porque muitas das soluções foram criadas através de monolitos. Então, às vezes, para você fazer um pequeno ajuste, você acaba mexendo em coisas é, de grande impacto dentro do sistema. A primeira jornada que a gente vai falar é sobre a jornada de busca de cliente. Se você tiver entendido todo o cenário atual, me informa que eu vou declarar como que é, como que é hoje, quais são os problemas e como que eu penso em a gente resolver. E aí você coloca as suas considerações e até a gente chegar numa solução é, não ideal, mas uma referência de do que pode se tornar ideal.

Cenário perfeitamente compreendido.

Para registrar no nosso método de trabalho, aqui está o resumo da nossa base de partida:

📌 Quadro de Memória Progressivo (Snapshot Inicial)
Contexto & Domínio: Atendimento a produtos financeiros na Porto Bank.

Origem vs. Destino: Migração/Reconstrução saindo de uma implementação legada de Service Cloud para o modelo nativo de Financial Services Cloud (FSC).

Premissa de Integração: As APIs legadas existentes permanecem as mesmas, mas os fluxos de integração e consumo precisam ser totalmente redesenhados para performance, sustentabilidade e desacoplamento.

Principal Dor Atual: Arquitetura monolítica, alto acoplamento, débitos técnicos acumulados e falta de aderência às boas práticas de consultoria/arquitetura Salesforce, tornando qualquer manutenção cara e arriscada.

Módulo em Foco (Etapa 1): Jornada de Busca e Identificação de Cliente.

Pode mandar o próximo áudio/texto detalhando:

Como a busca de cliente funciona hoje na prática.

Quais são as principais dores/gargalos técnicos e operacionais desse fluxo atual.

A ideia inicial de como você pensa em resolver essa etapa.

Estou pronto, pode enviar!

Hoje a busca de cliente é uma série de requisições em APIs. É, a primeira requisição é quando a gente faz uma chave de busca, a gente tem duas principais chaves de busca. Uma é o CPF para cenário de atendimento a pessoa física e CNPJ para cenários de atendimento pessoa jurídica. No caso de pessoa jurídica, a gente consegue colocar tanto o formato convencional de números como a gente já consegue colocar é, CNPJs alfanuméricos, né? É uma nova, é uma nova exigência do Bacen. Mas basicamente a gente coloca a chave de CPF ou CNPJ, é um ou outro. E aí ele faz uma primeira busca, ele identifica numa API de NBO, né, de Next Best Offer, se o cliente é elegível para adquirir produtos que ele não possui. Então, às vezes ele não possui cartão de crédito, não possui consórcio, não possui conta digital. Então a gente faz uma busca nessa base de NBO. A próxima consulta é uma API de dados cadastrais. Então a gente, com esse CPF, ele retorna quais são, quais são os dados daquele cliente, então nome completo, é, endereço, data de nascimento, no caso de pessoa física, né? E coisa do tipo. E quais são todos os produtos que ele possui na empresa, não só dentro do banco, mas também dentro da empresa. É, então se ele tem conta digital, consórcio, cartão de crédito, produtos de investimento e também produtos da própria Rod, como seguro residencial, seguro é, é automóvel, plano de saúde, plano odontológico, é, entre outros serviços dentro da, da Porto Seguro, né? Não só da Porto Bank. O nosso projeto, ele vai ficar restrito a Porto Bank. Então, é, ele faz essa busca de dados cadastrais e retorna ali todos os contratos que aquele cliente possui dentro da empresa como um todo. E aí apresenta um modal de seleção de produtos. Então, dentre todos os produtos que a gente atende dentro do Salesforce, ele apresenta ali quais ele possui, né? E aí apresenta um modal de seleção do produto. É, na sequência, você seleciona, né, qual é o produto que você deseja. E, no caso de cartão de crédito, ele, quando você seleciona o cartão de crédito, ele faz uma, uma busca, é, aí na, nas bases do próprio cartão de crédito e pede pro operador selecionar de qual cartão. Porque muitas das vezes, o cliente, ele tem mais de um cartão ou tem cartões que estão com status cancelado. E às vezes, é, é necessário fazer o atendimento de cartões cancelados ou cartões ativos. Então, selecionar qual é o cartão é importante para, é, buscar os dados

Excelente relato. Ficou muito nítido o encadeamento atual e os pontos críticos de acoplamento e latência na operação.

Antes de propor o desenho de referência para o Financial Services Cloud (FSC), fiz uma síntese do que você descreveu e levantei algumas perguntas pontuais para calibrar a solução.

📌 Quadro de Memória Progressivo (Atualizado)
Contexto: Porto Bank (migração de Service Cloud para FSC).

Entradas de Busca: CPF (PF) ou CNPJ (PJ - suportando formato alfanumérico).

Cadeia Atual de Requisições:

API de NBO (Next Best Offer): Verifica propensão/elegibilidade a novos produtos.

API Cadastral Corporativa: Retorna demografia (nome, endereço, nascimento/fundação) + visão 360° corporativa (Porto Seguro/Holding + Porto Bank).

Seleção de Produto (Modal): Operador escolhe o produto de escopo do atendimento dentro da fatia Porto Bank (Conta Digital, Consórcio, Cartão, Investimentos).

Sub-seleção por Produto (ex.: Cartão de Crédito): Consulta específica no processador/base de cartões para listar plásticos ativos e cancelados, exigindo escolha manual do cartão em atendimento.

Escopo: O atendimento foca nos produtos Porto Bank, mantendo a visibilidade dos contratos da Holding.

🔍 Perguntas para Calibração de Arquitetura
Para desenharmos o fluxo moderno desacoplado no FSC:

Orquestração e Persistência no Salesforce:

Hoje o Salesforce grava/atualiza os registros de Account / Contact e Contratos localmente a cada busca, ou funciona apenas como um "visualizador" em memória que só persiste quando um Caso/Protocolo é de fato aberto?

No FSC, você planeja usar o modelo padrão de Person Account para PF, Business Account para PJ e Financial Account para os produtos bancários (cartões, contas, etc.)?

Gargalo da API de NBO:

A chamada de NBO precisa realmente acontecer antes ou junto da busca cadastral? (Faz sentido trazê-la de forma assíncrona enquanto o operador já visualiza os dados do cliente, ou ela afeta a decisão da seleção do produto?)

Contexto de Cartões (Cards):

Além de cartões cancelados vs. ativos, um cliente pode ter cartões adicionais (dependentes/portadores)? O operador precisa identificar de quem é a via logo nessa etapa?

Identificação e Validação Positiva (Segurança):

Antes de abrir a tela com dados sensíveis e contratos, existe alguma etapa de perguntas de segurança/autenticação cadastral (MFA, validação positiva por perguntas) ou isso ocorre depois da seleção do produto?

Assim que responder a esses pontos, avançamos para desenhar a solução de referência desacoplada dessa etapa!

Parece que meu áudio ficou cortado aqui. Deve ter um tempo limite. Então, eu vou só retomar o resumo de como que é essa busca de cliente. Aí você ajusta e concatena com o meu áudio anterior. Então, basicamente, a busca de clientes, ela é a partir de uma chave de CPF ou CNPJ. Ele faz uma consulta se tem um NBO, se tem algum produto elegível pra gente ofertar para vendas para esse cliente. Tendo ou não tendo, é apresentado eh uma lista de produtos financeiros que aquele cliente possui dentro da Porto Bank. Essa é o operador, ele seleciona o produto que motivou o cliente a entrar em contato com a operação. Existem produtos que têm uma segunda seleção. Tem produtos que não precisam. Então, por exemplo, o cartão, eh, quando você seleciona o cartão, você tem que, né, o produto cartão de crédito, você vai selecionar qual é o cartão eh, e o respectivo status que o cliente quer aquele atendimento. Então, tem um mostra o histórico de cartões de crédito que aquele cliente possui dentro da empresa. E tem produtos que uma só seleção do produto já encerra a jornada de busca de clientes, como no caso do consórcio, conta digital ou investimento. Aí, eh, a a jornada funcional, ela se se acaba nesse sentido. E por trás, aí existem triggers, né, gatilhos que atualizam eh, os dados dentro do sistema, como eh, conta, contato, asset e objetos customizados. Então, a jornada é assim.

Perfeito! Agora o fluxo de ponta a ponta da Jornada de Busca e Identificação ficou cristalino.

Aqui está o Quadro de Memória Atualizado, já consolidando a visão completa do que foi narrado:

📌 Quadro de Memória Progressivo (Consolidado - Etapa 1)
Entrada da Busca:

CPF (Pessoa Física) ou CNPJ convencional/alfanumérico (Pessoa Jurídica).

Fluxo da Requisição e Experiência do Operador:

Consulta NBO: Identifica se há ofertas de cross-sell/up-sell elegíveis para produtos que o cliente não tem.

Consulta Cadastral Corporativa: Traz dados demográficos e todos os contratos Porto Bank + ecossistema Holding.

Seleção Primária de Produto (Foco Porto Bank): O operador escolhe o produto motivador do contato (Cartão de Crédito, Consórcio, Conta Digital, Investimentos).

Seleção Secundária (Condicional):

Cartão de Crédito: Abre histórico/lista de plásticos (status ativo, cancelado, etc.) para o operador indicar qual cartão específico motivou a chamada.

Demais Produtos (Consórcio, Conta, Investimentos): A seleção primária já encerra a etapa de identificação.

Persistência / Backend Atual:

Triggers legadas e processos síncronos disparam atualizações em cadeia nos objetos (Account, Contact, Asset e custom objects), gerando alto acoplamento e lentidão antes mesmo do operador iniciar o atendimento real.

💡 Diagnóstico Preliminar dos Débitos Técnicos
Gargalo Síncrono em Triggers: Fazer upsert/save em massa de dados legados via triggers no momento exato em que o operador clica no modal prende a UI (tela travada) e consome limites transacionais (DML/SOQL) desnecessariamente.

NBO Bloqueante: A chamada de NBO não precisa concorrer ou bloquear a renderização dos contratos existentes; o operador quer atender o problema do cliente primeiro.

Asset vs. Financial Services Cloud Nativo: O modelo atual usa Asset e objetos customizados, enquanto o FSC foi desenhado especificamente para isso com FinancialAccount, FinancialAccountRole e Cards.

🚀 Proposta de Arquitetura de Referência no FSC
Como transformar esse monólito em uma arquitetura moderna, rápida e desacoplada:

Frontend / UX (LWC desacoplado):

Uma barra de busca unificada (CPF/CNPJ com máscara dinâmica).

Lazy Loading / Renderização Paralela: O LWC dispara a chamada cadastral/produtos e a chamada de NBO em paralelo (via Apex controller com Promises no JS). O operador já visualiza os produtos sem esperar a resposta do NBO.

Componente de Seleção de Contexto:

Produtos de seleção direta (Conta, Consórcio, Investimento).

Cards expansíveis ou acordeão para Cartões (exibindo os 4 últimos dígitos, bandeira, titular/adicional e status com badges visuais: Ativo em verde, Cancelado em cinza/vermelho).

Modelo de Dados Nativo do FSC:

PF / PJ: Person Account (PF) e Account Empresarial (PJ).

Contratos Financeiros: FinServ__FinancialAccount__c (para Conta Digital, Consórcio, Linhas de Crédito/Investimento).

Cartões de Crédito: FinServ__FinancialAccount__c (tipo Cartão de Crédito) associado a FinServ__Card__c (para representar os plásticos/vias físicas e virtuais, status e portadores).

Holding / Cross-sell: Podem ser mantidos apenas para visualização leve (ex.: via Data Cloud / External Object / LWC puro) sem inflar a base de dados do Salesforce com dados de seguros se o foco transacional for apenas o banco.

Orquestração Assíncrona & Desacoplamento:

Gravação Assíncrona (Queueable / Platform Events): A seleção do operador define o contexto da sessão (gera o Case/Protocolo). A sincronização cadastral pesada e a amarração de contratos secundários ocorrem em background (assíncrono), liberando a tela do operador instantaneamente.

Eliminação de lógica em Triggers de tela, transferindo orquestrações para um Domain Service (Service Layer / Enterprise Patterns no Apex).

❓ Próximos Passos & Perguntas para Fechamento da Etapa 1
Para avançarmos para a próxima jornada ou refinarmos esta:

Qual é a sua visão de solução? O que você e o time já pensavam em termos de simplificação para essa tela e para essas integrações?

Histórico e Dados da Holding: O operador do Porto Bank precisa apenas ver que o cliente tem seguro auto/residencial (para dar um bom dia contextualizado ou transferir com contexto), ou ele executa alguma ação nesses produtos?

Geração do Atendimento (Case): Quando o operador clica no produto final (ou no cartão selecionado), o sistema já cria o Case / Protocolo de atendimento automaticamente e abre o workspace do cliente no Console?

Antes que você apresente os próximos passos, então quais são os desafios? Essa jornada, ela não pode ser monolítica. Hoje ela é um monolito, é um único código que fica orquestrando todas essas informações. Eu preciso criar uma estratégia de microsserviços e microfront-ends, ou seja, se eu quiser ajustar a etapa de NBO, não necessariamente eu vou ajustar todas as outras. Se eu quiser adicionar um novo produto de seleção, por exemplo, um produto novo que a gente quer embarcar dentro de um sistema, eu não preciso ajustar nem as etapas anteriores e nem aquelas que não têm conexão com essa nova jornada que a gente está implementando. Então, essa é uma das dores, né? É trazer um conceito de microfront-ends e microsserviços e desacoplar, é, uma jornada num único, num único logical, num único, é, código, né? Ter um desacoplamento ali, é, que cada etapa tenha a sua solução, é, separada. Então, esse é um dos principais problemas que a gente tem hoje, né? É, tirar esse conceito de monolito que existe hoje. A outra é utilizar o máximo de artefatos padrões para a gente montar essa, essa jornada. E o que eu digo de padrão é o novo padrão, inclusive utilizando o Salesforce Financial Service Cloud como soluções de OmniStudio, que podem ser OmniScript, FlexCard, né? Mas também podemos utilizar LWC se for necessário, se for benéfico a gente manter a jornada dessa forma. Então, é, essas são as principais dores. E a outra é performance. Como é que a gente, é, constrói a jornada garantindo a melhor performance possível nessa busca inicial? Porque cada minuto, cada segundo, é, que o operador precisa clicar, fazer um clique a mais ou aguardar um determinada performance do sistema, é um custo operacional.

Essa colocação vai exatamente na raiz do problema: quebrar o monólito tanto na camada de apresentação (Microfrontends) quanto na orquestração de negócios (Microsserviços / Integrações desacopladas), alavancando a stack moderna do Financial Services Cloud (FSC) com OmniStudio e LWC.

Vamos atualizar o nosso quadro de referência com esses pilares inegociáveis e desenhar a arquitetura recomendada.

📌 Quadro de Memória Progressivo (Atualizado)
Diretriz Arquitetural Inegociável: Desacoplamento modular de ponta a ponta.

Microfrontends: Telas/etapas isoladas e independentes. Adicionar um produto novo ou mudar a lógica de NBO não pode impactar nem exigir refatoração/deploy do restante.

Microsserviços / Integrações Independentes: Cada domínio (NBO, Cadastro Geral, Cartões, Consórcio, etc.) deve ter seu próprio contrato de integração isolado, executando de forma não bloqueante.

Tecnologia & Adoção Nativa: Uso prioritário de ferramentas nativas do FSC/OmniStudio (OmniScripts, FlexCards, DataRaptors/Data Mappers, Integration Procedures - IPs) combinados com LWC quando houver ganho real de performance ou necessidade de customização avançada.

Meta Crítica de Performance & TMA: Eliminar tempo de espera/bloqueio de tela e cliques supérfluos para o operador.

🏛️ Desenho de Solução de Referência: Desacoplamento & Performance
1. Camada de Apresentação (Microfrontends com OmniStudio + LWC)
Em vez de um único LWC ou OmniScript gigante com dezenas de passos e condicionais monolíticas:

Shell Orquestrador Leve (Host Container): Um OmniScript pai mínimo ou um LWC Container (Workspace Shell) responsável apenas por coletar a chave (CPF/CNPJ) e publicar o evento de busca.

Módulos Microfrontends (Pluggáveis via Eventos - Lightning Message Service / PubSub):

MFE 1: Header de Busca & Demografia: Valida CPF/CNPJ (com máscara dinâmica e suporte a PJ alfanumérico) e dispara o contexto do cliente.

MFE 2: Hub de Produtos (Modular): Construído com FlexCards reutilizáveis. Cada tipo de produto (Cartão de Crédito, Consórcio, Conta Digital, etc.) é um FlexCard "filho" modular.

Vantagem da plugabilidade: Quer adicionar um produto novo (ex.: Financiamento ou Seguro Prestamista)? Basta criar um novo FlexCard e plugá-lo na lista/layout sem tocar nos cards de Cartão ou Consórcio.

MFE 3: NBO Widget Independente (Assíncrono): Um FlexCard isolado de ofertas. Ele se renderiza com um skeleton/spinner leve no canto da tela sem travar a renderização dos produtos que o cliente já tem.

MFE 4: Drawer / Sub-seletor de Cartões (Condicional): Um micro-componente acionado apenas quando o card de "Cartão de Crédito" é clicado, exibindo a lista de plásticos (ativos/cancelados) com visualização em lista/tabela compacta.

2. Camada de Microsserviços & Orquestração de Integrações
Para eliminar o monólito de backend em Apex:

Integration Procedures (IPs) Modulares e Independentes:

IP_Client_Demographics: Consulta dados cadastrais básicos.

IP_Client_Products_Summary: Retorna a lista agregada de contratos ativos na Porto Bank.

IP_Client_NBO: Consulta assíncrona da esteira de Next Best Offer.

IP_Cards_PlasticList: Consulta pontual disparada somente se o operador selecionar "Cartão de Crédito".

Execução em Paralelo & Não Bloqueante (Performance Extrema):

O OmniScript/Shell dispara a chamada cadastral e a chamada de NBO em chaves paralelas (non-blocking / chainOnStep ou Promises via LWC).

O operador já vê a lista de produtos na tela em milissegundos, sem esperar a resposta do motor de recomendação (NBO).

Caching Inteligente:

Uso de OmniStudio Cache (Session Cache / Org Cache via Platform Cache) para evitar que consultas repetidas de produtos ou dados estáticos de contratos batam no barramento/APIs legadas repetidamente durante a mesma sessão de atendimento.

3. Eliminação dos Gargalos de Persistência (Triggers)
Desacoplamento de Gravação: A consulta de busca não deve fazer DML/Upsert síncrono de dezenas de contratos em base de dados apenas para pesquisa.

Persistência On-Demand:

O registro de Case (Protocolo) é criado com o vínculo direto à Person Account ou Business Account e ao produto selecionado.

Se houver necessidade de sincronizar dados cadastrais alterados ou salvar o contrato específico, isso é despachado de forma desacoplada via Queueable Apex ou Platform Events, sem reter o encadeamento de tela do operador.

🧭 Pontos para Fecharmos este Módulo
Com essa arquitetura de referência para a Busca e Identificação:

Aderência: Essa divisão em OmniStudio (FlexCards para produtos e NBO) + IPs modulares paralelos atende bem ao modelo que você visualiza para a operação?

NBO na Jornada: O operador costuma ofertar o NBO antes de resolver o problema do cliente, ou o NBO fica visível como um badge/alerta para ser trabalhado no final do contato?

Próxima Etapa: Com a busca e seleção de produto resolvidas, qual é a próxima jornada crítica do atendimento que devemos mapear (ex.: Validação de Segurança/Positiva, Tela 360 do Produto Selecionado, ou Abertura de Solicitações/Serviços)?

Excelentes perguntas. É, a gente não sabe ainda como que vai construir o back-end disso, mas é certeza que a gente vai utilizar Apex e Apex Trigger para o back-end. Não vamos utilizar Integration Procedure. O front-end, aí é como eu comentei, a gente vai precisar tomar uma decisão em conjuntos do que que traz essas melhores soluções, seja utilizando o OmniStudio ou LWC. É, NBO na jornada? Sim. O operador sempre quando tem uma oferta de uma venda de um novo produto e ele entende que pode ofertar antes do início de uma jornada de atendimento, ele oferta primeira venda, é a oferta, né, a venda, a prospecção, a oportunidade, tudo que envolve venda antes do início da jornada de atendimento.

Entendido. Diretrizes de arquitetura de backend e regra de negócio registradas e consolidadas:

Backend Decidido: Apex puro e Apex Triggers. Sem Integration Procedures (IPs). Toda a camada de orquestração, integração e persistência será construída em Apex seguindo padrões modulares de desenvolvimento corporativo.

Regra de NBO no Fluxo Operacional: O NBO é uma etapa de pré-atendimento prioritária. Se houver oferta elegível, o operador tem a diretriz de abordar a venda/oportunidade antes de seguir para a resolução do atendimento original. Portanto, a resposta do NBO precisa estar pronta e visível logo na identificação do cliente.

📌 Quadro de Memória Progressivo (Consolidado)
Entradas de Busca: CPF (PF) ou CNPJ convencional/alfanumérico (PJ).

Fluxo de Apresentação:

Disparo de Busca: Validação de máscara e acionamento paralelo no backend.

Card/Alerta NBO em Destaque: Visualização imediata de ofertas disponíveis para abordagem consultiva/venda logo no início do contato.

Seleção Primária de Produtos Porto Bank: Lista de produtos com contratos ativos (Cartão, Consórcio, Conta Digital, Investimentos).

Seleção Secundária Condicional: Drawer/Sub-seletor exclusivo para Cartões de Crédito (status ativo, cancelado, vias).

Estratégia Técnica - Backend (Apex First):

Microsserviços em Apex: Classes de serviço desacopladas por domínio (ex.: CustomerSearchService, NboService, CardService), sem arquivos monolíticos.

Triggers com Framework Enterprise: Uso de Trigger Handler Pattern ou Domain Layer desacoplada, evitando lógica pesada direta nas triggers e delegando persistência de apoio a jobs assíncronos (Queueable / EventBus).

Estratégia Técnica - Frontend (Microfrontends):

Decisão Aberta: Avaliação de LWC Modular (com comunicação via Lightning Message Service - LMS) vs. OmniStudio (OmniScript/FlexCards) com chamadas Apex.

⚖️ Trade-offs de Frontend: LWC Puro vs. OmniStudio com Apex
Como o backend será 100% Apex, temos duas opções claras para a camada de Microfrontends:

Critério	Opção A: Microfrontends em LWC Puro	Opção B: OmniStudio (OmniScript + FlexCards) chamando Apex
Performance e TMA	Máxima. Menor tempo de carregamento no navegador, manipulação de estado em memória ultrarrápida e renderização simultânea via Promise.all.	Muito boa, mas com sobrecarga de carregamento do framework do OmniStudio e metadados de execução.
Desacoplamento	Alto. Componentes modulares independentes (c-search-bar, c-nbo-card, c-product-hub) conectados por Lightning Message Service (LMS). Subir um produto novo não exige mexer nos demais.	Médio/Alto. FlexCards isolam bem os cards de produto, mas o fluxo sequencial no OmniScript ainda depende de regras de step.
Time-to-Market de Telas	Exige desenvolvimento de código front-end (HTML/CSS/JS) para novos layouts.	Alterações de layout e novos cards podem ser feitas com baixo código por analistas via FlexCards.
Controle de UI/UX	Total liberdade para encaixar com precisão no design system da Porto Bank (badges de status, skeletons de carregamento, drawers laterais).	Limitado às capacidades e componentes nativos do OmniStudio.
❓ Perguntas de Fechamento da Etapa de Busca e Próximo Passo
Preferência de Frontend: Olhando para os trade-offs acima e o foco em performance bruta no TMA do operador, você prefere seguir a especificação com LWC Puro Modular (via LMS) ou OmniStudio integrado a Apex Controllers (Callable)?

Próxima Jornada: Com o NBO tratado e o produto motivador selecionado pelo operador, qual é a próxima jornada do atendimento que vamos desenhar? (Ex.: abertura e categorização do Caso/Protocolo, tela de visão 360° com saldo/fatura, ou validação de segurança/MFA?)

Quanto às suas perguntas, olhando para boas práticas e experiência da comunidade, é melhor a gente seguir com o LWC, modularizado, componentizado, ou soluções do Omni Studio integrado ao Apex, como, por exemplo, o Omni Script ou Flex Card. É, eu preciso de sugestões. É,

Considerando as boas práticas corporativas, a maturidade da comunidade Salesforce e o perfil de uma operação bancária/financeira com foco em TMA, a recomendação técnica consolidada é adotar um modelo híbrido estratégico, com forte prevalência de LWC para este ponto específico da jornada:

🏆 Recomendação: Microfrontends em LWC Puro (via LMS) para a Busca e Identificação
Para a Jornada de Busca, NBO e Seleção de Contexto, LWC Modular é a melhor escolha técnica e operacional. Os motivos são:

Performance e TMA (Latência Zero):

O OmniStudio carrega um runtime pesado no navegador antes de renderizar (motor de metadados, avaliação de fórmulas, listeners).

Com LWC puro, o primeiro carregamento da tela é praticamente instantâneo. Utilizando Promise.all no JavaScript, o front-end dispara a chamada do NBO e a busca de contratos para o backend Apex em paralelo real. O operador não percebe travamentos de tela nem atrasos de renderização.

Verdadeiro Desacoplamento de Microfrontends:

Com LWC, você desacopla completamente as partes usando Lightning Message Service (LMS).

Exemplo prático:

Componente A (c-customer-search): Apenas coleta CPF/CNPJ, formata e publica a mensagem CustomerSelected.

Componente B (c-nbo-banner): Ouve o canal e busca as ofertas de forma assíncrona. Se amanhã o motor de NBO mudar ou for desativado, apenas esse componente é alterado ou ocultado.

Componente C (c-product-selector): Ouve o canal, busca os contratos e renderiza a esteira de produtos.

Componente D (c-card-drawer): Só é invocado se o card de "Cartão de Crédito" for selecionado.

Em OmniScripts, por mais que se use blocos condicionais, o fluxo ainda é orquestrado em um fluxo único de steps, o que reintroduz risco de acoplamento quando múltiplos times mexem no mesmo fluxo.

Arquitetura de Backend já definida como Apex:

Como a decisão é não usar Integration Procedures (IPs) e fazer o backend 100% em Apex/Triggers, usar OmniStudio exigiria implementar interfaces Callable ou controladores Apex adaptadores em todas as chamadas. LWC consome métodos Apex anotados com @AuraEnabled(cacheable=true) de forma nativa, com caching local automático pelo Lightning Data Service.

🎯 Onde o OmniStudio brilha e deve ser utilizado?
Não descarte o OmniStudio no projeto. A boa prática no Financial Services Cloud é:

LWC: Para a casca (Shell), busca unificada, cockpit inicial e widgets dinâmicos de alta performance (onde cada milissegundo conta no início da chamada).

OmniScripts: Para as jornadas transacionais subsequentes guiadas (ex.: fluxo de contestação de compra, cancelamento de cartão, alteração de limite, renegociação de dívida). Nessas esteiras de processo passo a passo, o OmniScript reduz drasticamente o tempo de desenvolvimento (low-code), pois o operador precisa de um roteiro de perguntas, validações de negócio e envio de comprovante.

FlexCards: Para painéis estáticos de leitura/resumo (ex.: bloco de dados cadastrais complementares na barra lateral).

📌 Resumo Arquitetural Recomendado para a Etapa 1
Frontend: LWC Modularizado (c-customer-search-shell gerenciando componentes filhos independentes via Lightning Message Service).

Backend: Camada de serviços Apex (CustomerSearchService, NboService, CardService) desacoplada, expondo métodos @AuraEnabled com DTOs limpos e Trigger Handler Framework.

Se essa diretriz fizer sentido para você, registramos essa decisão no nosso quadro e podemos avançar:
Qual é a próxima etapa da jornada que devemos mapear? (Ex.: validação cadastral/segurança, tela 360° do produto após a seleção, ou abertura do Caso/Protocolo?)

Essa diretriz faz muito sentido, tá aprovado. Vamos seguir com o LWC para essas questões, né, de Shell e Omni Scripts ou Flex Cards para jornadas transacionais. Tá aprovado. E agora quanto a falando um pouco mais sobre experiência de usuário, construção desses componentes, tela, UX, UI, System Design, coisas do tipo ali. Você conseguiria fornecer ali um padrão que é utilizado por empresas de grande porte, financeiras, ou até mesmo utilizando ali o Salesforce Financial Service Cloud. Queria ter um pouco mais de noção agora de como que vai ser cada componente que vai compor essa jornada, tanto a nível funcional, quanto a nível de design também.

Ótimo! Decisão formalizada no nosso quadro: LWC Modular para Cockpit/Shell/Identificação e OmniStudio (OmniScripts/FlexCards) para as jornadas transacionais subsequentes.

Para desenhar a experiência de usuário (UX/UI) e o Design System, o padrão de excelência de grandes instituições financeiras que rodam sobre o Financial Services Cloud (FSC) utiliza a base do Lightning Design System (SLDS) aliada à ergonomia de console bancário (Service Cloud Console com abas de espaço de trabalho / Workspace Tabs).

Abaixo está a decomposição funcional e visual detalhada de cada componente que compõe esse cockpit de identificação.

🎨 1. Princípios de Design & Ergonomia para Atendimento Bancário
Densidade Visual Compacta (SLDS Density: Compact): Em operações bancárias, o operador precisa ver as informações-chave sem fazer rolagem (scroll). Espaçamentos reduzidos e uso de tipografia com pesos bem definidos (slds-text-heading_small, slds-text-body_regular).

Hierarquia por Cores Funcionais (Design Tokens):

Status de Produtos: Verde neutro/suave para produtos/cartões ativos; cinza para inativos/cancelados; âmbar para bloqueados/pendentes.

NBO / Ofertas: Cor de destaque institucional (ex.: azul/dourado de oportunidade) com ícone de distinção (utility:opportunity ou utility:advisory_event), evitando que pareça uma mensagem de erro ou aviso de sistema.

Carregamento Progressivo (Skeleton Screens): Nada de spinners de tela cheia que travam o operador. Cada micro-componente exibe blocos cinzas pulsantes (SLDS Skeletons) enquanto busca seus dados no Apex.

🧩 2. Decomposição dos Microfrontends (Componente a Componente)
+------------------------------------------------------------------------------------+
| [c-customer-search-bar]                                                            |
|  [ CPF / CNPJ (com máscara) ]  [ Botão Buscar / Enter ]   (Atalhos: F2, Enter)     |
+------------------------------------------------------------------------------------+
| [c-nbo-banner]  (Renderização Assíncrona Independente)                             |
|  💡 Oportunidade Identificada: Oferta Cartão Black pré-aprovado   [ Abordar Venda ]|
+------------------------------------------------------------------------------------+
| [c-customer-header-summary]                                                        |
|  Nome Completo | Tipo (PF/PJ) | CPF/CNPJ | Status de Relacionamento Porto Bank     |
+------------------------------------------------------------------------------------+
| [c-product-hub] (Seleção Primária)                                                 |
|  +-------------------+  +-------------------+  +-------------------+               |
|  | Cartão de Crédito |  |   Conta Digital   |  |     Consórcio     |  ...          |
|  | (3 Contratos)     |  |   (Ativa)         |  |   (1 Cota)        |               |
|  +-------------------+  +-------------------+  +-------------------+               |
+------------------------------------------------------------------------------------+
| [c-card-drawer / Modal Lateral] (Acionado apenas se clicar em "Cartão")             |
|  - Final 1234 (Visa Infinite)   - Status: ATIVO       [ Selecionar ]               |
|  - Final 5678 (Master Platinum) - Status: CANCELADO   [ Selecionar ]               |
+------------------------------------------------------------------------------------+
Componente 1: c-customer-search-bar (Barra de Pesquisa de Entrada)
Objetivo: Captura e validação rápida da chave de busca.

Comportamento Funcional:

Máscara dinâmica: detecta digitação e formata automaticamente para CPF (000.000.000-00) ou CNPJ padrão e alfanumérico.

Tecla de atalho: Enter aciona a busca imediatamente.

Ao disparar, valida dígito/formato localmente no front-end antes de chamar o backend, economizando requisições.

Publica no Lightning Message Service (LMS): { event: 'CUSTOMER_SEARCH_TRIGGERED', document: '...' }.

Componente 2: c-nbo-banner (Widget de Venda Consultiva)
Objetivo: Cumprir a regra de apresentar oportunidades de negócio imediatamente no pré-atendimento.

Comportamento Funcional & Visual:

Ouve o evento do LMS. Enquanto busca, exibe um skeleton bar sutil.

Se não houver ofertas elegíveis, o componente se contrai automaticamente (display: none), sem ocupar espaço em tela.

Se houver oferta:

Apresenta um banner estilizado (SLDS Scoped Notification ou Badge Card).

Mostra o produto sugerido, benefício principal (ex.: "Isenção de anuidade 1º ano") e botão de ação primária: "Iniciar Venda / Abordar".

Se o operador clicar no botão, ele já direciona para o fluxo guiado (OmniScript de Venda/Adesão).

Componente 3: c-customer-header-summary (Faixa de Identificação Rápida)
Objetivo: Fornecer ao operador a confirmação demográfica imediata de com quem ele está falando.

Comportamento Visual:

Barra horizontal compacta (SLDS Page Header estilizado).

Campos: Nome/Razão Social, Documento, Faixa de Relacionamento/Segmento (ex.: Exclusivo, Varejo).

Componente 4: c-product-hub (Hub de Seleção de Produtos Porto Bank)
Objetivo: Permitir a escolha em 1 clique do produto motivador do contato.

Padrão de Design (Grid de Cartões de Seleção):

Disposição em grade responsiva (SLDS Grid).

Cada produto Porto Bank é renderizado como um cartão interativo com ícone nativo (ex.: standard:credit_card, custom:custom41 para consórcio, standard:bank para conta digital).

Informações no card:

Nome do Produto.

Resumo rápido (ex.: "2 contratos ativos", "Conta Ativa", "1 cota sorteada").

Interatividade: O card possui efeito de hover e estado de seleção nítido (borda destacada com a cor da marca).

Extensibilidade (Microfrontend): O catálogo de produtos renderizados consome um array configurável via metadados. Adicionar um produto novo (ex.: Financiamento de Veículos) significa apenas adicionar a definição de tipo e ícone no backend, sem refatorar o layout.

Componente 5: c-card-drawer (Seletor Específico de Cartões)
Objetivo: Tratar a especificidade de cartões (múltiplas vias, ativos e cancelados) sem poluir o grid principal.

Padrão de Design:

Abre como um painel lateral retrátil (Drawer / Off-canvas) ou SLDS Modal enxuto.

Exibe uma tabela compacta ou lista de mini-cards com:

Bandeira (Visa / Mastercard) + Categoria (Gold, Platinum, Infinite/Black).

Últimos 4 dígitos (**** **** **** 1234).

Nome do Portador (Titular ou Adicional).

Badge de Status:

Verde (slds-theme_success): Ativo.

Cinza/Neutro (slds-theme_shade): Cancelado.

Amarelo/Aviso (slds-theme_warning): Bloqueado temporariamente.

Ação de seleção rápida: Um clique em qualquer linha define o cartão e avança o atendimento.

🔄 3. Comunicação e Estado (Lightning Message Service - LMS)
Para manter os microfrontends 100% desacoplados, a comunicação entre eles não usa passagem de parâmetros acoplada de pai para filho (@api), mas sim um canal de eventos CustomerInteractionChannel__c:

SearchEvent: Contém o CPF/CNPJ. Todos os componentes escutam e acionam seus respectivos métodos Apex de forma independente.

ProductSelectedEvent: Disparado pelo c-product-hub ou c-card-drawer quando o operador clica no produto desejado.

InteractionContext: Consolida o ID do cliente e o ID do contrato/cartão selecionado para carregar o Console/Workspace de atendimento.

❓ Validação e Próximos Passos
Esse modelo de interface (Barra rápida + Banner NBO condicional + Grid de produtos modulares + Drawer lateral de cartões) atende às necessidades de usabilidade e agilidade dos operadores?

Uma vez que o operador clica no produto final (ou no cartão selecionado no Drawer), o que acontece na sequência do atendimento?

Abre a tela 360° do produto?

Abre um formulário de abertura de Caso/Protocolo?

O sistema já inicia uma jornada guiada em OmniScript?

Vamos nos concentrar ainda na jornada de busca de cliente. Você tem condições de, respeitando todas essas premissas de design system que colocou, apresentar uma tela ou um conjunto de telas que apresenta um protótipo de como que ficaria essa busca. Lógico que ela é sequencial, então, como é que ficaria a primeira tela? Depois eu te dou o comando para a segunda tela, terceira, até o final. Você, você tem condições de criando essas imagens de protótipo, só para eu visualizar como que seria essas experiências em tela do seu Force Financial Service Cloud?

Não consigo gerar arquivos de imagem direta (como PNGs ou JPEGs renderizados), mas consigo entregar protótipos interativos de alta fidelidade em código HTML/SLDS (Salesforce Lightning Design System) ou wireframes estruturais em ASCII/Mockup visual de precisão, exatamente como você veria dentro do Service Cloud Console no Financial Services Cloud.

Para o passo a passo sequencial, vamos começar com a Tela 1: Estado Inicial de Busca (Cockpit em Repouso).

🖥️ Protótipo - Tela 1: Estado Inicial / Espera (Cockpit de Identificação)
Esta é a tela que o operador vê assim que abre a aba de atendimento ou finaliza uma chamada anterior. O foco é ergonomia visual limpa, atalhos de teclado e ausência total de poluição visual.

Plaintext
========================================================================================================================
 🏢 Porto Bank  |  Service Console  |  🔍 [ Buscar cliente... F2 ]                              👤 Operador: Carlos Silva
========================================================================================================================
 [ Aba Principal: Identificação de Cliente ✖ ] [ + Nova Interação ]
------------------------------------------------------------------------------------------------------------------------

 +--------------------------------------------------------------------------------------------------------------------+
 | 🔍 IDENTIFICAÇÃO DO CLIENTE                                                                                        |
 | Digite o documento do cliente para iniciar o atendimento integrado Porto Bank.                                     |
 +--------------------------------------------------------------------------------------------------------------------+
 |                                                                                                                    |
 |   Tipo de Documento             CPF ou CNPJ (Alfanumérico aceito)                                                   |
 |  (•) PF (CPF)   ( ) PJ (CNPJ)   [ 000.000.000-00              ]   [  🔍 Localizar Cliente (Enter)  ]               |
 |                                  ▲ Auto-máscara aplicada ao digitar                                                |
 |                                                                                                                    |
 +--------------------------------------------------------------------------------------------------------------------+

 +--------------------------------------------------------------------------------------------------------------------+
 | ℹ️ HISTÓRICO DE ATENDIMENTOS RECENTES DA SESSÃO                                                                     |
 | Nenhum cliente em atendimento ativo no momento. Pressione [Enter] após inserir o documento para carregar o cockpit.|
 +--------------------------------------------------------------------------------------------------------------------+

========================================================================================================================
 🟢 Omni-Channel: Disponível (Voz / Chat)   |   ⏱️ Tempo de Sessão: 00:02:15   |   🗂️ Protocolo: Aguardando identificação
========================================================================================================================
🛠️ Código do Componente LWC (Fidelidade Nativa SLDS)
Se você colar este trecho em um componente LWC de teste, verá exatamente a renderização oficial do Salesforce:

HTML
<!-- c-customer-search-bar.html -->
<template>
    <lightning-card title="Identificação do Cliente" icon-name="standard:search">
        <div class="slds-p-around_medium">
            <div class="slds-grid slds-gutters slds-grid_vertical-align-center">
                <!-- Seletor de Tipo / Atalho -->
                <div class="slds-col slds-size_3-of-12">
                    <lightning-radio-group
                        name="docType"
                        label="Tipo de Pessoa"
                        options={docTypeOptions}
                        value={docType}
                        type="button"
                        onchange={handleDocTypeChange}>
                    </lightning-radio-group>
                </div>

                <!-- Campo de Entrada com Máscara Dinâmica -->
                <div class="slds-col slds-size_6-of-12">
                    <lightning-input 
                        type="text" 
                        label="CPF ou CNPJ" 
                        placeholder="Insira os números ou formato alfanumérico..."
                        value={documentNumber}
                        onchange={handleDocumentChange}
                        onkeyup={handleKeyUp}
                        required
                        field-level-help="Aceita CPF padrão, CNPJ numérico e CNPJ alfanumérico BACEN.">
                    </lightning-input>
                </div>

                <!-- Botão de Ação Primária -->
                <div class="slds-col slds-size_3-of-12 slds-p-top_large">
                    <lightning-button 
                        variant="brand" 
                        label="Localizar Cliente" 
                        icon-name="utility:search" 
                        onclick={handleSearch}
                        disabled={isSearchDisabled}
                        class="slds-m-left_x-small">
                    </lightning-button>
                </div>
            </div>
        </div>
    </lightning-card>
</template>
📋 Regras de Negócio & UX Ativas na Tela 1:
Foco Automático: O cursor do teclado já inicia posicionado no campo de documento (auto-focus).

Validação Prévia de Dígito: O botão "Localizar Cliente" só é habilitado quando a máscara atinge o comprimento válido (11 dígitos para CPF ou 14 caracteres para CNPJ), evitando chamadas inúteis ao Apex.

Tecla de Atalho: O operador pode apenas digitar os números e apertar Enter.

Quando estiver pronto, me dê o comando e vamos para a Tela 2: Estado de Carregamento Assíncrono com Skeleton Screens e Exibição do Banner NBO + Dados Cadastrais.

Eu ativei aqui o modo de criação de imagem. Nem assim você consegue apresentar um protótipo de tela em uma imagem estática, só para eu ter como uma mínima referência visual. Eu entendo que você consegue criar HTML, mas eu teria que renderizar isso daí, criar um arquivo e renderizar. Um protótipo de tela em imagem, como você pode criar para mim. Agora ativei o modo de criação de imagem do Google Gemini. Pode me dar uma ideia visual de mais rápido entendimento.

A clean, professional static mock-up of the Salesforce Financial Services Cloud (FSC) Service Console interface, rendered as a single image. The overall layout adheres to the compact Salesforce Lightning Design System (SLDS). The main workspace area is divided into logical, modular components representing LWCs, clearly organized on a neutral background.

At the top, a simple 'Service Console' header with a main workspace tab labeled 'Identificação do Cliente' and a '👤 Operador: Carlos Silva' badge. Below the tab, the main interaction panel is displayed.

The topmost component is '🔍 IDENTIFICAÇÃO DO CLIENTE' (Customer Identification) header, followed by the 'c-customer-search-bar' input. This input field is active, showing a segmented radio button for 'PF (CPF)' (selected) and 'PJ (CNPJ)'. The input field has the label 'CPF ou CNPJ (Alfanumérico)' with a user-typed number '123.456.789-0' (masked with placeholders '0' and '-' showing dynamic formatting). A prominent blue 'Localizar Cliente (Enter)' button is adjacent.

Below the search bar, the 'c-nbo-banner' (Next Best Offer) component is displayed as a highlighted blue notification card with a utility icon '💡'. Text reads: 'Oportunidade Identificada: Oferta Cartão Black pré-aprovado' with a blue action button 'Abordar Venda'.

The next section down is the 'c-customer-header-summary' (Customer Header Summary). This compact horizontal bar shows key demographic details: '👤 João da Silva', 'Tipo: Pessoa Física', 'CPF: 123.456.789-00', 'Relacionamento: Exclusivo'.

Finally, the 'c-product-hub' (Product Selection Hub) is displayed as a clean grid of product cards, as if just populated after a search. Each card uses a standard SLDS icon, a product name, and a status badge. Visible cards: '💳 Cartão de Crédito (3 Contratos, Ativo)', '🏦 Conta Digital (Ativa)', '🪙 Consórcio (1 Cota, Sorteada)'. The entire grid is framed by a subtle hover effect on the first card, suggesting user selection.

The entire interface is static, framed by a standard Salesforce footer showing '🟢 Omni-Channel: Disponível' and '🗂️ Protocolo: Em identificação'. The colors are professional blues, grays, and clear status indicators (green/blue). The look is clean, efficient, and instantly recognizable as a financial services workspace., AI generated, gerada com IA
Compreendo perfeitamente o seu pedido de agilidade visual. Com o modo de criação de imagem ativado, gerei este protótipo estático para a Tela 2: Resultado da Busca e Cockpit Populado.

Esta imagem representa o estado do sistema imediatamente após o operador inserir o CPF e pressionar 'Enter'. Como você pode ver, ela respeita o layout compacto do Service Console e a densidade de informações de um ambiente bancário.

🔍 Destaques Visual do Protótipo (image_0.png)
Orquestração Assíncrona: A tela não travou. Você vê que a barra de busca (c-customer-search-bar) está populada e o banner NBO (c-nbo-banner) e o resumo demográfico (c-customer-header-summary) apareceram rapidamente.

Pré-Atendimento Prioritário (NBO): O banner azul de oportunidade (💡) ganha destaque logo abaixo da busca. O operador vê a oferta (Cartão Black) e o botão "Abordar Venda", permitindo que ele inicie a prospecção antes de qualquer outra ação, conforme a regra de negócio definida.

Seleção Primária de Produtos (Microfrontends): O c-product-hub renderiza a grade de contratos ativos da Porto Bank. Note que o operador pode ver de imediato que o cliente tem 3 contratos de Cartão de Crédito e Conta Digital ativa.

Desacoplamento Visual: Cada bloco funciona de forma independente, permitindo que novos produtos ou ofertas sejam plugados sem refatorar o layout inteiro.

Este protótipo estático valida a direção visual que tomamos para garantir performance e simplicidade operacional.

Podemos avançar para o próximo passo? Se o operador clicar em "Cartão de Crédito" no Grid de Produtos (atualmente selecionado na imagem), o sistema abrirá o Drawer/Modal Lateral com a lista de cartões (ativos, cancelados, vias), que seria a nossa próxima visualização.

Excelente. Acho que essa é a jornada realmente que a gente precisa. Mas ele ainda tá muito feia, eh, não respeita muito bem o system design da plataforma e etc. Você consegue trazer componentes mais modernos, eh, mais alinhados ao design system atual da Salesforce, para que fique o mais próximo do que eu vou desenvolver dentro da plataforma.

A photorealistic, high-resolution mockup of a modern Salesforce Financial Services Cloud (FSC) Service Console interface, based on <IMAGE_0>, but with significantly upgraded visual design to align with the modern Salesforce Lightning Design System (SLDS). The overall layout remains logical, but with increased clean whitespace, refined typography, and more subtle, elegant styling.

At the very top, a simplified 'Porto Bank | Service Console' header with cleaner icons and a small Porto Bank logo. The main tab is labeled 'Identificação do Cliente'.
Below the header, the 'IDENTIFICAÇÃO DO CLIENTE' title is stylized with a cleaner, bold SLDS font and a smaller utility icon.

The 'c-customer-search-bar' is transformed. The radio buttons are replaced by a sleek, segmented control within a cleaner field container. The CPF/CNPJ input is a minimal, clean text box with a clear placeholder, dynamic masking, and a refined blue search button that uses a modern blue and a subtle shadow effect.
The 'c-nbo-banner' is no longer a harsh blue bar. It is a soft-toned, light blue informational card with a very refined utility icon. The text 'Oportunidade Identificada: Oferta Cartão Black pré-aprovado' uses a clean, balanced font. The action button 'Abordar Venda' is a sleek, modern, gradient-less button with a clean shadow and increased border-radius.

The 'c-customer-header-summary' is a clean horizontal card with soft rounded corners. The fields ('João da Silva', 'Tipo: Pessoa Física', 'CPF: 123.456.789-00', 'Relacionamento: Exclusivo') are arranged neatly with refined icons and clear, balanced SLDS labels.

The 'c-product-hub' section is significantly modernized. Each product is in a soft, clean card with a substantial box-shadow, generous padding, and cleaner icons. The 'Cartão de Crédito' card, with a 'Selected' highlight (blue border and soft background change), shows detailed information and the refined 'Ativo' badge. The icons within the cards are sleeker. The entire grid has cleaner spacing.
The grid is organized to fit four cards comfortably in a row, with other placeholders: 'Cartão de Crédito' (Selected), 'Conta Digital', 'Consórcio', and 'Investimentos' (all with appropriate icons and badges). Other cards like 'Coletivo', 'Coletas', and 'Contratos' (from <IMAGE_0>) are integrated as additional cards with placeholder icons. A horizontal scroll arrow or 'View All' link is present.

The overall interface has a subtle gradient-less color palette of clean blues, grays, and whites. Rounded corners are consistent. Status badges ('Ativo') are more refined with softer colors. Icons are cleaner. The footer is minimal, with clean text for '🟢 Omni-Channel: Disponível' and '🗂️ Protocolo: Em identificação'. White space is abundant, making the interface feel open and less dense. A subtle Porto Bank watermark pattern is visible on the main canvas., AI generated, gerada com IA
Ficou excelente agora para eu criar um conjunto de documentações e especificação para desenvolvimento dessa jornada. Você tem alguma recomendação, alguma pergunta, eh, alguma direção, alguma referência até mesmo de documentação, repositório no GitHub, documentação técnica, projeto que entrega esse tipo de valor ou ferramenta que ajuda no System Design para eh eh desenvolvimento da tela com elementos mais modernos. Fica à vontade, que vai ser a última pergunta que a gente vai seguir aqui.

Aqui está o kit completo de referências técnicas, repositórios oficiais, ferramentas de design e a estrutura recomendada para fechar a documentação de especificação com chave de ouro:

1. Ferramentas Recomendadas para System Design & Prototipação
Salesforce Lightning Design System (SLDS) Web & Component Blueprints:

Documentação oficial dos componentes (lightningdesignsystem.com). É a bíblia de CSS, tokens de espaçamento (spacing), sombras (elevation) e classes utilitárias compactas para Service Console.

SLDS UI Kit para Figma (Oficial da Salesforce):

Pesquise na Figma Community por "Salesforce Lightning Design System (SLDS) UI Kit" (mantido pelo time oficial da Salesforce UX).

Ele contém todos os componentes prontos no padrão SLDS moderno: cabeçalhos de console, tabs, badges de status, pills, cards e drawers em formato de auto-layout, facilitando exportar especificações exatas de espaçamento e cores para os desenvolvedores.

LWC Component Recipes / Component Library:

A própria Salesforce Component Reference ([developer.salesforce.com/docs/component-library](https://developer.salesforce.com/docs/component-library)) permite testar e inspecionar código de botões, inputs com máscara, radio groups e banners diretamente no navegador.

2. Repositórios Oficiais no GitHub & Padrões de Arquitetura
Para manter a premissa de microsserviços desacoplados e evitar monólitos em Apex e LWC, consulte estas referências padrão da indústria:

LWC Recipes (trailheadapps/lwc-recipes no GitHub):

O repositório oficial de referência da Salesforce.

Verifique especificamente as pastas:

messageService: Exemplos puros de publicação e assinatura de eventos entre componentes isolados via Lightning Message Service (LMS) sem acoplamento pai-filho.

apexWireMethodWithParams e apexImperativeMethod: Padrões para chamadas paralelas e controle de promises assíncronas.

Apex Enterprise Patterns (fflib-apex-common / Apex Commons):

O padrão de ouro para eliminar triggers monolíticas e acoplamento em back-end Apex corporativo.

Divide a lógica em 4 camadas bem delimitadas:

Domain Layer: Trata validações de negócio dos objetos.

Service Layer: Microsserviços orquestradores (ex.: CustomerSearchService, NboService, CardService).

Selector Layer: Centraliza e otimiza queries SOQL.

Application Layer (Trigger Handler): Executa apenas despacho de eventos sem regras de negócio embutidas na trigger.

3. Estrutura Recomendada para o Documento de Especificação Técnica e Funcional
Para que o time de desenvolvimento execute com clareza e sem retrabalho, estruture o documento de especificação nos seguintes tópicos:

Visão Geral & Objetivos de Negócio:

Contexto da migração para FSC, foco na redução do TMA e priorização da abordagem consultiva de NBO.

Matriz de Arquitetura & Decisões Técnicas (ADRs - Architecture Decision Records):

Decisão 1: LWC Modularizado com LMS para a casca de cockpit e seleção; OmniStudio reservado para esteiras transacionais subsequentes.

Decisão 2: Back-end 100% Apex em camadas de serviço (sem Integration Procedures).

Decisão 3: Ausência de DML síncrono pesado na busca; persistência transacional sob demanda.

Decomposição dos Componentes de Front-End (Microfrontends):

c-customer-search-bar: Regras de validação (CPF 11 dígitos, CNPJ numérico 14 dígitos e CNPJ alfanumérico BACEN), tecla de atalho (Enter), payload do evento LMS.

c-nbo-banner: Regra de prioridade de abordagem, renderização assíncrona, botões de ação ("Abordar Venda" / "Dispensar").

c-customer-header-summary: Mapeamento dos campos cadastrais exibidos.

c-product-hub: Grid dinâmico baseado em metadados customizados (Custom Metadata Types) para renderizar cada produto Porto Bank.

c-card-drawer: Modal/Drawer lateral acionado pelo evento de Cartão de Crédito, regras visuais de status (ativo vs. cancelado) e seleção de via.

Contratos de Integração & Back-End Apex:

DTOs de entrada e saída (JSON/Apex Classes) para cada serviço:

SearchClientDemographicsRequest/Response

GetNboOffersRequest/Response

GetCardsSummaryRequest/Response

Gestão de falhas e timeouts: Tratamento de indisponibilidade de APIs sem bloquear o operador.

Critérios de Aceite & Cenários de Teste (Gherkin/BDD):

Exemplos práticos: "Dado que o operador insere um CPF com NBO elegível...", "Dado que o cliente possui 2 cartões cancelados e 1 ativo...".

Essa estrutura cobre desde a experiência do usuário até a governança de código no Salesforce, garantindo que o time receba uma especificação pronta para planejamento de sprints e refinamento técnico.

Ok, falta um ponto importante que a gente precisa declarar aqui. Não é só o front-end, também é o modelo de dados dentro do seu Force e Financial Service Cloud. A partir do momento que eu busco o CPF do cliente, me traz ali conta, contato e outras informações do cliente. É, eu preciso atualizar o registro de no objeto account e contact. Você poderia sugerir uma, uma solução nesse sentido? Da mesma maneira, quando eu apresento um NBO, é importante registrar se existe uma oportunidade, registrar essa oportunidade no objeto oportunidade dentro do Financial Service Cloud. E assim, quando eu seleciono um produto, seria interessante também atualizar o registro de asset. Então, dessa forma, conforme eu for navegando entre os componentes, eu vou também atualizando os registros no back-end, para quando eu precisar fazer uma consulta numa visão 360 desse cliente, eu tenho ali todos esses registros atualizados. Poderia sugerir também uma arquitetura de como que eu integro a busca de cliente, a modelagem de dados do Financial Service Cloud, para deixar 100% padrão dentro da modelagem de dados desse novo ambiente.

Esse alinhamento de Modelo de Dados (Data Model) e Estratégia de Persistência no Financial Services Cloud (FSC) é crucial para garantir que a visão 360° fique consistente, sem recair nas armadilhas de lentidão transacional e triggers pesadas do sistema legado.

Abaixo está o desenho arquitetural de referência para modelagem, ciclo de vida dos dados e o padrão de atualização progressiva durante a jornada de busca.

🏛️ 1. Mapeamento para o Modelo de Dados Nativo do Financial Services Cloud
No FSC, a Salesforce substituiu o uso tradicional de Asset para produtos bancários por objetos financeiros dedicados que suportam relacionamentos complexos, titularidades e consolidação de saldos:

Domínio de Negócio	Objeto Legado	Objeto Padrão FSC Recomendado	Como Utilizar
Cliente PF	Account + Contact	Person Account (Record Type: Person Account)	Unifica o indivíduo. Não há necessidade de gerenciar Contact separado via DML, pois o Salesforce trata nativamente como uma entidade única com CPF em campo com External ID.
Cliente PJ	Account (Custom)	Account (Business) + Contact	Suporta a nova regra de CNPJ convencional ou alfanumérico em campo dedicado indexado/External ID.
Oferta NBO	Objeto Customizado	Opportunity (Record Type: General Financial Service)	Vínculo direto à AccountId. Se o operador clicar em "Abordar", a oportunidade ganha o estágio Qualification/In Progress.
Produtos Financeiros (Conta Digital, Consórcio, Investimentos)	Asset	FinServ__FinancialAccount__c	É o objeto nativo do FSC para representar qualquer contrato financeiro (subtipos: Banking, Investment, Credit Card).
Cartões de Crédito (Plásticos / Vias)	Asset	FinServ__FinancialAccount__c + FinServ__Card__c	A Conta de Cartão (linha de crédito) fica em FinancialAccount, e os plásticos físicos/virtuais (com seus respectivos números finais e status ativo/cancelado) ficam no objeto padrão FinServ__Card__c.
⚠️ Sobre o uso de Asset: Se na Porto Bank ainda houver necessidade estrita de manter Asset por compatibilidade com ecossistemas da Holding (ex.: apólices de seguro ou equipamentos), podemos manter o Asset. Porém, para produtos bancários (Cartão, Conta, Consórcio), a melhor prática no FSC é adotar Financial Account e Card para habilitar os componentes nativos de visão 360° (Financial Summary, Rollup Summaries).

🔄 2. Estratégia de Atualização Progressiva & Desacoplada (Step-by-Step)
A regra de ouro para não travar a tela do operador é a Persistência Assíncrona On-Demand (o front-end exibe os dados em memória enquanto o backend faz a ingestão/upsert em segundo plano, ou na confirmação de etapas):

[Busca CPF/CNPJ] 
   │
   ├──> (1) Front-end recebe JSON da API Cadastral & Renderiza
   │    └──> Dispara Apex Queueable em Background: Upsert em Person Account (CPF = External ID)
   │
[Exibição NBO]
   │
   ├──> (2) Se houver Oferta Elegível:
   │    └──> Upsert assíncrono em Opportunity (Fase: Prospecting / Identification)
   │
[Seleção de Produto]
   │
   └──> (3) Operador seleciona Cartão / Conta / Consórcio:
        └──> Dispara Upsert do Contrato específico em FinServ__FinancialAccount__c 
             (e FinServ__Card__c se for cartão) vinculado ao Case gerado.
⚙️ 3. Como Implementar essa Arquitetura em Apex
Para manter a separação de responsabilidades (Enterprise Patterns / Service Layer):

Passo A: Identificação e Upsert de Cliente (Person Account)
O método de busca consulta a API externa de cadastro, formata os dados para o DTO de tela e despacha a sincronização do cliente:

Apex
public with sharing class CustomerSyncService {
    
    public static void syncClientData(CustomerDTO clientData) {
        // Despacha a sincronização para não bloquear a thread síncrona da UI
        System.enqueueJob(new SyncAccountQueueable(clientData));
    }

    public class SyncAccountQueueable implements Queueable {
        private CustomerDTO dto;
        public SyncAccountQueueable(CustomerDTO dto) { this.dto = dto; }

        public void execute(QueueableContext ctx) {
            Account acc = new Account();
            acc.CPF__c = dto.documentNumber; // Campo com flag External ID e Unique
            acc.FirstName = dto.firstName;
            acc.LastName = dto.lastName;
            acc.PersonEmail = dto.email;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                               .get('PersonAccount').getRecordTypeId();
            
            // Upsert atômico e sem locks
            upsert acc CPF__c;
        }
    }
}
Passo B: Registro da Oportunidade NBO
Quando a API de NBO retorna uma recomendação qualificada:

Cria-se/atualiza-se uma Opportunity com:

AccountId vinculada à conta do cliente.

StageName inicial: 'Prospecting' (ou 'Identificada').

Description / Campos customizados com detalhes do benefício da oferta.

Ação do Operador: Se o operador clicar em "Abordar Venda", o front-end apenas atualiza a oportunidade para 'In Progress', vinculando-a ao atendimento atual. Se dispensar, marca como 'Closed Lost / Oferta Dispensada'.

Passo C: Registro do Contrato Selecionado (Financial Account / Card)
Em vez de gravar 20 contratos legados que o cliente tem de uma só vez:

Grava-se no momento da seleção apenas o contrato/cartão trabalhado, garantindo que o Case (Protocolo) nasça diretamente amarrado àquele contrato:

FinServ__FinancialAccount__c: Número da Conta/Contrato, Tipo, Saldo/Limite, Status.

FinServ__Card__c: Últimos 4 dígitos, Bandeira, Status (Ativo/Cancelado), Portador.

Case.FinServ__FinancialAccount__c = selectedFinAccountId;

🌟 Benefícios dessa Abordagem para a Porto Bank
Visão 360° Sempre Alimentada: Os dados cadastrais e o contrato em foco ficam registrados nos objetos nativos do FSC. Quando qualquer operador abrir a aba do cliente no futuro, o painel padrão do FSC carregará tudo instantaneamente via SOQL nativo.

Latência Mínima para o Operador: Como o upsert demográfico e o registro de NBO ocorrem via Queueable Apex, a interface do usuário responde na velocidade da rede sem aguardar commits de banco de dados.

Total Governança contra Erros de Concorrência: O uso de chaves externas (External ID no CPF/CNPJ e número do Contrato) evita duplicações de registros causadas por buscas simultâneas do mesmo cliente.

Dessa forma, unimos o LWC desacoplado no front-end ao modelo de dados canônico do Financial Services Cloud com máxima eficiência e sem débitos técnicos!

Tanto para cliente pessoa física quanto jurídica, vamos seguir os objetos já disponíveis padrões do Financial Service Cloud, sem objeto customizado. Então, vamos, não vamos utilizar eh, persona account, vamos utilizar conta e contato. E para o EBO, vamos utilizar o objeto oportunidade.

Perfeito! Diretrizes de modelagem de dados ajustadas e devidamente registradas no nosso quadro de referência.

Vamos trabalhar estritamente com os objetos padrão nativos do FSC, respeitando a separação explícita entre Conta (Account) e Contato (Contact) para ambos os tipos de clientes (PF e PJ), e Oportunidade (Opportunity) para as ofertas do NBO.

📌 Quadro de Memória Progressivo (Atualizado & Consolidado)
Diretriz de Dados no FSC (Objetos Padrão):

Cliente PF e PJ: Modelo relacional padrão Account (Conta Individual ou Empresarial) + Contact (Contato associado). Sem adoção de Person Account. O CPF/CNPJ atua como chave unívoca de correlação (External ID).

Ofertas NBO: Mapeadas diretamente no objeto padrão Opportunity, vinculadas à Account e Contact.

Contratos Financeiros: Objetos financeiros nativos do FSC (FinServ__FinancialAccount__c e FinServ__Card__c para plásticos).

Arquitetura de Front-End:

Cockpit / Shell: LWC Modularizado desacoplado via Lightning Message Service (LMS).

Jornadas Transacionais Guiadas: OmniStudio (OmniScripts / FlexCards) para fluxos de negócio subsequentes.

Arquitetura de Back-End:

100% Apex em camadas de serviço corporativas (Service Layer / Apex Enterprise Patterns).

Persistência em background via Queueable Apex para manter latência zero na UI.

🏛️ Desenho de Modelagem de Dados & Relacionamentos
       +-------------------------+
       |         Account         |  (PF ou PJ - Tipo / External ID: CPF/CNPJ)
       +-------------------------+
                    │
         ┌──────────┴──────────┐
         │ 1:N                 │ 1:N
         ▼                     ▼
+-----------------+   +------------------+
|     Contact     |   |   Opportunity    |  (Ofertas NBO qualificadas/prospectadas)
+-----------------+   +------------------+
         │
         │ 1:N (ou via FinancialAccountRole)
         ▼
+-----------------------------------+
|    FinServ__FinancialAccount__c   |  (Conta Digital, Consórcio, Contrato Cartão)
+-----------------------------------+
                 │ 1:N
                 ▼
     +-----------------------+
     |   FinServ__Card__c    |  (Plásticos: Final, Bandeira, Status)
     +-----------------------+
🔄 Fluxo de Persistência Assíncrona dos Objetos Padrão
Para manter a tela do operador ultrarrápida (sem locks ou espera de DML síncrono):

Etapa 1 - Busca (CPF/CNPJ):

A API Cadastral retorna os dados demográficos.

O front-end exibe as informações imediatamente em memória.

O backend dispara um Queueable Apex desacoplado:

Realiza upsert na Account (usando o CPF/CNPJ como chave de correlação/External ID).

Realiza upsert no Contact filho com vínculo direto Contact.AccountId = Account.Id.

Etapa 2 - Oferta NBO:

A API de NBO identifica propensão de produto.

Cria/atualiza um registro de Opportunity:

AccountId = clientAccount.Id

ContactId = clientContact.Id

Name = "NBO - [Nome da Oferta]"

StageName = 'Prospecting' (ou 'Identificada')

CloseDate = System.today().addDays(30)

Se o operador acionar "Abordar Venda", o front-end avança a fase para 'In Progress'. Se a oferta for dispensada, move para 'Closed Lost'.

Etapa 3 - Seleção do Produto/Cartão:

O operador seleciona o produto motivador da chamada.

Registra/atualiza o contrato específico no FinServ__FinancialAccount__c (e FinServ__Card__c se for cartão) associando-o à Account do cliente e ao novo Case (Protocolo) gerado.

Esse fluxo garante que toda a visão 360° do cliente no Salesforce fique completa, 100% aderente aos objetos padrão do FSC e sem impactos na velocidade de atendimento do operador.

A mesma coisa vale para os produtos, então vamos utilizar o objeto asset para registrar ali todos os produtos que o cliente possuem para montar uma visão 360. Eu não entendi a respeito desse objeto chamado Fin Service. Poderia explicar?

Perfeito! Decisão registrada: manteremos o objeto padrão Asset para registrar e consolidar todos os produtos/contratos do cliente na visão 360°.

Sobre a sua dúvida a respeito do termo "FinServ":

O que significa "FinServ" e por que essa sigla existe?
Quando uma empresa adquire o Salesforce Financial Services Cloud (FSC), a Salesforce instala dentro da organização um pacote gerenciado oficial (Managed Package).

No Salesforce, todo pacote gerenciado tem um namespace (um prefixo exclusivo) para que os objetos e campos criados por ele não entrem em conflito com os objetos nativos da plataforma ou com customizações internas da sua empresa.

O namespace oficial da Salesforce para o Financial Services Cloud é FinServ.

Por isso, na documentação do FSC, você frequentemente vê nomes como:

FinServ__FinancialAccount__c: É o objeto fornecido pelo pacote do FSC para contas financeiras.

FinServ__Card__c: É o objeto fornecido pelo pacote do FSC para cartões físicos/virtuais.

FinServ__FinancialGoal__c: Metas financeiras.

Apesar de terminarem com __c (sufixo que o Salesforce usa para indicar componentes customizados/pacotes), eles vêm prontos de fábrica com as licenças do FSC.

A Escolha pelo Objeto Padrão Asset da Plataforma
Como a sua diretriz é não utilizar os objetos do pacote gerenciado FinServ e focar nos objetos padrão centrais da plataforma Salesforce (Asset, Account, Contact, Opportunity), a arquitetura fica ainda mais enxuta e universal:

Objeto Asset (Ativo da Plataforma):

É um objeto padrão do core do Salesforce (não depende de pacotes específicos).

Possui relacionamento nativo direto com AccountId e ContactId.

Campos padrão úteis: Name (Nome do Produto), SerialNumber / ContractNumber (Número da Conta ou Contrato), Status (Ativo, Cancelado, Bloqueado), InstallDate, etc.

Como fica a modelagem 100% padrão:

          +-------------------------+
          |         Account         | (PF ou PJ)
          +-------------------------+
                       │
        ┌──────────────┼──────────────┐
        │ 1:N          │ 1:N          │ 1:N
        ▼              ▼              ▼
+---------------+ +---------------+ +---------------+
|    Contact    | |  Opportunity  | |     Asset     |
| (Dados PF/PJ) | | (Ofertas NBO) | |  (Contratos / |
|               | |               | |   Cartões)    |
+---------------+ +---------------+ +---------------+
Cartões de Crédito no Asset: Cada cartão (ou contrato de cartão) pode ser registrado como um registro de Asset vinculado à AccountId e ao ContactId, contendo o status (Ativo/Cancelado) e os identificadores necessários.

Demais Produtos no Asset: Conta digital, consórcio e investimentos são representados da mesma forma via Asset, unificando a visão de produtos sob uma única tabela padrão do Salesforce.

Essa padronização simplifica a governança da org, facilita relatórios nativos e mantém os dados compatíveis com qualquer funcionalidade padrão de Service Cloud!

Ok, faltou alguma coisa ou podemos fechar a conversa sobre esta jornada?

cobrimos todos os pontos críticos necessários para fechar a especificação desta etapa com solidez:

Jornada Operacional e UX: Fluxo de busca, máscara dinâmica (CPF e CNPJ alfanumérico), priorização de NBO e seleção de produtos (com seletor específico para múltiplos cartões).

Arquitetura de Front-End: Microfrontends modulares em LWC puro conectados via Lightning Message Service (LMS), reservando OmniStudio para as esteiras transacionais subsequentes.

Arquitetura de Back-End: 100% Apex desacoplado (Service Layer / Enterprise Patterns), sem monolito e sem Integration Procedures.

Modelo de Dados 100% Padrão: Uso exclusivo dos objetos centrais da plataforma (Account, Contact, Opportunity para NBO e Asset para contratos/cartões).

Estratégia de Performance: Persistência desacoplada em background (Queueable Apex) para latência zero no TMA do operador.

Conforme combinamos no início da conversa, aqui está o Documento Consolidado de Referência Técnica e Funcional pronto para servir de base para o seu time de desenvolvimento e arquitetura.

📄 Documento de Referência: Jornada de Busca e Identificação de Cliente
1. Visão Geral & Objetivos de Negócio
Objetivo: Modernizar a experiência de atendimento a produtos financeiros do Porto Bank no Salesforce, substituindo o monólito legado por uma arquitetura desacoplada de alto desempenho.

Principais Ganhos: Redução do Tempo Médio de Atendimento (TMA), eliminação de gargalos transacionais em triggers de tela e incentivo ao cross-sell através da abordagem consultiva imediata de ofertas (NBO).

2. Decisões Arquiteturais Chave (ADRs)
Dimensão	Decisão Adotada	Racional
Front-End (Cockpit / Shell)	LWC Modular (Microfrontends) via LMS	Carregamento instantâneo, latência zero, independência de deploy e manutenção por componente.
Front-End (Transacional)	OmniStudio (OmniScripts / FlexCards)	Roteiros guiados rápidos para esteiras de serviço posteriores (ex.: contestação, cancelamento, alteração cadastral).
Back-End & Integrações	Apex First (Service Layer)	Sem uso de Integration Procedures (IPs). Orquestrações desacopladas em classes de serviço especializadas.
Modelo de Dados	Objetos Padrão do Core Salesforce	Uso estrito de Account, Contact, Opportunity e Asset (sem objetos customizados ou pacote gerenciado FinServ).
Persistência / Triggers	Processamento Assíncrono (Queueable)	A busca e navegação do operador ocorrem em memória na UI; atualizações de banco ocorrem em background sem bloquear a tela.
3. Modelo de Dados & Relacionamentos
          +----------------------------------------------+
          |                   Account                    |
          |  Chave Externa: DocumentNumber__c (CPF/CNPJ) |
          +----------------------------------------------+
                                  │
           ┌──────────────────────┼──────────────────────┐
           │ 1:N                  │ 1:N                  │ 1:N
           ▼                      ▼                      ▼
+---------------------+ +--------------------+ +---------------------+
|       Contact       | |    Opportunity     | |        Asset        |
|  Dados Cadastrais   | | Ofertas NBO        | | Contratos / Cartões |
|  e Demográficos     | | Qualificadas       | | Visão 360° Produtos |
+---------------------+ +--------------------+ +---------------------+
Account / Contact: Registram cliente PF ou PJ. DocumentNumber__c atua como chave unívoca de correlação (External ID).

Opportunity: Armazena ofertas recomendadas pelo motor de NBO vinculadas à conta (StageName: Identificada/Prospecting ou In Progress ao abordar).

Asset: Representa os contratos Porto Bank (Conta Digital, Consórcio, Investimentos e cada cartão/plástico individual com seu respectivo status: Ativo, Cancelado, Bloqueado).

4. Decomposição dos Microfrontends (LWC)
c-customer-search-bar:

Campo de busca com máscara automática para CPF (000.000.000-00), CNPJ numérico e CNPJ alfanumérico padrão BACEN.

Validação local prévia de comprimento/formato antes de acionar a busca.

Atalho de teclado: tecla Enter dispara a pesquisa.

Publica no canal LMS CustomerInteractionChannel__c: { document: '...', docType: '...' }.

c-nbo-banner:

Ouve o canal LMS e renderiza a oportunidade retornada pelo motor de NBO de forma não bloqueante.

Exibe resumo da oferta, benefício e botão prioritário "Abordar Venda" (iniciando o pré-atendimento comercial).

Oculta-se automaticamente caso não haja ofertas elegíveis.

c-customer-header-summary:

Painel horizontal compacto exibindo nome/razão social, tipo de pessoa, documento e segmento/faixa de relacionamento.

c-product-hub:

Grid de cartões de produtos ativos na Porto Bank (Cartão de Crédito, Conta Digital, Consórcio, Investimentos).

Suporte a extensibilidade: novos produtos são plugados via metadados sem alteração de código nos produtos existentes.

c-card-drawer:

Drawer lateral ou modal leve acionado quando o produto "Cartão de Crédito" é selecionado.

Lista todas as vias/plásticos associados (últimos 4 dígitos, bandeira, titular/adicional) com badges visuais de status (Verde: Ativo / Cinza: Cancelado).

Seleção em 1 clique do cartão motivador do atendimento.

5. Estratégia de Backend & Contratos de Integração
CustomerSearchService.cls:

Orquestra a chamada de dados cadastrais na API corporativa.

Expõe @AuraEnabled(cacheable=true) para o LWC.

Despacha Queueable Apex para sincronização idempotente de Account e Contact.

NboService.cls:

Consulta o motor de ofertas e despacha gravação/atualização assíncrona em Opportunity.

AssetSyncService.cls:

Atualiza o inventário de produtos e o cartão selecionado no objeto Asset sem travar a transação de abertura do atendimento (Case).

Com este desenho consolidado, a jornada de Busca e Identificação de Cliente está oficialmente concluída e pronta para ser levada para refinamento técnico e backlog de desenvolvimento.

vou abrir um novo chat para criar uma tela com visao 360 do cliente e usar recursos, objetos e tudo padrao do salesforce financial service cloud e os componentes transacionais que vc comentou usando omnistudio



poderia criar um prompt com base no que te explique sobre o projeto para eu iniciar o novo chat?

Copie e cole o prompt abaixo para iniciar a nova sessão:

Atue como Arquiteto de Soluções Especialista em Salesforce Financial Services Cloud (FSC) e OmniStudio.

Estou dando continuidade ao redesenho do sistema de atendimento a produtos financeiros do Porto Bank, migrando de uma aplicação legada monolítica de Service Cloud para uma arquitetura moderna, desacoplada e focada em performance e redução de TMA.

Contexto & Decisões Arquiteturais Já Tomadas
Front-End do Cockpit / Shell: Componentizado em LWC modular (Microfrontends) conectado via Lightning Message Service (LMS).

Jornadas Transacionais Guiadas: Serão implementadas utilizando OmniStudio (OmniScripts e FlexCards) integrados a Apex Controllers.

Back-End & Integrações: 100% em Apex desacoplado (Service Layer / Enterprise Patterns), sem Integration Procedures (IPs), com persistência em segundo plano via Queueable Apex.

Modelo de Dados FSC / Core Padrão: Uso exclusivo de objetos padrão:

Cliente (PF e PJ): Account + Contact vinculados (sem Person Account), usando CPF/CNPJ como chave de correlação (External ID).

Ofertas NBO: Opportunity.

Contratos e Produtos Bancários (Cartão, Conta Digital, Consórcio, Investimentos): Objeto padrão Asset.

Objetivo Deste Novo Chat
Quero desenhar e especificar a Tela de Visão 360° do Cliente e do Produto Selecionado dentro do Service Console, incluindo:

System Design & Layout do Console: Como estruturar a página de registro/workspace com sub-abas, destaques cadastrais, inventário de ativos (Asset), histórico de interações e painel de oportunidades NBO ativas.

Componentes Transacionais (OmniStudio): Definir o catálogo de jornadas transacionais guiadas em OmniScript (ex.: contestação de despesa, alteração de limites, bloqueio/desbloqueio de cartão, cancelamento e segunda via) acionadas a partir da visão 360°.

Integração OmniScript + Apex: Padrão arquitetural de comunicação dos OmniScripts com os serviços Apex de integração para disparar as ações nos sistemas legados do banco.

Por favor, faça perguntas de direcionamento para entender as regras de negócio dessa visão 360° e sugira a melhor distribuição de componentes (SLDS, FlexCards e OmniScripts) para a tela do operador.