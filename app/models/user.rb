class User < ApplicationRecord
    has_secure_password

    has_many :children
    has_many :artworks
    has_many :assignments
    has_many :activities


    validates_uniqueness_of :email, :user_name
    validates_presence_of :user_name
end
