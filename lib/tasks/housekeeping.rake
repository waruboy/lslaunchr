namespace :housekeeping do 
  desc "will create reminder model for each user without any"
  task create_reminder_records: :environment do
    users = User.includes(:reminder).where(reminders: {id: nil})
    users.each do |user|
      user.create_reminder_record
    end
    puts "records created: #{users.count}"
  end
  
end