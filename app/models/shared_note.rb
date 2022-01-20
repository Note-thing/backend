class SharedNote < ApplicationRecord

  belongs_to :note


  def self.share_type
    %w[read_only mirror copy_content]
  end
end
