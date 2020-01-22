# frozen_string_literal: true

require 'spandx/parsers/base'
require 'spandx/parsers/gemfile_lock'
require 'spandx/parsers/packages_config'
require 'spandx/parsers/pipfile_lock'

module Spandx
  module Parsers
    UNKNOWN = Class.new do
      def self.parse(*_args)
        []
      end
    end

    class << self
      def for(path, catalogue: Spandx::Catalogue.latest)
        result = ::Spandx::Parsers::Base.find do |x|
          x.matches?(File.basename(path))
        end

        result&.new(catalogue: catalogue) || UNKNOWN
      end
    end
  end
end
