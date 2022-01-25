class Note < ApplicationRecord

  belongs_to :folder
  #has_many :note_tags, dependent: :destroy
  #has_many :tags, through: :note_tags
  has_many :tags, dependent: :destroy

  has_many :shared_notes, dependent: :destroy

  validates :title, presence: true
  validates :title, length: { minimum: 1, maximum: 64 }

  def has_locked_references
    child_notes = Note.where(reference_note: self.id)
    child_notes.each do |note|
      if note.lock
        return true
      end
    end

    false
  end

  def has_parent_not_been_used_recently
    if self.reference_note
      get_parent.updated_at < 1.minute.ago
    end
  end

  def has_been_used_frequently(note)
    note.updated_at > 1.minute.ago
  end

  def has_family_been_used_recently
    if self.reference_note
      if has_been_used_frequently get_parent
        return true
      end
    end

    child_notes = Note.where(reference_note: self.id)
    child_notes.each do |note|
      if note.lock and has_been_used_frequently(note)
        return true
      end
    end

    false
  end

  def update_children
    child_notes = Note.where(reference_note: self.id)
    child_notes.each do |note|
      note.title = self.title
      note.body = self.body
      note.save
    end
  end

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

  def copy_to_parent
    parent = get_parent
    parent.title = self.title
    parent.body = self.body
    parent.save!
  end

  def copy_from_parent
    parent = get_parent

    self.title = parent.title
    self.body = parent.body
    self.save!
  end

  private

  def get_parent
    begin
      return Note.find(self.reference_note)
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end

  end

end
