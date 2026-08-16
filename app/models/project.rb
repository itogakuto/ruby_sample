class Project < ApplicationRecord
    validates :name, presence: true

    has_many :sprints, dependent: :destroy
end
