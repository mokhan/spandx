# frozen_string_literal: true

module Spandx
  module Core
    class Plugin
      class << self
        include Enumerable

        def each(&block)
          registry.each do |x|
            block.call(x)
          end
        end

        def inherited(subclass)
          registry.push(subclass)
        end

        def registry
          @registry ||= []
        end
      end
    end
  end
end