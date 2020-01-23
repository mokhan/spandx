# frozen_string_literal: true

module Spandx
  module Gateways
    # https://guides.rubygems.org/rubygems-org-api-v2/
    class Rubygems
      def initialize(http: Spandx.http)
        @http = http
      end

      def licenses_for(name, version)
        details_on(name, version).fetch('licenses', [])
      end

      private

      attr_reader :http

      def details_on(name, version)
        url = "https://rubygems.org/api/v2/rubygems/#{name}/versions/#{version}.json"
        response = http.get(url, default: {})
        http.ok?(response) ? parse(response.body) : {}
      end

      def parse(json)
        JSON.parse(json)
      end
    end
  end
end
