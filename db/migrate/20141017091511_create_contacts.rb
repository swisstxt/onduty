class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string  :name
      t.string  :phone
      t.time    :created_at
      t.integer :status
    end
  end
end
