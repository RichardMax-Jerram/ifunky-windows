require 'spec_helper'

describe 'windows', :type => :class do
  let(:facts) { {
      :osfamily  => 'windows'
  } }

  it { is_expected.to compile.with_all_deps }

end