class Dish < ActiveRecord::Base
  has_many :comments
  # allows @dish.user.email etc.
  belongs_to :user # add extra methods
  has_many :likes # add likes method
end
