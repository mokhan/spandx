# frozen_string_literal: true

module Spandx
  module Cli
    module Commands
      class Index
        class Update < Spandx::Cli::Command
          def initialize(options)
            @options = options
          end

          def execute(output: $stdout)
            [
              'rubygems'
            ].each do |package_manager|
              Spandx::Core::Database
                .new(url: "https://github.com/mokhan/spandx-#{package_manager}.git")
                .update!
            end
            output.puts 'OK'
          end
        end
      end
    end
  end
end