require 'spec_helper'

describe 'windows::unzip',:type => :define do
  let(:facts) { {
      :osfamily  => 'windows'
  } }

  context 'The catalog should at the very least compile' do
    let(:title) { 'test' }

    let(:params) {{
        :destination => 'c:\somewhere',
        :creates     => 'c:\a_file'
    }}

    it {
      should compile.with_all_deps
    }
  end

  describe 'Not passing destination should fail' do

    let(:title) { 'test' }

    let(:params) {{
        :creates  		            => 'c:\temp\file',
        :zipfile                  => 'c:\temp\test.zip',
    }}

    #it { is_expected.to compile.with_all_deps }
    it do
      expect {
        should contain_exec('filename')
      }.to raise_error(Puppet::Error) {|e| expect(e.to_s).to match 'Must pass destination to Windows'}
    end

    #it { is_expected.to compile.with_all_deps }
  end

end