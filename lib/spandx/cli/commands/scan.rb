# frozen_string_literal: true

module Spandx
  module Cli
    module Commands
      class Scan
        attr_reader :scan_path, :spinner

        def initialize(scan_path, options)
          @scan_path = ::Pathname.new(scan_path)
          @options = options
          @spinner = options[:show_progress] ? ::Spandx::Core::Spinner.new : ::Spandx::Core::Spinner::NULL
          require(options[:require]) if options[:require]
        end

        def execute(output: $stdout)
          report = ::Spandx::Core::Report.new
          each_file do |file|
            spinner.spin(file)
            each_dependency_from(file) do |dependency|
              spinner.spin(file)
              report.add(dependency)
            end
          end
          spinner.stop
          output.puts(format(report.to(@options[:format])))
        end

        private

        def each_file
          Spandx::Core::PathTraversal
            .new(scan_path, recursive: @options['recursive'])
            .each { |file| yield file }
        end

        def each_dependency_from(file)
          ::Spandx::Core::Parser
            .for(file)
            .parse(file)
            .map { |x| enhance(x) }
            .each { |dependency| yield dependency }
        end

        def format(output)
          Array(output).map(&:to_s)
        end

        def enhance(dependency)
          ::Spandx::Core::Plugin
            .all
            .inject(dependency) { |memo, plugin| plugin.enhance(memo) }
        end
      end
    end
  end
end
