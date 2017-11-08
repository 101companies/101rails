class Part < ApplicationRecord
belongs_to :repo

validates :name, presence: true
validates :state, presence:true

def to_param
  name
end

end
