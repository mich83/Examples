# Be sure to restart your server when you modify this file.
# Action Cable runs in a loop that does not support auto reloading.
class ChatChannel < ApplicationCable::Channel
  def subscribed
    ChatChannel.broadcast_service_message(type: :users)
    stream_for current_user
  end

  def unsubscribed
    ChatChannel.broadcast_service_message(type: :users)
  end

  def speak(data)
    message = ChatMessage.create(
      author_id: current_user.id,
      room_type: data['room_type'],
      room_id: data['room_id'],
      text: data['text']
    )
    ChatChannel.broadcast_message message.id if message.save
  end

  def self.broadcast_message(message_id)
    message = ChatMessage.includes(:author).find(message_id)
    serialized_message = ChatMessageSerializer.new(message).as_json
    message.addressees_with_author.each do |addressee|
      ChatChannel.broadcast_to addressee, serialized_message
    end
  end

  def self.broadcast_service_message(message)
    serialized_message = { chat_message: message }.as_json
    User.all.each do |user|
      ChatChannel.broadcast_to user, serialized_message
    end
  end
end
