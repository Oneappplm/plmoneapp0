class Visit < Ahoy::Event

  def self.firefox_count
    Visit.where_props(browser: "Firefox").count
  end

  def self.safari_count
    Visit.where_props(browser: "Safari").count
  end

  def self.chrome_count
    Visit.where_props(browser: "Chrome").count
  end

  # this is verification platform
  # month here is number like 6 for June or 1 for January
  def self.hvhs_count(month)
    Visit.where_props(controller: "verification_platform").where("EXTRACT(MONTH FROM time) = ?", month).count
  end

  def self.bcbh_count(month)
    Visit.where_props(controller: "verification_platform").where("EXTRACT(MONTH FROM time) = ?", month).count
  end

  def self.fch_count(month)
    Visit.where_props(controller: "verification_platform").where("EXTRACT(MONTH FROM time) = ?", month).count
  end

  def self.ochn_count(month)
    Visit.where_props(controller: "verification_platform").where("EXTRACT(MONTH FROM time) = ?", month).count
  end

  def self.mcchnqa_count(month)
    Visit.where_props(controller: "verification_platform").where("EXTRACT(MONTH FROM time) = ?", month).count
  end
end