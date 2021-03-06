# frozen_string_literal: true

module Spandx
  module Core
    class Guess
      attr_reader :catalogue

      def initialize(catalogue)
        @catalogue = catalogue
      end

      def license_for(raw)
        case raw
        when Hash
          from_hash(raw)
        when Array
          from_array(raw)
        else
          from_string(raw)
        end
      end

      private

      def from_hash(hash)
        from_string(hash[:name]) ||
          from_url(hash[:url]) ||
          unknown(hash[:name] || hash[:url])
      end

      def from_array(array)
        from_string(array.join(' AND '))
      end

      def from_string(raw)
        return if raw.nil?

        content = Content.new(raw)

        catalogue[raw] ||
          catalogue[raw.split(' ').join('-')] ||
          match_name(content) ||
          match_body(content) ||
          unknown(raw)
      end

      def from_url(url)
        return if url.nil? || url.empty?

        response = Spandx.http.get(url)
        return unless Spandx.http.ok?(response)

        license_for(response.body)
      end

      def match_name(content)
        return if content.tokens.size < 2 || content.tokens.size > 10

        result = from_expression(content)
        return result if result

        threshold = 85.0
        catalogue.find do |license|
          content.similar?(Content.new(license.name), threshold: threshold)
        end
      end

      def match_body(content)
        score = Score.new(nil, nil)
        threshold = 89.0
        catalogue.each do |license|
          next if license.deprecated_license_id?

          percentage = content.similarity_score(content_for(license))
          next if percentage < threshold
          next if score.score >= percentage

          score.update(percentage, license)
        end
        score&.item
      end

      def content_for(license)
        ::Spandx::Core::Content.new(Spandx.git[:spdx].read("text/#{license.id}.txt") || '')
      end

      def unknown(text)
        ::Spandx::Spdx::License.unknown(text)
      end

      def from_expression(content)
        Spandx::Spdx::CompositeLicense
          .from_expression(content.raw, catalogue)
      end
    end
  end
end
