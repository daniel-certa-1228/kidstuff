class Artwork < ApplicationRecord
    has_attached_file :avatar, styles: {  med: "300x450", original: "900x1200" }
    validates_presence_of :avatar
    validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
    
    belongs_to :user

    def self.fuzzy_content_search(search_string)
        search_string = "%" + search_string.downcase + "%"
        self.where("lower(title) LIKE ?", search_string)
    end
end
