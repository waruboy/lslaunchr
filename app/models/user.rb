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
            "html" => "Lifetime<br>Free Access",
            "class" => "three",
            "image" => ""
        },
    ]

    def to_s
        email
    end

    def update_ref_count!
        self.ref_count = referrals.count
        self.save
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

    def send_welcome_email
        UserMailer.delay.signup_email(self)
    end

    def update_referrer!
        if referrer
            referrer.update_ref_count!
        end
    end
end
