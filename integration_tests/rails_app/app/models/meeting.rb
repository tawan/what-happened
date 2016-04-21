class Meeting < ActiveRecord::Base
  belongs_to :group
  has_many :participations
  has_many :participants, through: :participations, class_name: "User", source: :user
  belongs_to :creator, class_name: "User"
end
