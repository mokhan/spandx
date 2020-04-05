# frozen_string_literal: true

RSpec.describe Spandx::Js::YarnPkg do
  subject { described_class.new(catalogue: catalogue) }

  let(:catalogue) { Spandx::Spdx::Catalogue.from_file(fixture_file('spdx/json/licenses.json')) }

  describe '#licenses_for' do
    context 'when fetch license data for a known package' do
      let(:result) do
        VCR.use_cassette('babel/6.23.0') do
          subject.licenses_for('babel', '6.23.0')
        end
      end

      specify { expect(result.map(&:id)).to match_array(['MIT']) }
    end

    context 'when the version does not exist' do
      let(:result) do
        VCR.use_cassette('babel/6.23.0') do
          subject.licenses_for('babel', 'invalid.23.0')
        end
      end

      specify { expect(result).to be_empty }
    end

    context 'when the name does not exist' do
      let(:result) { subject.licenses_for('invalid', '6.23.0') }

      before do
        stub_request(:get, 'https://registry.yarnpkg.com/invalid')
          .and_return(status: 404, body: { error: 'Not found' }.to_json)
      end

      specify { expect(result).to be_empty }
    end

    context 'when connecting to a custom source' do
      let(:custom_source) { 'https://example.com'  }
      let(:result) { subject.licenses_for('babel', '6.23.0', source: custom_source) }

      before do
        stub_request(:get, 'https://example.com/babel')
          .and_return(status: 200, body: { versions: { '6.23.0' => { license: 'MIT' } } }.to_json)
      end

      specify { expect(result.map(&:id)).to match_array(['MIT']) }
    end

    context 'when the endpoint returns an unexpected response' do
      let(:result) { subject.licenses_for('babel', '6.23.0') }

      before do
        stub_request(:get, 'https://registry.yarnpkg.com/babel')
          .and_return(status: 200, body: {}.to_json)
      end

      specify { expect(result).to be_empty }
    end
  end
end