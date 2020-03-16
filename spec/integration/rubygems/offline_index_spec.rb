# frozen_string_literal: true

RSpec.describe Spandx::Rubygems::OfflineIndex do
  subject { described_class.new(:rubygems) }

  describe '#licenses_for' do
    (0x00..0xFF).map { |x| x.to_s(16).upcase.rjust(2, '0').downcase }.each do |hex|
      context hex do
        let(:path) { subject.db.expand_path(".index/#{hex}/rubygems") }

        it 'is able to find all packages in the index' do
          CSV.readlines(path).shuffle.each do |row|
            results = subject.licenses_for(name: row[0], version: row[1])
            expect(results).to match_array(row[2].split('-|-'))
          end
        end
      end
    end

    it 'returns an empty list of unknown packages' do
      expect(subject.licenses_for(name: 'x', version: 'x')).to be_empty
    end
  end
end
