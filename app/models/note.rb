class Note < ApplicationRecord

  belongs_to :folder
  has_many :tags, dependent: :destroy

  has_many :shared_notes, dependent: :destroy

  validates :title, presence: true
  validates :title, length: { minimum: 1, maximum: 64 }

  # attributs :
  # title, body, created_at, updated_at, folder_id, reference_note, read_only, lock, has_mirror

  # On définit la famille d'une note toutes celles reliées par un partage.
  # La note parente est la note depuis laquelle la note actuelle est copiée (reference_id)
  # Une note enfant est celle qui a été copiée à partir de nous-même.

  # true si la node possède des parents ou enfants lockés.
  def has_locked_references
    child_notes = Note.where(reference_note: self.id)
    child_notes.each do |note|
      if note.lock
        return true
      end
    end

    false
  end

  # true si la note parente a été utilisée frequemment
  def has_parent_not_been_used_recently
    if self.reference_note
      get_parent.updated_at < 1.minute.ago
    end
  end

  # true si la note a été utilisé fréquemment
  # pour mettre à jour le champ "updated_at", utiliser note.touch
  def has_been_used_frequently(note)
    note.updated_at > 1.minute.ago
  end

  # true si un parent ou enfant a été utilisé frequemment
  def has_family_been_used_recently
    # donc si on a un parent
    if self.reference_note
      # alors on regarde si utilisé fréquemment
      if has_been_used_frequently get_parent
        return true
      end
    end

    # et pareil pour tous les enfants
    child_notes = Note.where(reference_note: self.id)
    child_notes.each do |note|
      if note.lock and has_been_used_frequently(note)
        return true
      end
    end

    false
  end

  # màj contenu des enfants
  def update_children
    child_notes = Note.where(reference_note: self.id)
    child_notes.each do |note|
      note.title = self.title
      note.body = self.body
      note.save
    end
  end

  # lock ou unlock la famille (càd enfant + parent si existant)
  def set_family_to(lock, except = nil)
    child_notes = Note.where(reference_note: self.id)
    child_notes.each do |note|
      if except == nil || note.id != except
        note.lock = lock
        note.save
      end
    end

    if self.reference_note
      parent = get_parent

      parent.lock = lock
      parent.save
      parent.set_family_to(lock, self.id)
    end
  end

  # retire le champ mirroir
  def remove_mirror_to_family
    child_notes = Note.where(reference_note: self.id)
    child_notes.each do |note|
      if note.has_mirror
        note.has_mirror = false
        note.save
      end
    end

    # Ok alors là c'est plus délicat..
    # On doit vérifier si le parent n'a pas d'autre notes partagées en mirror avant de r
    if self.reference_note
      parent = get_parent
      siblings = Note.where(reference_note: parent.id)
      p siblings.length, "sibling length"
      siblings.each do |note|
        if note.id != self.id and note.has_mirror
          return
        end
      end
      parent.has_mirror = false
      parent.save
    end
  end

  # supprime les références de soi-même aux enfants
  # les enfants deviennent orphelines, et indépendante de tout lock/read_only
  def remove_copies
    child_notes = Note.where(reference_note: self.id)
    child_notes.each do |note|
      note.reference_note = nil
      if note.read_only
        note.read_only = false
      end
      note.save
    end
  end

  # màj contenu dans parent
  def copy_to_parent
    parent = get_parent
    parent.title = self.title
    parent.body = self.body
    parent.save!
  end

  # màj contenu de parent
  def copy_from_parent
    parent = get_parent

    self.title = parent.title
    self.body = parent.body
    self.save!
  end

  private

  # retourne le parent, si existant
  def get_parent
    begin
      return Note.find(self.reference_note)
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

  end

end
