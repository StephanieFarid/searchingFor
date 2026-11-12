class RemoveAccounts < ActiveRecord::Migration[8.1]
  def change
    remove_reference :comments, :user, null: false, foreign_key: true, index: true
    remove_reference :items, :user, null: false, foreign_key: true, index: true

    drop_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end

    drop_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :name
      t.timestamps
      t.index :email_address, unique: true
    end
  end
end
