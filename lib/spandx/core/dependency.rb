# frozen_string_literal: true

module Spandx
  module Core
    class Dependency
      GATEWAYS = {
        rubygems: ::Spandx::Ruby::Gateway,
        nuget: ::Spandx::Dotnet::NugetGateway,
        maven: ::Spandx::Java::Gateway,
      }.freeze

      attr_reader :package_manager, :name, :version, :meta

      def initialize(package_manager:, name:, version:, meta: {})
        @package_manager = package_manager
        @name = name
        @version = version
        @meta = meta
      end

      def licenses(catalogue: Spdx::Catalogue.from_git)
        Spdx::GatewayAdapter
          .new(catalogue: catalogue, gateway: CompositeGateway.new(cache_for(package_manager), gateway_for(package_manager)))
          .licenses_for(name, version)
      end

      def <=>(other)
        [name, version] <=> [other.name, other.version]
      end

      def hash
        [name, version].hash
      end

      def eql?(other)
        name == other.name && version == other.version
      end

      def to_a
        [name, version, licenses.map(&:id)]
      end

      def to_h
        { name: name, version: version, licenses: licenses.map(&:id) }
      end

      private

      def gateway_for(package_manager)
        case package_manager
        when :yarn, :npm
          js_gateway
        when :pypi
          python_gateway
        else
          GATEWAYS[package_manager].new
        end
      end

      def cache_for(package_manager)
        Cache.new(package_manager, url: package_manager == :rubygems ? 'https://github.com/mokhan/spandx-rubygems.git' : 'https://github.com/mokhan/spandx-index.git')
      end

      def js_gateway
        if meta['resolved']
          uri = URI.parse(meta['resolved'])
          return Spandx::Js::YarnPkg.new(source: "#{uri.scheme}://#{uri.host}:#{uri.port}")
        end

        Spandx::Js::YarnPkg.new
      end

      def python_gateway
        meta.empty? ? ::Spandx::Python::Pypi.new : ::Spandx::Python::Pypi.new(sources: ::Spandx::Python::Source.sources_from(meta))
      end
    end
  end
end
