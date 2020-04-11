# frozen_string_literal: true

RSpec.describe Spandx::Dotnet::Parsers::Csproj do
  subject { described_class.new }

  describe '#parse' do
    context 'when parsing a .csproj file' do
      let(:lockfile) { fixture_file('nuget/example.csproj') }

      let(:because) { subject.parse(lockfile) }
      let(:jive) { because.find { |item| item.name == 'jive' } }

      specify { expect(jive.name).to eql('jive') }
      specify { expect(jive.version).to eql('0.1.0') }
    end

    context 'when parsing a .csproj file that has a reference to another project' do
      let(:lockfile) { fixture_file('nuget/nested/test.csproj') }

      let(:because) { subject.parse(lockfile) }

      specify { expect(because.map(&:name)).to match_array(%w[jive xunit]) }
    end

    context 'when parsing `Nancy.Hosting.Self.csproj`' do
      let(:lockfile) { fixture_file('nuget/Nancy.Hosting.Self.csproj') }

      let(:because) { subject.parse(lockfile) }

      specify { expect(because.count).to be(1) }
      specify { expect(because[0].name).to eql('System.Security.Principal.Windows') }
      specify { expect(because[0].version).to eql('4.3.0') }
    end
  end

  describe '.matches?' do
    subject { described_class }

    specify { expect(subject.matches?('/root/simple.csproj')).to be(true) }
    specify { expect(subject.matches?('C:\Documents and Settings\simple.csproj')).to be(true) }
    specify { expect(subject.matches?('C:\Documents and Settings\hello world.csproj')).to be(true) }
    specify { expect(subject.matches?('/root/Packages.props')).to be(true) }
    specify { expect(subject.matches?('/root/simple.sln')).to be(false) }
  end
end
