require 'spec_helper'

describe 'windows::gem',:type => :define do
  let(:facts) { {
      :osfamily  => 'windows'
  } }

  context 'The catalog should at the very least compile' do
    let(:title) { 'bundler' }
    let(:params) {{
        :ensure  => 'installed'
    }}

    it { should compile.with_all_deps  }
  end

  describe 'Not passing gem_name should fail' do

    let(:title) { '' }
    let(:params) {{
        :version  => '1.1.0',
        :ensure  => 'installed',
    }}

    it { should compile.and_raise_error(/ERROR:: You must specify a gem name to install/) }
  end

  describe 'Passing wrong value to ensure should fail' do
    let(:title) { 'bundler' }
    let(:params) {{
        :version  => '1.1.0',
        :ensure  => 'something',
    }}

    it { should compile.and_raise_error(/ERROR: ensure must be installed or absent/) }
  end

  describe 'Passing an incorrect version format should error' do
    let(:title) { 'bundler' }
    let(:params) {{
        :version  => '1.x.0',
        :ensure  => 'installed',
    }}

    it { should compile.and_raise_error(/ERROR: version must be in the format 1.1.22/) }
  end

  context 'When not specifying a version and ensure => installed the gem will install the latest version' do
    let(:title) { 'bundler' }
    let(:params) {{
        :ensure  => 'installed'
    }}

     #{ should contain_exec('gem install bundler').with({
     #   #'command'  => 'gem install bundler',
     #   #'onlyif'   => "\$gemName = \"bundler\";\$version = \"\";if (\$version) { \$version = \"{0}{1}{2}\" -f \"\(\", \$version.Replace('.','\.'), \"\)\"};\$gemVersion = \"\$gemName \$version\";if (gem list | select-string \$gemVersion | % { \$_.Matches } | % { \$_.Value }) { exit 1 } else { exit 0 }",
     #   'provider' => 'powershell',
    #}) }
  end

  context 'When specifying a version and ensure => installed the gem will install the specific version' do
    let(:title) { 'bundler' }
    let(:params) {{
        :version  => '1.10',
        :ensure  => 'installed'
    }}

    it { should contain_exec('install gem bundler').with({
       'command'  => 'c:\tools\ruby21\bin\gem.bat install bundler -v 1.10',
       #'onlyif'   => "\$gemName = \"bundler\";\$version = \"\";if (\$version) { \$version = \"{0}{1}{2}\" -f \"\(\", \$version.Replace('.','\.'), \"\)\"};\$gemVersion = \"\$gemName \$version\";if (gem list | select-string \$gemVersion | % { \$_.Matches } | % { \$_.Value }) { exit 1 } else { exit 0 }",
       'provider' => 'powershell',
   }) }
  end
end