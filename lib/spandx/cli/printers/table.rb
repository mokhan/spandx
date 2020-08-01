# frozen_string_literal: true

module Spandx
  module Cli
    module Printers
      class Table < Printer
        HEADINGS = ['Name', 'Version', 'Licenses', 'Location'].freeze

        def initialize
          @spinner = TTY::Spinner.new(output: $stderr)
        end

        def match?(format)
          format.to_sym == :table
        end

        def print_header(_io)
          @dependencies = SortedSet.new
          @spinner.auto_spin
        end

        def print_line(dependency, _io)
          @dependencies << dependency
        end

        def print_footer(io)
          @spinner.stop
          io.puts(to_table(@dependencies.map(&:to_a)))
        end

        private

        def to_table(rows)
          Terminal::Table.new(headings: HEADINGS) do |table|
            rows.each { |row| table.add_row(row) }
          end
        end
      end
    end
  end
end