class RenameForeignKeyOfProfiles < ActiveRecord::Migration
  def change
    rename_column :profiles, :users_id, :user_id
  end
end
