class ChatRoomSerializer < ActiveModel::Serializer
  attributes :login, :avatar_url, :room_type, :room_id, :online, :parent

  def avatar_url
    object.avatar.thumb('135x135#c').url if object.avatar
  end

  def room_type
    if object.class == User
      'ChatPrivateRoom'
    else
      object.class.to_s
    end
  end

  def room_id
    if object.class == User
      compound_id(object.id, context[:current_user].id)
    elsif object.class == ServiceRoom
      context[:current_user].id
    else
      object.id
    end
  end

  def online
    if object.respond_to?(:online?)
      object.online?
    else
      false
    end
  end

  def parent
    object.parent_id if object.respond_to?(:parent)
  end

  def compound_id(*args)
    args.sort!
    args[0] << 30 | args[1]
  end
end
