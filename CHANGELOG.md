# Changelog

Todas as mudanças notáveis no projeto **Pessegram** serão documentadas neste arquivo.

## [4.0.0] - 2026-03-22

### Adicionado
- **Arquitetura Multi-Bot**: Pessegram agora opera como um roteador central (API Router) com 3 bots especializados: Chatbot, GoiabookLM e Mangofier.
- **API Router (Puma)**: Servidor web que roteia requisições para os bots correspondentes via endpoints `/bot/chatbot`, `/bot/goiabooklm`, `/bot/mangofier`.
- **Cloudflare Tunnel**: Integração completa com túneis Cloudflare para exposição segura dos serviços via webhooks.
- **Webhooks do Telegram**: Configuração automática de webhooks para cada bot, permitindo processamento concorrente.
- **Sistema de Notificação**: PessegramService notifica o Telegram com resumos processados pelos bots.
- **Tratamento de Erros Aprimorado**: Logs detalhados e respostas amigáveis para falhas de processamento.
- **Configuração de Ambiente**: Variáveis de ambiente específicas para cada bot (tokens, URLs, IDs).
- **Documentação de Deploy**: Scripts de instalação como serviço systemd (`install_service.sh`).
- **Persistência de Dados**: Uso de bancos SQLite separados para cada bot e fila de jobs.

### Modificado
- **Estrutura do Projeto**: Reorganização em diretórios `bots/` com implementações especializadas.
- **Fluxo de Processamento**: URLs são enviadas diretamente para os bots respectivos, eliminando dependência do bot principal.
- **Configuração de Banco**: Multi-database com bancos separados para cada serviço (cache, queue, cable).
- **Logs e Debug**: Saída de logs melhorada para monitoramento em produção.

### Removido
- **Bot Monolítico**: Substituído por arquitetura modular multi-bot.
- **Dependência do GoiabookLM via Bot Principal**: Comunicação direta via API.

## [3.1.0] - 2026-03-14

### Adicionado
- **Integração Mangofier Service**: Triagem inteligente de links. Respostas a mensagens do bot que contêm "MU:" agora são encaminhadas para o `mangofier_service` em vez do GoiabookLM.
- **MangofierClient**: Novo cliente HTTP para comunicação com o serviço de mangás.
- **Fluxo Silencioso**: Removida a confirmação de encaminhamento para o Mangofier, permitindo que o serviço de destino gerencie o feedback ao usuário.

## [3.0.0] - 2026-03-14

### Adicionado
- **ApiListener (O Ouvido Digital)**: Implementação de um servidor WEBrick interno que permite ao Pessegram receber mensagens via POST de sistemas externos.
- **Integração de Mensageria Passiva**: O bot agora pode ecoar avisos de outros scripts diretamente para o mestre.
- **Dependência `webrick`**: Adicionada ao Gemfile para suportar o novo listener.

## [2.2.6] - 2026-03-12

### Adicionado
- **Lei do Silêncio para Links**: O Gemini não é mais acionado em nenhuma mensagem que contenha URL, garantindo privacidade e economia de tokens.
- **Detecção de Link Universal**: URLs são detectadas em qualquer posição da mensagem, ignorando metadados automáticos de encaminhamento.
- **Estabilização de Encoding**: Correção definitiva do erro `incompatible character encodings: UTF-8 and BINARY` na comunicação com Gemini e GoiabookLM.
- **Tratamento de Erro Inteligente**: Mensagens de erro da GoiabookLM agora são parseadas e exibidas de forma amigável e sem redundância.

## [2.1.0] - 2026-03-12

### Adicionado
- **Estabilização de Encoding**: Resolvido o erro `incompatible character encodings: UTF-8 and BINARY` forçando UTF-8 em todos os pontos de manipulação de string.
- **Auto-Leave de Grupos**: O bot agora sai automaticamente de qualquer grupo para o qual for convidado, mantendo a exclusividade da conversa com o mestre.
- **Silêncio Seletivo**: Removida a resposta de erro para usuários não autorizados (ignora completamente).

## [2.0.0] - 2026-03-12

### Adicionado
- **Memória de Curto Prazo**: Implementada a funcionalidade de "sliding window" para as últimas 10 mensagens (5 usuários + 5 modelo), permitindo conversas com contexto.
- **Comando `/start` resetável**: Agora o `/start` limpa o histórico de memória para iniciar um novo contexto.

## [1.0.0] - 2026-03-12

### Adicionado
- **Base do Projeto**: Estrutura modular em Ruby.
- **Integração Telegram**: Uso da gem `telegram-bot-ruby`.
- **Oráculo Gemini**: Cliente `Net::HTTP` para interação com a IA sem dependências extras.
- **GoiabookLM**: Detecção e salvamento automático de links enviados pelo mestre.
- **Porteiro Digital**: Sistema de controle de acesso via `MASTER_USER_ID`.
- **CLI com Thor**: Interface de linha de comando profissional em `bin/pessegram`.
- **Dinamismo de Persona**: Suporte a interpolação de variáveis (`%{master_id}`) no arquivo de persona.
- **Compatibilidade Ruby 3.4+**: Inclusão de gems padrão no Gemfile (`net-http`, `uri`, etc).
- **Documentação**: README inicial e este CHANGELOG.
