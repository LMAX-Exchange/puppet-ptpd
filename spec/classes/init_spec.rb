require 'spec_helper'
describe 'ptpd' do

  context 'with defaults for all parameters' do
    it { should contain_class('ptpd') }
  end
end
