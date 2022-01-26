class Tag < ApplicationRecord

  belongs_to :note

  validates :title, presence: true
  validates :title, length: { minimum: 1, maximum: 32 }

  # valide l'uniticé d'un tag à une note.. Une note ne peut avoir qu'1x le tag "tag1"
  validates :title, uniqueness: {scope: :note_id}

  # attributs :
  # title, created_at, updated_at, note_id

end
