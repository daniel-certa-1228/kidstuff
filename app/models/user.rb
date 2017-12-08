class User < ApplicationRecord
    has_secure_password

    has_many :children
    has_many :artworks
    has_many :assignments
    has_many :activities

    validates :email, :email_format => { :message => 'must be in the correct format.' }
    validates_uniqueness_of :email, :user_name
    validates_presence_of :user_name
end
