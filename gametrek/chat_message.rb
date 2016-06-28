class ChatMessage < ApplicationRecord
  belongs_to :author, class_name: 'User'
  validates  :text, presence: true

  def room
    room_type.to_s.classify.constantize.find(room_id) unless room_type.nil? || room_id.nil?
  end

  def room=(value)
    self.room_type = value.class
    self.room_id = value.id
  end

  def addressees
    if room.nil?
      User.all
    elsif room.is_a? User
      [room]
    else
      room.users.all
    end
  end

  def addressees_with_author
    (addressees + [author]).uniq
  end
end
