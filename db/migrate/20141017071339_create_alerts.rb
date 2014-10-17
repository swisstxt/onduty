class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.string  :uid
      t.string  :message
      t.time    :created_at
      t.time    :acknowledged_at
    end
  end
end
