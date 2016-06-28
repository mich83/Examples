class TransactionFilter < BaseFilter
  def initialize(user, params)
    super Transaction, params
    build_global_conditions(user.exchequer)
    build_conditions(params)
  end

  def build_global_conditions(exchequer)
    add_condition(condition: lambda do
                               where(exchequer: exchequer)
                               .select(:resource_kind,
                                       :value,
                                       :corresponding_exchequer_id,
                                       'date_trunc(\'minute\', created_at) as created_at',
                                       :id)
                               .order(created_at: :desc)
                             end)
  end

  def filter_grouped
    groups = filter.all.group_by do |obj|
      [obj.description, obj.created_at].join('::')
    end
    groups.map do |_, v|
      {
        description: v.first.description,
        created_at: v.first.created_at,
        resources: Hash[v.map do |r|
          [r.resource_kind, r.value]
        end]
      }
    end
  end

  def build_conditions(params)
    add_condition(required: :limit,  condition: -> { limit(params[:limit]) })
    add_condition(required: :offset, condition: -> { offset(params[:offset]) })
    add_condition(reject: [:limit, :offset],
                  condition: -> { where('created_at > ?', 24.hours.ago) })
  end
end
