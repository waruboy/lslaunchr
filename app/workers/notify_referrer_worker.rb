class NotifyReferrerWorker
  include Sidekiq::Worker

  def perform(id)
    user = User.find(id)
    user.notify_referrer
  end
end