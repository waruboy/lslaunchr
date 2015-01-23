class InboxController < ApplicationController
  include Mandrill::Rails::WebHookProcessor
    def handle_hard_bounce(event_payload)
    User.delete_bounced(event_payload)
  end

  def handle_soft_bounce(event_payload)
    User.delete_bounced(event_payload)
  end
end