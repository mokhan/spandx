# frozen_string_literal: true

require 'forwardable'
require 'json'
require 'net/hippie'

require 'spandx/catalogue'
require 'spandx/gateways/http'
require 'spandx/gateways/spdx'
require 'spandx/gateways/pypi'
require 'spandx/license'
require 'spandx/parsers'
require 'spandx/version'

module Spandx
  class Error < StandardError; end

  class << self
    def root
      Pathname.new(File.dirname(__FILE__)).join('../..')
    end

    def http
      @http ||= Spandx::Gateways::Http.new
    end
  end
end
