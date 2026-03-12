# frozen_string_literal: true

module Pessegram
  class Memory
    def initialize(max_size = 10)
      @max_size = max_size
      @history = []
    end

    def add(role, text)
      @history << { role: role, parts: [{ text: text }] }
      @history.shift if @history.size > @max_size
    end

    def get_history
      @history.dup
    end

    def clear
      @history = []
    end
  end
end
