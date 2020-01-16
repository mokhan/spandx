# frozen_string_literal: true

RSpec.describe Spandx::Gateways::PyPI do
  describe '#definition_for' do
    subject { described_class.new }

    let(:source) { 'pypi.org' }
    let(:package) { 'six' }
    let(:version) { '1.13.0' }
    let(:successful_response_body) do
      JSON.generate(
        info: {
          name: package,
          version: version
        }
      )
    end

    context 'when the default source is reachable' do
      before do
        stub_request(:get, "https://#{source}/pypi/#{package}/#{version}/json")
          .to_return(status: 200, body: successful_response_body)
      end

      specify do
        expect(subject.definition_for(package, version)).to include(
          'name' => package,
          'version' => version
        )
      end
    end

    context 'when the response redirects to a different location' do
      let(:redirect_url) { "https://#{source}/pypi/#{SecureRandom.uuid}" }

      before do
        stub_request(:get, "https://#{source}/pypi/#{package}/#{version}/json")
          .to_return(status: 301, headers: { 'Location' => redirect_url })

        stub_request(:get, redirect_url)
          .to_return(status: 200, body: successful_response_body)
      end

      specify do
        expect(subject.definition_for(package, version)).to include(
          'name' => package,
          'version' => version
        )
      end
    end

    context 'when stuck in an infinite redirect loop' do
      before do
        url = "https://#{source}/pypi/#{package}/#{version}/json"

        11.times do |n|
          redirect_url = "#{url}#{n}"
          stub_request(:get, url)
            .to_return(status: 301, headers: { 'Location' => redirect_url })
          url = redirect_url
        end
      end

      it 'gives up after `n` attempts' do
        expect(subject.definition_for(package, version)).to be_empty
      end
    end

    context 'when the source is not reachable' do
      before do
        stub_request(:get, "https://#{source}/pypi/#{package}/#{version}/json")
          .to_timeout
      end

      it 'fails gracefully' do
        expect(subject.definition_for(package, version)).to be_empty
      end
    end
  end
end
