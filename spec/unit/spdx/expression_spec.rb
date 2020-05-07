RSpec.describe Spandx::Spdx::Expression do
  subject { described_class.new }

  describe "#parse" do
    specify { expect(subject).to parse('MIT') }
    specify { expect(subject.parse('MIT').to_s).to eql("MIT") }

    pending { expect(subject.parse_with_debug('MIT or GPLv3')).to be_truthy }
    pending { expect(subject).to parse('(0BSD OR MIT)') }
    pending { expect(subject.parse('(BSD-2-Clause OR MIT OR Apache-2.0)')).to eql('BSD-2-Clause') }
    pending { expect(subject.parse('(BSD-3-Clause OR GPL-2.0)')).to eql('BSD-3-Clause') }
    pending { expect(subject.parse('(MIT AND CC-BY-3.0)')).to eql('(MIT AND CC-BY-3.0)') }
    pending { expect(subject.parse('(MIT AND Zlib)')).to eql(%w[MIT Zlib]) }
    pending { expect(subject.parse('(MIT OR Apache-2.0)')).to eql('MIT') }
    pending { expect(subject.parse('(MIT OR CC0-1.0)')).to eql('MIT') }
    pending { expect(subject.parse('(MIT OR GPL-3.0)')).to eql('MIT') }
    pending { expect(subject.parse('(WTFPL OR MIT)')).to eql('WTFPL') }
    pending { expect(subject.parse('BSD-3-Clause OR MIT')).to eql('BSD-3-Clause') }
  end

  describe "#simple_expression" do
    specify { expect(subject.simple_expression).to parse('MIT') }
    specify { expect(subject.simple_expression).to parse('0BSD') }
    specify { expect(subject.simple_expression).to parse('BSD-3-Clause') }
    specify { expect(subject.simple_expression).to parse('GPLv3') }
  end

  describe "#license_id" do
    specify { expect(subject.license_id).to parse('MIT') }
    specify { expect(subject.license_id).to parse('0BSD') }
  end

  describe "$license_exception_id" do
    specify { expect(subject.license_exception_id).to parse('389-exception') }
  end

  describe "#with_expression" do
  end

  describe "#and_expression" do
    subject { described_class.new.and_expression }

    specify { expect(subject.parse_with_debug('0BSD AND MIT')).to be_truthy }
  end

  describe "#or_expression" do
    subject { described_class.new.or_expression }

    specify { expect(subject.parse_with_debug('0BSD OR MIT')).to be_truthy }
  end

  describe "#compound_expression" do
    subject { described_class.new.compound_expression }

    pending { expect(subject.parse_with_debug('0BSD OR MIT')).to be_truthy }
    pending { expect(subject.parse_with_debug('(0BSD OR MIT)')).to be_truthy }
  end
end
