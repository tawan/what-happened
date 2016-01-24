class Group < ActiveRecord::Base
  has_many :users, through: :group_memberships
  has_many :group_memberships
end
