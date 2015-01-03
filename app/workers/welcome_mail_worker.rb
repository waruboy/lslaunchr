class WelcomeMailWorker
  include Sidekiq::worker 

  def perform(id)
    user = User.find(id)
    user.send_welcome_mail
  end
end