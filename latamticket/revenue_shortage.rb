class RevenueShortage < ActiveRecord::Base
  belongs_to :revenue, inverse_of: :revenue_shortages
  belongs_to :responsible, class_name: 'CrewMember', foreign_key: :responsible_id
  attr_accessible :responsible_id, :amount
  validates_presence_of :revenue, :responsible
  validates_uniqueness_of :responsible_id, scope: :revenue_id
  validates_numericality_of :amount, greater_than_or_equal_to: 0

  delegate :member_type, to: :responsible, prefix: false
  delegate :name, to: :responsible, prefix: false
  delegate :rut, to: :responsible, prefix: false
  delegate :full_id, to: :responsible, prefix: false

  def make_register_movement register_id
    cash_register_movement = CashRegisterMovement.create(amount: -amount, movement_type: "SHORTAGE",
                                cash_register_id: register_id, detail_id: id,
                                detail_type: "RevenueShortage")
    if cash_register_movement.errors.any?
      cash_register_movement.errors.each do |attribute, message|
        errors.add("cash_register_movement.#{attribute}", message)
      end
    end
  end
end
