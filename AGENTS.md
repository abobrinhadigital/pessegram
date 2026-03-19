# AGENTS.md

## Build & Run Commands

```bash
# Install dependencies
bundle install

# Run the bot
./bin/pessegram start

# List available Gemini models
./bin/pessegram list-models

# Check for syntax errors (no formal linter configured)
ruby -c lib/pessegram/*.rb bin/pessegram
```

**Testing**: No test framework is currently configured. To add tests, consider adding `rspec` or `minitest` to the Gemfile and creating a `spec/` or `test/` directory.

**Linting**: No RuboCop or other linter is configured. Run `ruby -c` for syntax checking only.

## Code Style Guidelines

### General
- Always include `# frozen_string_literal: true` as the first line in every Ruby file.
- Use UTF-8 encoding for all files.
- Keep files focused: one primary class/module per file.

### Naming Conventions
- **Modules/Classes**: PascalCase (`Pessegram::GeminiClient`, `AccessControl`)
- **Methods/Variables**: snake_case (`generate_response`, `build_payload`)
- **Constants**: SCREAMING_SNAKE_CASE (`VERSION`)
- **Files**: snake_case matching the class name (`gemini_client.rb` for `GeminiClient`)

### Imports (Requires)
- Group requires in order: stdlib gems, third-party gems, then local requires.
- Use `require_relative` for local files within the project.
- Use `require` for gems.
- Example:
  ```ruby
  require 'net/http'
  require 'uri'
  require 'json'
  require_relative 'gemini_client'
  ```

### Error Handling
- Define custom error classes inside their parent module, inheriting from `StandardError`:
  ```ruby
  class GeminiClient
    class Error < StandardError; end
  end
  ```
- Use `rescue StandardError => e` for broad catch, then handle specific errors when needed.
- Prefer logging with `puts` for this bot context (no formal logger configured).

### Module Structure
- All classes live under the `Pessegram` module.
- The main entry point is `lib/pessegram.rb` which requires all submodules.
- CLI commands use Thor (`lib/pessegram/cli.rb`).

### Strings & Encoding
- Use `.force_encoding('UTF-8')` when processing external text data.
- Prefer double-quoted strings for interpolation, single-quoted for static strings (flexible, no strict enforcement).

### Concurrency
- Background tasks use `Thread.new` (no thread pool or async gem).
- Ensure error handling inside threads to avoid silent failures.

### Environment
- Configuration via `.env` file using the `dotenv` gem.
- Never commit `.env` or secrets (see `.gitignore`).
- Access env vars with `ENV['KEY']`; validate presence before use.

### Comments
- Comments are in Portuguese (Brazilian), matching the project's language.
- Keep comments minimal; let code be self-documenting where possible.
