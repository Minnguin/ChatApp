class Message < ApplicationRecord
  belongs_to :room
end
class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room 
end
