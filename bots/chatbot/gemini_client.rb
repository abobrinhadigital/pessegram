# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Pessegram
  module Chatbot
    class GeminiClient
      class Error < StandardError; end

      def initialize(api_key, system_prompt, model_name = 'gemini-2.5-flash-lite')
        @api_key = api_key
        @system_prompt = system_prompt
        @model_name = model_name.to_s.gsub(%r{\Amodels/}, '')
      end

      def generate_response(prompt, history: [])
        puts "[Gemini] Gerando resposta para: #{prompt[0..30]}..."
        uri = URI("https://generativelanguage.googleapis.com/v1beta/models/#{@model_name}:generateContent?key=#{@api_key}")

        request_body = build_payload(prompt, history)

        response = Net::HTTP.post(uri, request_body, 'Content-Type' => 'application/json')

        case response.code
        when '200'
          handle_response(response)
        when '429'
          'Calma lá, mestre! O Oráculo (Gemini) está de ressaca e pediu um tempo (Erro 429).'
        when '401'
          'Erro de credenciais (401). Verifique o .env, mestre.'
        else
          "O Oráculo soltou um enigma indecifrável (Erro #{response.code})."
        end
      rescue StandardError => e
        "Colapso no sistema: #{e.message}."
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
        texto = resultado.dig('candidates', 0, 'content', 'parts', 0, 'text')
        texto || 'Hmm... Deu branco. O Gemini não retornou texto.'
      rescue StandardError
        'O Oráculo se perdeu nas próprias palavras (Erro ao processar JSON).'
      end
    end
  end
end
