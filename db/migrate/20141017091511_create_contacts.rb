class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string    :first_name
      t.string    :last_name
      t.string    :phone
      t.string    :email
      t.integer   :alert_by_email, default: 1
      t.integer   :alert_by_sms, default: 1
      t.timestamps
    end
  end
end
