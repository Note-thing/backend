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

  def set_family_to(lock, except = nil)
    child_notes = Note.where(reference_note: self.id)

    child_notes.each do |note|
      if except == nil || note.id != except
        note.lock = lock
        note.save!
      end
    end

    if self.reference_note
      begin
        parent = Note.find(reference_note)
      rescue ActiveRecord::RecordNotFound => e
        raise BadRequestError.new(e)
      end

      parent.lock = lock
      parent.save
      parent.set_family_to(lock, self.id)
    end

  end

  def remove_copies
    Note.find_each(reference_note: self.id) do |note|
      note.reference_note = nil
      note.save
    end
  end

  def copy_from_parent
    begin
      parent = Note.find(reference_note)
    rescue ActiveRecord::RecordNotFound => e
      raise BadRequestError.new(e)
    end
    self.title = parent.title
    self.body = parent.body
  end

end
