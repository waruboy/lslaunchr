# Export to CSV with the referrer_id
ActiveAdmin.register User do
  actions :index, :show

  index do
    column :id
    column :email
    column :referrer_id
    column :referral_code
    column :ref_count
    column :created_at
    column :updated_at
  end

  csv do
    column :id
    column :email
    column :referral_code
    column :ref_count
    column :referrer_id
    column :created_at
    column :updated_at
  end
  
end
