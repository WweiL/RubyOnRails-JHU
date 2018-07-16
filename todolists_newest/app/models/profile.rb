class Profile < ActiveRecord::Base
  belongs_to :user
  validates :gender, inclusion: { in: ["male", "female"] }
  validate :name_not_nil
  validate :what_is_that

  def name_not_nil
    if first_name.nil? and last_name.nil?
      errors.add(:first_name, "First name and last name cannot be empty at same time")
    end
  end

  def what_is_that
    if gender == "male" and first_name == "Sue"
      errors.add(:gender, "I don't understand why a boy can't be named Sue")
    end
  end

# issues a BETWEEN SQL clause in a where clause to locate Profiles with birth years
# that are between min year and max year defends itself against SQL injection
# when applying the parameters to the SQL clauses returns a collection of Profiles
# in ASC birth year order
  def self.get_all_profiles(min_age, max_age)
    self.where("birth_year BETWEEN ? and ?", min_age, max_age).order(:birth_year)
  end
end
