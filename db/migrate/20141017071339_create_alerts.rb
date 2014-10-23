class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.string   :uid
      t.string   :message
      t.datetime :created_at
      t.datetime :last_alert_at
      t.datetime :acknowledged_at
    end
  end
end
