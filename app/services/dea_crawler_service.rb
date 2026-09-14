class DeaCrawlerService
  def initialize(dea_record:, provider_dea:)
    @dea_record = dea_record
    @provider_dea = provider_dea
  end

  def run
    bot = WebcrawlerBot.new(
      dea_number: @dea_record.dea_number,
      name: @dea_record.name,
      address1: @dea_record.address1,
      address2: @dea_record.address2,
      city: @dea_record.city,
      state: @dea_record.state,
      zip: @dea_record.zip,
      degree: @dea_record.degree,
      status: @dea_record.status,
      expiration_date: @dea_record.expiration_date
    )

    bot.capture  # returns path of generated screenshot/pdf
  end
end
