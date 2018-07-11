class Profile < ActiveRecord::Base
  validates :gender, inclusion: { in: ["male", "female"] }
end
