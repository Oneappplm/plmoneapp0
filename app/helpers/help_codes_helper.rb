module HelpCodesHelper
  def table_view?
    params.dig(:view).present? && params.dig(:view) == "table"
  end

  def list_view?
    params.dig(:view).blank? || (params.dig(:view).present? && params.dig(:view) == "list")
  end
end
