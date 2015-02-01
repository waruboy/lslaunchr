class Reminder < ActiveRecord::Base
  belongs_to :user
  attr_accessible :day_10_sent, :day_10_sent_at, :day_3_sent, :day_3_sent_at
end
