require 'spec_helper'

describe 'get_windows_env_byname' do

  it { should run.with_params('OS').and_return('Windows_NT') }
end