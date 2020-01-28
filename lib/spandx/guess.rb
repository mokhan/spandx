# frozen_string_literal: true

module Spandx
  class Guess
    class Score
      include Comparable

      attr_reader :score, :item

      def initialize(score, item)
        @score = score
        @item = item
      end

      def <=>(other)
        score <=> other.score
      end

      def to_s
        "#{score}: #{item}"
      end
    end

    attr_reader :catalogue

    def initialize(catalogue)
      @catalogue = catalogue
    end

    def license_for(raw_content, algorithm: :dice_coefficient)
      content = Content.new(raw_content)
      score = nil

      if algorithm == :dice_coefficient
        catalogue.each do |license|
          next if license.deprecated_license_id?

          score = dice(content, license, score)
        end
      elsif algorithm == :levenshtein
        catalogue.each do |license|
          next if license.deprecated_license_id?

          score = levenshtein(content, license, score)
        end
      end
      score ? score.item.id : nil
    end

    private

    def levenshtein(target, other, score)
      percentage = target.similarity_score(other.content, algorithm: :levenshtein)
      if (score.nil? || percentage < score.score)
        return Score.new(percentage, other)
      end
      score
    end

    def dice(target, other, score)
      percentage = target.similarity_score(other.content, algorithm: :dice_coefficient)
      if (percentage > 89.0) && (score.nil? || percentage > score.score)
        return Score.new(percentage, other)
      end
      score
    end
  end
end
