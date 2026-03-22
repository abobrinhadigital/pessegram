# Pessegram v4.0.0 - Arquitetura Multi-Bot

O **Pessegram** é o sucessor espiritual e técnico do Damascord, um sistema multi-bot para Telegram focado em registrar o caos, gerenciar links e habitar a "preguiça produtiva" do Mestre. Construído em Ruby, ele é o biógrafo oficial do azar de Murphy.

## 🚀 Novidades na v4.0.0

### Arquitetura Multi-Bot
- **API Router (Puma)**: Roteador central que distribui requisições para 3 bots especializados
- **Chatbot**: Bot principal para diálogos com Gemini AI
- **GoiabookLM**: Bot especializado em processamento e sumarização de URLs
- **Mangofier**: Bot especializado em mapeamento de mangás

### Cloudflare Tunnel
- Integração nativa com túneis Cloudflare para exposição segura
- Suporte a múltiplos subdomínios (`pessegram.mogami.dev.br`, etc.)
- Configuração automática de webhooks

### Processamento em Background
- **Solid Queue**: Sistema de filas para processamento assíncrono
- **Bancos de Dados Separados**: SQLite para cada serviço (cache, queue, cable)
- **Notificação Automática**: Resumos são enviados ao Telegram automaticamente

## 🤖 Bots Disponíveis

### 1. Chatbot (`/bot/chatbot`)
- **Modelo**: Gemini AI (gemini-2.5-flash)
- **Função**: Diálogos ácidos e respostas contextuais
- **Comandos**: `/start`, conversas normais
- **Persona**: Configurável via `data/ai_persona.md`

### 2. GoiabookLM (`/bot/goiabooklm`)
- **Função**: Processamento de URLs e geração de resumos
- **Integração**: API GoiabookLM para sumarização
- **Fluxo**: URL → Processamento → Resumo → Notificação

### 3. Mangofier (`/bot/mangofier`)
- **Função**: Mapeamento de URLs do MangaUpdates
- **Integração**: API Mangofier para busca de correspondências
- **Comando**: `/mapear <url>` ou resposta a mensagens com "MU:"

## 📁 Estrutura do Projeto

```
pessegram/
├── bin/
│   └── pessegram          # Executável principal
├── bots/
│   ├── chatbot/           # Implementação do chatbot
│   ├── goiabooklm/        # Implementação do bot de URLs
│   └── mangofier/         # Implementação do bot de mangás
├── config/
│   ├── tunnel.yml.example # Configuração do Cloudflare Tunnel
│   └── ...
├── lib/
│   └── pessegram/
│       ├── api_router.rb  # Roteador API (Puma)
│       ├── bots.rb        # Registro dos bots
│       ├── ...
├── data/                  # Persona e dados locais
├── CHANGELOG.md           # Histórico de mudanças
└── README.md              # Este arquivo
```

## ⚙️ Configuração

### Requisitos
- Ruby 3.4.8+
- Bundler
- Cloudflare Tunnel (para exposição pública)

### Variáveis de Ambiente (.env)
```bash
# Bot Tokens
TELEGRAM_BOT_TOKEN=           # Token do bot principal (Chatbot)
GOIABOOK_BOT_TOKEN=           # Token do GoiabookLM
MANGOFIER_BOT_TOKEN=          # Token do Mangofier

# APIs
GEMINI_API_KEY=               # Chave da API Google Gemini
GOIABOOK_API_TOKEN=           # Token para API GoiabookLM
SCRAPE_DO_API_TOKEN=          # Token para Scrape.do (opcional)

# Configurações
MASTER_USER_ID=               # ID do usuário mestre
PESSEGRAM_API_TOKEN=          # Token para autenticação interna
PESSEGRAM_CHAT_ID=            # ID do chat para notificações
```

## 🚀 Instalação e Execução

### Local
```bash
bundle install
./bin/pessegram start
```

### Produção (Systemd)
```bash
# Instalar como serviço
./script/install_service.sh

# Atualizar
./update.sh
```

### Cloudflare Tunnel
```bash
# Configuração automática (já incluída)
# Os tunnels são configurados via variáveis de ambiente
```

## 🔧 Configuração dos Webhooks

Os webhooks são configurados automaticamente quando os bots são iniciados com a URL do túnel configurada.

## 📊 Monitoramento

- **Logs**: Saída detalhada para debug
- **Status dos Bots**: Cada bot reporta seu status
- **Webhook Info**: Informações dos webhooks no Telegram

## 🛡️ Segurança

- Controle de acesso por `MASTER_USER_ID`
- Autenticação de API com tokens
- Validação de webhooks
- Logs de auditoria

---

Desenvolvido no caos para o ecossistema [Abobrinha Digital](https://abobrinhadigital.github.io/).