RSpec.describe Spandx::Spdx::CompositeLicense do
  context ".from_expression" do
    subject { described_class.from_expression(expression, catalogue) }
    let(:catalogue) { ::Spandx::Spdx::Catalogue.from_file(fixture_file('spdx/json/licenses.json')) }

    before do
      puts subject.instance_variable_get(:@tree).inspect
    end

    context 'when parsing a simple binary expression' do
      let(:expression) { '(0BSD OR MIT)' }

      specify { expect(subject.id).to eql(expression) }
      specify { expect(subject.name).to eql("#{catalogue['0BSD'].name} OR #{catalogue['MIT'].name}") }
      specify { expect(subject).to be_kind_of(::Spandx::Spdx::License) }
    end

    context 'when parsing an expression with a valid and an invalid license id' do
      let(:expression) { 'MIT or GPLv3' }

      specify { expect(subject.id).to eql("(MIT OR Nonstandard)") }
      specify { expect(subject.name).to eql("#{catalogue['MIT'].name} OR GPLv3") }
      specify { expect(subject).to be_kind_of(::Spandx::Spdx::License) }
    end

    context 'when parsing a license name' do
      let(:expression) { 'Common Public License Version 1.0' }

      specify { expect(subject).to be_nil }
    end

    context 'when parsing an invalid expression' do
      let(:expression) { 'BSD-like' }

      specify { expect(subject.id).to eql('Nonstandard') }
      specify { expect(subject.name).to eql('BSD-like') }
    end

    context 'when parsing a binary expression with an id that is similar to another' do
      let(:expression) { '(MIT OR CC0-1.0)' }

      specify { expect(subject.id).to eql(expression) }
      specify { expect(subject.name).to eql("#{catalogue['MIT'].name} OR #{catalogue['CC0-1.0'].name}") }
      specify { expect(subject).to be_kind_of(::Spandx::Spdx::License) }
    end
  end
end
