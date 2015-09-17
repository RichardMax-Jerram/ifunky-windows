require 'spec_helper'

describe 'windows' do
  let(:facts) { {
      :osfamily  => 'windows'
  } }

  context 'The catalog should at the very least compile' do
    let(:params) {{
        :temp_dir => 'C:\temp',
    }}
    it {
      should compile.with_all_deps
    }
  end

  describe 'Passing an incorrect proxy server url should fail' do
    let(:params) {{
        :temp_dir     => 'somewhere_on_the_drive',
        :proxy_server => 'htt://proxyserver.net:3128'
    }}

    it { should compile.and_raise_error(/ERROR: You must enter a proxy url in a valid format i\.e\. http:\/\/proxy\.net:3128/) }
  end
end
