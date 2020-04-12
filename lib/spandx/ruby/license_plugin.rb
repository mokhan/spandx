# frozen_string_literal: true

module Spandx
  module Ruby
    class LicensePlugin < Spandx::Core::Plugin
      def initialize(catalogue: Spdx::Catalogue.from_git)
        @catalogue = catalogue
      end

      def enhance(dependency)
        return dependency unless dependency.managed_by?(:rubygems)

        licenses_for(dependency).each do |license|
          dependency.licenses << license
        end
        dependency
      end

      private

      attr_reader :catalogue

      def licenses_for(dependency)
        @adapter ||= Spdx::GatewayAdapter.new(catalogue: catalogue, gateway: gateway)
        @adapter.licenses_for(dependency.name, dependency.version)
      end

      def gateway
        @gateway ||=
          ::Spandx::Core::CompositeGateway.new(
            ::Spandx::Core::Cache.new(:rubygems, url: 'https://github.com/mokhan/spandx-rubygems.git'),
            ::Spandx::Ruby::Gateway.new
          )
      end
    end
  end
end
