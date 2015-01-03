require 'mandrill'

class User < ActiveRecord::Base
    belongs_to :referrer, :class_name => "User", :foreign_key => "referrer_id"
    has_many :referrals, :class_name => "User", :foreign_key => "referrer_id"
    
    attr_accessible :email

    validates :email, :uniqueness => true, :format => { :with => /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/i, :message => "Invalid email format." }
    validates :referral_code, :uniqueness => true

    before_create :create_referral_code
    after_create :send_welcome_email, :update_referrer!

    REFERRAL_STEPS = [
        {
            'count' => 5,
            "html" => "Early access to<br>Learn Safari<br>for your child",
            "class" => "two",
            "image" =>  ActionController::Base.helpers.asset_path("refer/tooltip1.png")
        },
        {
            'count' => 10,
            "html" => "3 Months<br>Free Access",
            "class" => "three",
            "image" => ActionController::Base.helpers.asset_path("refer/tooltip2.png")
        },
        {
            'count' => 25,
            "html" => "Lifetime<br>Free Access",
            "class" => "four",
            "image" => ActionController::Base.helpers.asset_path("refer/tooltip3.png")
        },
    ]

    def send_welcome_email
        m = Mandrill::API.new
        template_name = 'welcome'
        template_content = []
        message = {
            global_merge_vars: [{
                name: 'refcode',
                content: referral_code
            },],
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

    private

    def async_send_welcome_email
        WelcomeMailWorker.perform_async(id)
    end


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
