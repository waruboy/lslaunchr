require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'has valid data' do
    User.find_each do |user|
      assert_valid user
    end
  end

  test 'must have an email' do
    invalid_user = User.new
    assert_invalid invalid_user
    assert_includes invalid_user.errors[:email], "Invalid email format."
  end

  test 'must have a unique referral code' do
    copy_cat  = User.new(email: "wawa@owow.com")
    copy_cat.referral_code = users(:one).referral_code
    assert_invalid copy_cat, referral_code: 'has already been taken'
  end

end 
