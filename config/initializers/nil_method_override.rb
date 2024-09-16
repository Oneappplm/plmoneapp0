if Rails.env.production?
  class NilClass
    def method_missing(method_name, *args, &block)
      nil
    end
  end
end