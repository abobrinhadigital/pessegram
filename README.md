# Pessegram

O **Pessegram** é o sucessor espiritual e técnico do Damascord, um bot modular para Telegram focado em registrar o caos, gerenciar links e habitar a "preguiça produtiva" do Mestre. Construído em Ruby puro, ele é o biógrafo oficial do azar de Murphy.

## Funcionalidades v1.0

### 1. Diálogos Ácidos (Gemini AI)
- **Integração Nativa**: Comunicação direta com a API do Gemini via `Net::HTTP`, sem gems de IA pesadas.
- **Identidade Dinâmica**: Persona configurável via `data/ai_persona.md` com suporte a interpolação dinâmica de variáveis.
- **Sarcasmo de Precisão**: Respostas curtas, diretas e devidamente amargas.

### 2. Controle de Acesso de Elite
- **Master ID Lockdown**: O bot só obedece ao Mestre Marcelo (ID configurado no `.env`).
- **Middleware de Segurança**: Qualquer outro usuário que tente interagir receberá um erro sarcástico e será ignorado.

### 3. Integração GoiabookLM
- **Salvamento Automático**: Qualquer link enviado pelo mestre é instantaneamente cadastrado no GoiabookLM.
- **Protocolo de Rede**: Uso de `Net::HTTP` para garantir paridade técnica com o ecossistema Abobrinha Digital.

### 4. Interface CLI Profissional
- **Thor Powered**: Execução simplificada via `bin/pessegram`.
- **Dinamismo**: Carregamento automático de ambiente e dependências.

## Configuração e Instalação

### Requisitos
- Ruby 3.4.8+
- Bundler

### Configuração Inicial
1. Clone o repositório.
2. Copie o arquivo `.env.example` para `.env` e preencha as chaves:
   - `TELEGRAM_BOT_TOKEN`: Obtido via @BotFather.
   - `GEMINI_API_KEY`: Chave da API do Google Gemini.
   - `MASTER_USER_ID`: Seu ID do Telegram (use @userinfobot para descobrir).
   - `GOIABOOK_URL` e `GOIABOOK_TOKEN`: Credenciais da Goiaba.

### Execução
- `bundle install` para instalar as dependências (incluindo fix de Ruby 3.4+).
- `./bin/pessegram start` para iniciar o serviço.

## Estrutura do Projeto
- `bin/`: CLI e executáveis (Thor).
- `lib/`: Implementação modular (Gemini, AccessControl, Goiabook).
- `data/`: Persona e dados ignorados pelo git.

---
Desenvolvido no caos para o ecossistema [Abobrinha Digital](https://abobrinhadigital.github.io/).
