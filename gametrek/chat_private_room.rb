class ChatPrivateRoom
  attr_accessor :id

  def self.find(id)
    ChatPrivateRoom.new(id: id)
  end

  def initialize(attributes = {})
    @id = attributes[:id]
  end

  def user_ids
    [@id & 0x3fffffff, @id >> 30]
  end

  def users
    User.where(id: user_ids)
  end
end
