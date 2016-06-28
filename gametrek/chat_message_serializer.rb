class ChatMessageSerializer < ActiveModel::Serializer
  attributes :id, :room_type, :room_id, :text, :created_at, :type
  has_one :author, serializer: Chat::AuthorSerializer

  def type
    'msg'
  end
end
