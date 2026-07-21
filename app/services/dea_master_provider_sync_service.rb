# frozen_string_literal: true

class DeaMasterProviderSyncService
  FULL_SCHEDULES = %w[
    2
    2N
    3
    3N
    4
    5
  ].freeze

  def initialize(dea_numbers: nil)
    @dea_numbers = Array(dea_numbers)
      .map { |value| normalize_dea_number(value) }
      .reject(&:blank?)
      .uniq
  end

  def call
    updated = 0
    manual = 0
    skipped = 0

    provider_dea_scope.find_each do |provider_dea|
      normalized_dea =
        normalize_dea_number(provider_dea.dea_number)

      if normalized_dea.blank?
        skipped += 1
        next
      end

      master_record =
        find_master_record(normalized_dea)

      # No uploaded master record:
      # leave the manually entered ProviderDea untouched.
      unless master_record
        manual += 1

        Rails.logger.info(
          "[DEA SYNC] Manual data retained " \
          "provider_dea_id=#{provider_dea.id} " \
          "dea=#{normalized_dea}"
        )

        next
      end

      schedules =
        normalize_schedules(master_record.schedules)

      provider_dea.update!(
        state: master_record.state,
        expiration_date: master_record.expiration_date,
        schedules_held: schedules,
        full_schedule:
          full_schedule?(schedules) ? "Yes" : "No"
      )

      updated += 1

      Rails.logger.info(
        "[DEA SYNC] Uploaded data applied " \
        "provider_dea_id=#{provider_dea.id} " \
        "master_record_id=#{master_record.id} " \
        "dea=#{normalized_dea} " \
        "expiration=#{master_record.expiration_date} " \
        "schedules=#{schedules.inspect}"
      )
    rescue StandardError => e
      skipped += 1

      Rails.logger.error(
        "[DEA SYNC] Failed " \
        "provider_dea_id=#{provider_dea.id} " \
        "dea=#{provider_dea.dea_number.inspect} " \
        "error=#{e.class}: #{e.message}"
      )
    end

    {
      updated: updated,
      manual: manual,
      skipped: skipped
    }
  end

  private

  def provider_dea_scope
    scope = ProviderDea.all

    return scope if @dea_numbers.blank?

    scope.where(
      <<~SQL.squish,
        LEFT(
          UPPER(
            REGEXP_REPLACE(
              COALESCE(dea_number, ''),
              '[^A-Za-z0-9]',
              '',
              'g'
            )
          ),
          9
        ) IN (?)
      SQL
      @dea_numbers
    )
  end

  def find_master_record(normalized_dea)
    # First select the new correct nine-character record.
    exact_record =
      DeaMasterRecord.find_by(
        dea_number: normalized_dea
      )

    return exact_record if exact_record.present?

    # Temporary backward compatibility for old imports where the
    # business activity character was stored after the DEA number,
    # for example MG6295643M.
    DeaMasterRecord.where(
      <<~SQL.squish,
        LEFT(
          UPPER(
            REGEXP_REPLACE(
              COALESCE(dea_number, ''),
              '[^A-Za-z0-9]',
              '',
              'g'
            )
          ),
          9
        ) = ?
      SQL
      normalized_dea
    ).order(
      Arel.sql(
        "CASE WHEN LENGTH(dea_number) = 9 THEN 0 ELSE 1 END"
      )
    ).first
  end

  def normalize_dea_number(value)
    value.to_s
         .upcase
         .gsub(/[^A-Z0-9]/, "")
         .first(9)
  end

  def normalize_schedules(value)
    Array(value)
      .flat_map do |item|
        item.to_s.split(/[,\s]+/)
      end
      .map(&:strip)
      .reject(&:blank?)
      .select do |schedule|
        FULL_SCHEDULES.include?(schedule)
      end
      .uniq
      .sort_by do |schedule|
        FULL_SCHEDULES.index(schedule)
      end
  end

  def full_schedule?(schedules)
    (FULL_SCHEDULES - schedules).empty?
  end
end