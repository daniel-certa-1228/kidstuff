class Assignment < ApplicationRecord
    has_attached_file :avatar, styles: {  sm: "150X200", original: "900x1200" }
    validates_presence_of :avatar
    validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
    
    belongs_to :user

    def self.fuzzy_content_search(search_string)
        search_string = "%" + search_string.downcase + "%"
        self.where("lower(content) LIKE ?", search_string)
    end
end
