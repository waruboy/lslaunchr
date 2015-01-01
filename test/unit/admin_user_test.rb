require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  test 'has valid data'  do
    AdminUser.find_each do |admin|
      assert_valid admin
    end
  end
end
