module PriceListUpdater
  extend ActiveSupport::Concern
  included do
    before_save :set_price_list
  end

  def self.included base
    class << base
      @@price_list_order = nil

      def price_list_search_order price_list_order
        @@price_list_order = price_list_order
      end
    end
  end


  def used_price_list
    if self.active_price_list.nil?
      @@price_list_order.each do |price_list_key|
        obj = self.send(price_list_key)
        return obj.active_price_list unless obj.active_price_list.nil?
      end
      return PriceList.find_first_by_active active: true
    else
     self.active_price_list
    end
  end

  def set_price_list
    price_list_changed = self.changed_attributes.has_key?("active_price_list_id")
    if price_list_changed
      success = false
      self.transaction do
        price_list = used_price_list
        price_list.update_or_create_itineraries_prices(self.class.to_s.underscore.to_sym => self.id).each do |message|
          self.errors[:base] << message
        end.empty? ? success = true : raise(ActiveRecord::Rollback)
      end
      success
    end
  end
end