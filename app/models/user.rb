require 'mandrill'

class User < ActiveRecord::Base
    belongs_to :referrer, :class_name => "User", :foreign_key => "referrer_id"
    has_many :referrals, :class_name => "User", :foreign_key => "referrer_id"
    has_one :reminder
    
    attr_accessible :email

    validates :email, :uniqueness => true, :format => { :with => /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i, :message => "Invalid email format." }
    validates :referral_code, :uniqueness => true

    before_create :create_referral_code
    after_create :create_reminder_record, :async_send_welcome_email, :update_referrer!, :async_notify_referrer

    REFERRAL_STEPS = [
        {
            'count' => 5,
            "html" => "Early VIP access to<br>Spanish Safari<br>for your child",
            "class" => "one",
            "image" =>  ""
        },
        {
            'count' => 10,
            "html" => "3 Months<br>Free Access",
            "class" => "two",
            "image" => ""
        },
        {
            'count' => 25,
            "html" => "1 Year<br>Free Access",
            "class" => "three",
            "image" => ""
        },
    ]
    REFERRAL_STEPS_COUNT = REFERRAL_STEPS.map { |s| s["count"] }

    def async_notify_referrer
        NotifyReferrerWorker.perform_in(30.seconds, id)
    end

    def async_send_reminder_email(days)
        ReminderMailWorker.perform_async(id, days)
    end

    def async_send_welcome_email
        WelcomeMailWorker.perform_in(30.seconds, id)
    end

    def create_reminder_record
        r = Reminder.new
        r.user = self
        r.save
    end

    def notify_referrer
        referrer = self.referrer
        
        if referrer
            rcount = referrer.referrals.count
            if REFERRAL_STEPS_COUNT.include? rcount or rcount == 1
                mandrill_key = ENV["mandrill_key"]
                m = Mandrill::API.new mandrill_key
                template_name ="subscribe-#{rcount}"
                template_content = []
                message = 
                {
                    global_merge_vars:
                    [
                        {
                            name: "refcode",
                            content: referrer.referral_code
                        },
                        {
                            name: "year",
                            content: Time.new.year.to_s
                        },
                    ],
                    tags: [ "subscribe-#{rcount}"],
                    to: [{ email: referrer.email }],
                }
                sending = m.messages.send_template template_name, template_content, message
                puts sending
            end
        end
    end

    def send_reminder_email(days)
        mandrill_key = ENV["mandrill_key"]
        m = Mandrill::API.new mandrill_key
        template_name = "#{days}-days"
        template_content = []
        message = {
            global_merge_vars:
            [
                {
                    name: "refcode",
                    content: referral_code
                },
                {
                    name: "year",
                    content: Time.new.year.to_s
                },
            ],
            tags: [ "reminder-day-#{days}" ],
            to: [{ email: email }],
        }
        sending = m.messages.send_template template_name, template_content, message
        reminder = self.reminder
        reminder["day_#{days}_sent"] = true
        reminder["day_#{days}_sent_at"] = Time.current
        reminder.save
        puts sending
    end

    def send_welcome_email
        mandrill_key = ENV["mandrill_key"]
        m = Mandrill::API.new mandrill_key
        template_name = "welcome"
        template_content = []
        message = {
            global_merge_vars: [
                {
                name: 'refcode',
                content: referral_code
                },
                {
                name: 'year',
                content: Time.new.year.to_s
                },
            ],
            tags: [ "welcome" ],
            to: [{ email: email }],
        }
        sending = m.messages.send_template template_name, template_content, message
        puts sending
    end

    def to_s
        email
    end

    def update_ref_count!
        self.ref_count = referrals.count
        self.save
    end

    def self.delete_bounced(event_payload)
        recipient_address = event_payload['msg']['email']
        user = User.find_by_email(recipient_address)
        user.destroy if user
    end

    def self.send_reminder
        days = [3, 10]
        days.each do |day|
            day_field = "day_#{day}_sent"
            users = User.where(created_at: (Time.now - (day+2).days)..(Time.now - day.days))
            users.each do |user|
                unless user.reminder[day_field]
                    user.async_send_reminder_email(day)
                end
            end

        end
        
    end


    private

   

    def create_referral_code
        referral_code = SecureRandom.hex(5)
        @collision = User.find_by_referral_code(referral_code)

        while !@collision.nil?
            referral_code = SecureRandom.hex(5)
            @collision = User.find_by_referral_code(referral_code)
        end

        self.referral_code = referral_code
    end



    def update_referrer!
        if referrer
            referrer.update_ref_count!
        end
    end
end
