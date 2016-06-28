module Api
  module Users
    class ChatMessagesController < ApiController
      # returns messages for specified room
      # room is specified by :room_type (for example: user) and :room_id
      # if room is not specified returns messages for common chat
      # if :offset and/or :limit is specified then returns messages according to these parameters
      #  otherwise returns messages sent in the last 1m
      # sender id could be passed by :from parameter
      # example:  /api/users/:token/chat_messages&room_type=user&room_id=2&from=1&offset=25&limit=10 -
      #  return 10 messages from 26th sent to the user with id 2  from the user with id 1
      def index
        chat_messaged_filter = ChatMessagesFilter.new(params)
        render json: chat_messaged_filter.filter
      end

      def create
        @message = ChatMessage.create(message_params)
        @message.author = current_user
        if @message.save
          ChatChannel.broadcast_message @message
          render json: @message
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      end

      def rooms
        @rooms = room_types.map(&:all).flatten
        render json: @rooms, each_serializer: ChatRoomSerializer, context: { current_user: current_user }
      end

      def message_params
        params.permit(:text, :room_type, :room_id)
      end

      private

      def room_types
        [User, Department]
      end
    end
  end
end
