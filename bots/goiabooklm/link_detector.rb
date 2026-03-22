# frozen_string_literal: true

module Pessegram
  module GoiabookLM
    class LinkDetector
      URL_REGEX = %r{https?://\S+}

      def extract(text)
        return nil unless text

        match = text.match(URL_REGEX)
        match ? match[0] : nil
      end

      def contains_url?(text)
        !extract(text).nil?
      end
    end
  end
end
