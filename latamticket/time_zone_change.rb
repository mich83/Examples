class TimeZoneChange < ActiveRecord::Base
  belongs_to :base_agency
  attr_accessible :start_date_utc, :start_time_utc, :zone, :base_agency_id, :start_date

  validates_presence_of :base_agency_id, :start_date_utc, :start_time_utc, :zone
  validate :date_and_time_should_be_valid

  def start_date
    DateTime.parse(start_date_utc).strftime("%d/%m/%Y")
  end

  def start_date=(date)
    begin
      self.start_date_utc = DateTime.parse(date).strftime('%Y-%m-%d')
    rescue ArgumentError => e
      self.start_date_utc = nil
    end
  end

  def is_start_date_valid?
    true && Date.strptime(start_date_utc, '%Y-%m-%d') rescue false
  end

  def is_start_time_valid?
    true && Time.strptime(start_time_utc, '%H:%M') rescue false
  end


  def date_and_time_should_be_valid
    unless is_start_date_valid?
      errors.add(:start_date_utc, I18n.t('errors.messages.wrong_date'))
    end

    unless is_start_time_valid?
      errors.add(:start_time_utc, I18n.t('errors.messages.wrong_time'))
    end
  end

  def self.all_zones
    ActiveSupport::TimeZone.all.map(&:utc_offset).uniq.map{|z| {label: "UTC %02d:%02d" % [z/3600, (z/60) % 60], value: z}}
  end

end
