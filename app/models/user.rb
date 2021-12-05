class User < ApplicationRecord

    validates :email, uniqueness: true

    has_many :folders

end
