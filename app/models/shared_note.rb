class SharedNote < ApplicationRecord

  belongs_to :note

  READ_ONLY = 'read_only'
  MIRROR = 'mirror'
  COPY_CONTENT = 'copy_content'

  def self.share_type
    %w[read_only mirror copy_content]
  end

  # attributs :
  # title, body, created_at, updated_at, note_id, uuid, sharing_type

end
