class BaseFilter
  def initialize(model_class, params)
    @model_class = model_class
    @filter_list = []
    @params = params
  end

  #
  # condition is a hash of the following structure:
  # :required - condition will be applied when all fields present in params
  # :reject - condition will be applied when  no field presents in params
  # :condition - lambda to execute in the context of model class
  def add_condition(condition)
    @filter_list << condition
  end

  def filter
    query = @model_class
    @filter_list.each do |filter_item|
      if should_apply_condition(filter_item)
        query = query.class_exec(&filter_item[:condition])
      end
    end
    query.all
  end

  private

  def should_apply_condition(filter_item)
    param_presence = ->(param) { @params[param].present? }
    if filter_item.key?(:required)
      [filter_item[:required]].flatten.map(&param_presence).reduce(:&)
    elsif filter_item.key?(:reject)
      ![filter_item[:reject]].flatten.map(&param_presence).reduce(:|)
    else
      true
    end
  end
end
