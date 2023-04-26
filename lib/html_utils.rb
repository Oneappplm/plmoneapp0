module HtmlUtils
	include ActionView::Helpers::TagHelper
	include ActionView::Helpers::FormOptionsHelper
	include ActionView::Helpers::FormTagHelper
	extend self

	class << self
		include Rails.application.routes.url_helpers
	end

	def radio_toggle **options

		options[:container_class] ||= 'd-flex align-items-center my-3'
		options[:button_class] ||= 'btn btn-xs btn-toggle has-to-show to-change-value'
		options[:name] ||= ''
		options[:label] ||= ''
		options[:toshow] ||= ''

		toggle = <<-HTML
			<div class="#{ options[:container_class] }">
					<button type="button" class="#{ options[:button_class] }" data-tochange="#{ options[:name] }" data-toshow="#{ options[:toshow] }" data-toggle="button" aria-pressed="false" autocomplete="off">
								<div class="handle"></div>
					</button>

					<small class="ms-2">#{ options[:label] }</small>
			</div>
		HTML

		toggle.html_safe
	end
end