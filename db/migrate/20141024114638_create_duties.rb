class CreateDuties < ActiveRecord::Migration
  def change
    create_table :duties do |t|
      t.string      :name
      t.references  :contact
      t.timestamps
    end
  end
end
