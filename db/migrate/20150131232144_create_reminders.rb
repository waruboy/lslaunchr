class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.references :user
      t.boolean :day_3_sent
      t.datetime :day_3_sent_at
      t.boolean :day_10_sent
      t.datetime :day_10_sent_at

      t.timestamps
    end
    add_index :reminders, :user_id
  end
end
