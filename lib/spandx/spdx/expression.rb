# frozen_string_literal: true

module Spandx
  module Spdx
    class Expression < Parslet::Parser
      # https://spdx.org/spdx-specification-21-web-version
      #
      # idstring              = 1*(ALPHA / DIGIT / "-" / "." )
      # license-id            = <short form license identifier in Appendix I.1>
      # license-exception-id  = <short form license exception identifier in Appendix I.2>
      # license-ref           = ["DocumentRef-"1*(idstring)":"]"LicenseRef-"1*(idstring)
      # simple-expression = license-id / license-id"+" / license-ref
      # compound-expression =  1*1(simple-expression /
      #                             simple-expression "WITH" license-exception-id /
      #                             compound-expression "AND" compound-expression /
      #                             compound-expression "OR" compound-expression ) /
      #                           "(" compound-expression ")" )
      #
      # license-expression =  1*1(simple-expression / compound-expression)
      rule(:lparen) { str('(') }
      rule(:rparen) { str(')') }
      rule(:digit) { match('\d') }
      rule(:space) { match('\s') }
      rule(:alpha) { match['a-zA-Z'] }
      rule(:colon) { str(':') }
      rule(:dot) { str('.') }
      rule(:plus) { str('+') }
      rule(:hyphen) { str('-') }
      rule(:with_op) { str('with') | str('WITH') }
      rule(:and_op) { str('AND') | str('and') }
      rule(:or_op) { str('OR') | str('or') }

      # idstring              = 1*(ALPHA / DIGIT / "-" / "." )
      rule(:id_character) { alpha | digit | hyphen | dot }
      rule(:id_string) { id_character.repeat(1) }

      # license-id = <short form license identifier in Appendix I.1>
      rule(:license_id) do
        id_string
      end

      # license-ref = ["DocumentRef-"1*(idstring)":"]"LicenseRef-"1*(idstring)
      rule(:license_ref) do
        str('DocumentRef-') >> id_string >> colon >> str('LicenseRef-') >> id_string
      end

      # simple-expression = license-id / license-id"+" / license-ref
      rule(:simple_expression) do
        license_id >> plus.maybe | license_ref
      end

      # license-exception-id = <short form license exception identifier in Appendix I.2>
      rule(:license_exception_id) do
        # TODO: : Update to match exceptions list
        str('389-exception')
      end

      # simple-expression "WITH" license-exception-id
      rule(:with_expression) do
        simple_expression.as(:left) >> space >> with_op.as(:operator) >> space >> license_exception_id.as(:right)
      end

      # compound-expression "AND" compound-expression
      rule(:and_expression) do
        # compound_expression >> space >> and_op >> space >> compound_expression
        simple_expression.as(:left) >> space >> and_op.as(:operator) >> space >> simple_expression.as(:right)
      end

      # compound-expression "OR" compound-expression
      rule(:or_expression) do
        # compound_expression >> space >> or_op >> space >> compound_expression
        simple_expression.as(:left) >> space >> or_op.as(:operator) >> space >> simple_expression.as(:right)
      end

      #  compound-expression =  1*1(
      #    simple-expression /
      #    simple-expression "WITH" license-exception-id /
      #    compound-expression "AND" compound-expression /
      #    compound-expression "OR" compound-expression ) /
      #    "(" compound-expression ")"
      #  )
      rule(:compound_expression) do
        lparen.maybe >> (
          # simple_expression.repeat(1, 1) |
          with_expression.repeat(1, 1) |
          and_expression.repeat(1, 1) |
          or_expression.repeat(1, 1)
        ) >> rparen.maybe
      end

      # license-expression =  1*1(simple-expression / compound-expression)
      rule(:license_expression) do
        simple_expression.repeat(1, 1).as(:left) | compound_expression.repeat(1, 1)
      end

      root(:license_expression)
    end
  end
end