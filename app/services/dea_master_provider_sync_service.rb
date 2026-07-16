class DeaMasterProviderSyncService
  FULL_SCHEDULES = %w[2 2N 3 3N 4 5].freeze

  def initialize(dea_numbers: nil)
    @dea_numbers = Array(dea_numbers).map { |value| normalize(value) }.reject(&:blank?)
  end

  def call
    scope = DeaMasterRecord.all
    scope = scope.where(dea_number: @dea_numbers) if @dea_numbers.present?

    updated = 0
    skipped = 0

    scope.find_each do |master_record|
      normalized_dea = normalize(master_record.dea_number)
      next if normalized_dea.blank?

      provider_deas = ProviderDea.where(
        "UPPER(REGEXP_REPLACE(COALESCE(dea_number, ''), '[^A-Za-z0-9]', '', 'g')) = ?",
        normalized_dea
      )

      if provider_deas.none?
        skipped += 1
        next
      end

      provider_deas.find_each do |provider_dea|
        schedules = normalize_schedules(master_record.schedules)

        provider_dea.update!(
          state: master_record.state.presence,
          expiration_date: master_record.expiration_date,
          schedules_held: schedules,
          full_schedule: full_schedule?(schedules) ? "Yes" : "No"
        )

        updated += 1
      end
    end

    {
      updated: updated,
      skipped: skipped
    }
  end

  private

  def normalize(value)
    value.to_s.upcase.gsub(/[^A-Z0-9]/, "")
  end

  def normalize_schedules(value)
    value.to_s
         .split(/[,\s]+/)
         .map(&:strip)
         .reject(&:blank?)
         .uniq
  end

  def full_schedule?(schedules)
    (FULL_SCHEDULES - schedules).empty?
  end
end