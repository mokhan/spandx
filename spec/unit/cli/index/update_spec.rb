# frozen_string_literal: true

RSpec.describe Spandx::Cli::Commands::Index::Update do
  subject { described_class.new(options) }

  let(:options) { {} }

  describe '#execute' do
    let(:output) { StringIO.new }

    it 'executes `index update` command successfully' do
      subject.execute(output: output)
      expected = <<~OUTPUT
        Updating https://github.com/mokhan/spandx-rubygems.git...
        Updating https://github.com/spdx/license-list-data.git...
        OK
      OUTPUT

      expect(output.string).to eq(expected)
    end
  end
end
