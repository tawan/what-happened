class Group < ApplicationRecord
  has_many :members, through: :memberships, source: :user
  has_many :memberships
  has_many :meetings
end
