class ChatMessagesFilter < BaseFilter
  def initialize(params)
    super ChatMessage.includes(:author), params
    build_global_conditions(room)
    build_conditions(params)
  end

  def build_global_conditions(room)
    add_condition(condition: lambda do
                               where(room_id: room.try(:id),
                                     room_type: (room.nil? ? '' : room.class))
                               .order(created_at: :desc)
                             end)
  end

  def build_conditions(params)
    add_condition(required: :limit,  condition: -> { limit(params[:limit]) })
    add_condition(required: :offset, condition: -> { offset(params[:offset]) })
    add_condition(required: :from,   condition: -> { where(author_id: params[:from]) })
    add_condition(reject: [:limit, :offset],
                  condition: -> { where('created_at > ?', 1.month.ago) })
  end

  def room
    if @params[:room_type].present? && @params[:room_id].present?
      @params[:room_type].to_s.classify.constantize.find(@params[:room_id])
    end
  end
end
