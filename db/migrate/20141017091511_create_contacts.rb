class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string  :name
      t.string  :phone
      t.string  :email
      t.time    :created_at
      t.integer :status, default: 0
      t.integer :alert_by_email, default: 1
      t.integer :alert_by_sms, default: 1
      t.integer :alert_by_phone, default: 1
    end
  end
end
