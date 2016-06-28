class Transaction < ApplicationRecord
  belongs_to :exchequer
  belongs_to :corresponding_exchequer, class_name: 'Exchequer'

  def description
    if corresponding_exchequer.nil?
      I18n.t('transaction.manual')
    else
      corresponding_exchequer.exchequerable.to_s
    end
  end
end
