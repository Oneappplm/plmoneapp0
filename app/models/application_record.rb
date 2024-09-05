class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  include ActionView::Helpers::TextHelper
  include CsvAttributesAssignment
  # audited

  class << self
    def enum_list(enum)
      send(enum).map {|key, value| [filtered_display(key), send(enum).key(value)]}
    end
    def filtered_display(key)
      key.titleize
    end
  end

  def self.ransackable_associations(auth_object = nil)
    @ransackable_associations ||= reflect_on_all_associations.map { |a| a.name.to_s }
  end

  def self.ransackable_attributes(auth_object = nil)
    @ransackable_attributes ||= column_names + _ransackers.keys + _ransack_aliases.keys + attribute_aliases.keys
  end
end
