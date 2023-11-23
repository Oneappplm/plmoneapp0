class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
		include ActionView::Helpers::TextHelper

  class << self
    def enum_list(enum)
      send(enum).map {|key, value| [filtered_display(key), send(enum).key(value)]}
    end
    def filtered_display(key)
      key.titleize
    end
  end
end
