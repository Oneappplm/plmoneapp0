class DeaMasterRecord < ApplicationRecord
  scope :matching_dea, ->(dea_number) {
    normalized =
      dea_number.to_s
                .upcase
                .gsub(/[^A-Z0-9]/, "")
                .first(9)

    where(
      "LEFT(UPPER(REGEXP_REPLACE(COALESCE(dea_number, ''), '[^A-Za-z0-9]', '', 'g')), 9) = ?",
      normalized
    )
  }
end