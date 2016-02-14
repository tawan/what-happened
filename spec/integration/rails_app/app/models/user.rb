class User < ActiveRecord::Base
  has_many :groups, through: :memberships
  has_many :memberships
  has_many :participations
  has_many :meetings, through: :participations
end
