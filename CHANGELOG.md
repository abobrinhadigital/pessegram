# Changelog

Todas as mudanças notáveis no projeto **Pessegram** serão documentadas neste arquivo.

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
