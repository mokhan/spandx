# frozen_string_literal: true

RSpec.describe Spandx::Guess do
  subject { described_class.new(catalogue) }

  let(:catalogue) { Spandx::Catalogue.from_file(fixture_file('spdx.json')) }

  describe '#license_for' do
    needs_investigation = [
      '389-exception',
      'AGPL-1.0-only',
      'AGPL-1.0-or-later',
      'AGPL-3.0-only',
      'AGPL-3.0-or-later',
      'Autoconf-exception-2.0',
      'Autoconf-exception-3.0',
      'Bison-exception-2.2',
      'Bootloader-exception',
      'CLISP-exception-2.0',
      'Classpath-exception-2.0',
      'DigiRule-FOSS-exception',
      'FLTK-exception',
      'Fawkes-Runtime-exception',
      'Font-exception-2.0',
      'GCC-exception-2.0',
      'GCC-exception-3.1',
      'GFDL-1.1-only',
      'GFDL-1.1-or-later',
      'GFDL-1.2-only',
      'GFDL-1.2-or-later',
      'GFDL-1.3-only',
      'GFDL-1.3-or-later',
      'GPL-1.0+',
      'GPL-1.0-only',
      'GPL-1.0-or-later',
      'GPL-2.0-only',
      'GPL-2.0-or-later',
      'GPL-3.0+',
      'GPL-3.0-only',
      'GPL-3.0-or-later',
      'GPL-CC-1.0',
      'LGPL-2.0+',
      'LGPL-2.0-only',
      'LGPL-2.0-or-later',
      'LGPL-2.1+',
      'LGPL-2.1-only',
      'LGPL-2.1-or-later',
      'LGPL-3.0+',
      'LGPL-3.0-only',
      'LGPL-3.0-or-later',
      'LLVM-exception',
      'LZMA-exception',
      'Libtool-exception',
      'Linux-syscall-note',
      'MPL-2.0-no-copyleft-exception',
      'MulanPSL-1.0',
      'Nokia-Qt-exception-1.1',
      'OCCT-exception-1.0',
      'OCaml-LGPL-linking-exception',
      'OGL-Canada-2.0',
      'OLDAP-2.2.1',
      'OLDAP-2.3',
      'OpenJDK-assembly-exception-1.0',
      'PS-or-PDF-font-exception-20170817',
      'Qt-GPL-exception-1.0',
      'Qt-LGPL-exception-1.1',
      'Qwt-exception-1.0',
      'SSH-OpenSSH',
      'SSH-short',
      'StandardML-NJ',
      'Swift-exception',
      'UCL-1.0',
      'Universal-FOSS-exception-1.0',
      'WxWindows-exception-3.1',
      'eCos-exception-2.0',
      'etalab-2.0',
      'freertos-exception-2.0',
      'gnu-javamail-exception',
      'i2p-gpl-java-exception',
      'licenses',
      'mif-exception',
      'openvpn-openssl-exception',
      'u-boot-exception-2.0',
    ]

    Dir["spec/fixtures/spdx/jsonld/*.jsonld"].map { |x| File.basename(x).gsub('.jsonld', '') }.each do |license|
      next if needs_investigation.include?(license)

      it "guesses the `#{license}` correctly" do
        expect(subject.license_for(license_file(license))).to eql(license)
      end
    end

    needs_investigation.each do |license|
      pending "guesses the `#{license}` correctly" do
        expect(subject.license_for(license_file(license))).to eql(license)
      end
    end
  end
end