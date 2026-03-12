# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Pessegram
  class GoiabookClient
    class Error < StandardError; end

    def initialize(url, token)
      @url = URI(url)
      @token = token
    end

    def post_bookmark(url)
      request = Net::HTTP::Post.new(@url)
      request["Content-Type"] = "application/json"
      request["X-Api-Token"] = @token
      request.body = { url: url }.to_json

      response = Net::HTTP.start(@url.hostname, @url.port, use_ssl: @url.scheme == 'https') do |http|
        http.request(request)
      end

      case response.code
      when "201", "200"
        JSON.parse(response.body.force_encoding('UTF-8'))
      else
        handle_api_error(response)
      end
    rescue Error => e
      raise e
    rescue StandardError => e
      raise Error, e.message.force_encoding('UTF-8')
    end

    private

    def handle_api_error(response)
      body = response.body.force_encoding('UTF-8')
      begin
        data = JSON.parse(body)
        message = data['message'] || data['error'] || data['errors']&.join(', ') || body
        raise Error, "GoiabookLM diz: #{message}"
      rescue JSON::ParserError
        raise Error, "GoiabookLM deu erro #{response.code}: #{body}"
      end
    end
  end
end
