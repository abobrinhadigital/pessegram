# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Pessegram
  class GeminiClient
    class Error < StandardError; end

    def initialize(api_key, system_prompt, model_name = 'gemini-2.0-flash')
      @api_key = api_key
      @system_prompt = system_prompt
      @model_name = model_name.to_s.gsub(/\Amodels\//, '')
    end

    def generate_response(prompt, history: [])
      uri = URI("https://generativelanguage.googleapis.com/v1beta/models/#{@model_name}:generateContent?key=#{@api_key}")
      
      request_body = build_payload(prompt, history)

      response = Net::HTTP.post(uri, request_body, "Content-Type" => "application/json")
      puts "[Gemini] Resposta recebida: #{response.code}"
      
      case response.code
      when "200"
        handle_response(response)
      when "429"
        "Calma lá, mestre! O Oráculo (Gemini) está de ressaca e pediu um tempo (Erro 429). Espere um minuto para eu recuperar o fôlego."
      when "401"
        "Erro de credenciais (401). Parece que a chave do Oráculo expirou ou é falsa. Verifique o .env, mestre."
      when "400"
        "O Oráculo não entendeu o que eu disse (Erro 400). Talvez o histórico esteja confuso ou o prompt esteja corrompido."
      when "500", "503"
        "Os servidores do Google estão em chamas (Erro #{response.code}). O Oráculo caiu do Olimpo. Tente mais tarde."
      else
        "O Oráculo soltou um enigma indecifrável (Erro #{response.code}). Mais um mistério para a nossa curadoria do erro."
      end
    rescue StandardError => e
      "Colapso no sistema: #{e.message}. Mais um bug pra nossa coleção."
    end

    def list_models
      uri = URI("https://generativelanguage.googleapis.com/v1beta/models?key=#{@api_key}")
      response = Net::HTTP.get_response(uri)
      
      if response.code == "200"
        JSON.parse(response.body)
      else
        raise Error, "Erro ao listar modelos: #{response.code} - #{response.body}"
      end
    rescue StandardError => e
      raise Error, "Falha na comunicação com o Oráculo: #{e.message}"
    end

    private

    def build_payload(prompt, history)
      contents = history.dup
      contents << { role: 'user', parts: [{ text: prompt }] }

      {
        system_instruction: {
          parts: { text: @system_prompt }
        },
        contents: contents
      }.to_json.force_encoding('UTF-8')
    end

    def handle_response(response)
      resultado = JSON.parse(response.body)
      texto = resultado.dig("candidates", 0, "content", "parts", 0, "text")
      texto || "Hmm... Deu branco. O Gemini não retornou texto."
    rescue StandardError
      "O Oráculo se perdeu nas próprias palavras (Erro ao processar JSON)."
    end
  end
end
