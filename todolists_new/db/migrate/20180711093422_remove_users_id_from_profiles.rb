class RemoveUsersIdFromProfiles < ActiveRecord::Migration
  def change
    remove_column :profiles, :users_id
  end
end
