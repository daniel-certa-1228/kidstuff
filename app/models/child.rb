class Child < ApplicationRecord
    belongs_to :user
    has_many :artworks
    has_many :assignments
    has_many :activities
    validates_presence_of :child_name
end
