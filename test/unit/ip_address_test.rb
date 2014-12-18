require 'test_helper'

class IpAddressTest < ActiveSupport::TestCase
  test 'has valid 
  data' do
    IpAddress.find_each do |ip_address|
      assert_valid ip_address
    end
  end
  # test "the truth" do
  #   assert true
  # end
end
