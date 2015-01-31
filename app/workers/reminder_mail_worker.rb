class ReminderMailWorker
  include Sidekiq::Worker 

  def perform(id, days)
    user = User.find(id)
    user.send_reminder_email(days)
  end
end