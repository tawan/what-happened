class User < ActiveRecord::Base
  has_many :groups, through: :memberships
  has_many :memberships
end
