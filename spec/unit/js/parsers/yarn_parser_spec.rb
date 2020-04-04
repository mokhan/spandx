# frozen_string_literal: true

RSpec.describe Spandx::Js::Parsers::Yarn do
  subject { described_class.new(catalogue: catalogue) }

  let(:catalogue) { Spandx::Spdx::Catalogue.from_file(fixture_file('spdx/json/licenses.json')) }

  describe '#parse small lock file' do
    let(:lockfile) { fixture_file('js/yarn/short_yarn.lock') }
    let(:result) { subject.parse(lockfile) }

    specify { expect(result.size).to eq(2) }
    specify { expect(result.first.name).to eq('babel') }
    specify { expect(result.first.version).to eq('6.23.0') }
  end

  describe '#invalid lock file' do
    let(:lockfile) { fixture_file('js/yarn/invalid_yarn.lock') }

    specify { expect(subject.parse(lockfile)).to eq(nil) }
  end

  describe '#parse long lock file' do
    let(:lockfile) { fixture_file('js/yarn/long_yarn.lock') }
    let(:result) { subject.parse(lockfile).to_a }
    let(:expected_dependencies) do
      [
        'accepts@1.3.7', 'array-flatten@1.1.1', 'body-parser@1.19.0', 'bytes@3.1.0', 'content-disposition@0.5.3', 'content-type@1.0.4',
        'cookie-signature@1.0.6', 'cookie@0.4.0', 'debug@2.6.9', 'depd@1.1.2', 'destroy@1.0.4', 'ee-first@1.1.1', 'encodeurl@1.0.2', 'escape-html@1.0.3',
        'etag@1.8.1', 'express@4.17.1', 'finalhandler@1.1.2', 'forwarded@0.1.2', 'fresh@0.5.2', 'http-errors@1.7.2', 'http-errors@1.7.3', 'iconv-lite@0.4.24',
        'inherits@2.0.3', 'inherits@2.0.4', 'ipaddr.js@1.9.1', 'jquery@3.4.0', 'media-typer@0.3.0', 'merge-descriptors@1.0.1', 'methods@1.1.2', 'mime-db@1.43.0', 'mime-types@2.1.26',
        'mime@1.6.0', 'ms@2.0.0', 'ms@2.1.1', 'negotiator@0.6.2', 'on-finished@2.3.0', 'parseurl@1.3.3', 'path-to-regexp@0.1.7', 'proxy-addr@2.0.6', 'qs@6.7.0', 'range-parser@1.2.1', 'raw-body@2.4.0',
        'safe-buffer@5.1.2', 'safer-buffer@2.1.2', 'send@0.17.1', 'serve-static@1.14.1', 'setprototypeof@1.1.1', 'statuses@1.5.0', 'toidentifier@1.0.0', 'type-is@1.6.18', 'unpipe@1.0.0', 'utils-merge@1.0.1', 'vary@1.1.2'
      ]
    end

    specify { expect(result.map { |x| "#{x.name}@#{x.version}" }) .to match_array(expected_dependencies) }
    specify { expect(result.size).to eq(53) }
  end
end
