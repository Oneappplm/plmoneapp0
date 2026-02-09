# app/helpers/ai_queries_helper.rb

module AiQueriesHelper
  def display_value(record, column)
    case record
    when User
      display_user_value(record, column)
    else
      display_provider_value(record, column)
    end
  end

  private

  # -----------------------------
  # USER RECORDS
  # -----------------------------
  def display_user_value(user, column)
    case column
    when :first_name then user.first_name
    when :last_name  then user.last_name
    when :email      then user.email
    when :user_role  then user.user_role
    else
      user.respond_to?(column) ? user.public_send(column) : "—"
    end
  end

  # -----------------------------
  # PROVIDER-RELATED RECORDS
  # -----------------------------
  def display_provider_value(record, column)
    provider =
      record.respond_to?(:provider_attest) ?
        record.provider_attest&.provider_personal_informations&.first :
        nil

    case column
    when :provider_name
      provider ? "#{provider.first_name} #{provider.last_name}" : "—"

    when :first_name
      provider&.first_name || "—"

    when :last_name
      provider&.last_name || "—"

    when :expiration_date
      record.respond_to?(:expiration_date) ? record.expiration_date : "—"

    when :license_type
      @license_type || "—"

    else
      record.respond_to?(column) ? record.public_send(column) : "—"
    end
  end
end
