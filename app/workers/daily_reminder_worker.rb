class DailyReminderWorker
  include Sidekiq::Worker 
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    User.send_reminder
  end
end