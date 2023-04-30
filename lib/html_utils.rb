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


  # View Summary Elements

  def table_section_header **options
    header = <<-HTML
      <div class="row g-0 border-bottom border-dark">
        <div class="col-lg-12">
          <h3>#{options[:title]}</h3>
        </div>
      </div>
    HTML
    header.html_safe
  end

  def table_sub_section_header **options
    header = <<-HTML
      <div class="row g-0 border-bottom border-dark">
        <div class="col-lg-12">
          <h5>#{options[:title]}</h5>
        </div>
      </div>
    HTML
    header.html_safe
  end

  def single_column **options
    column = <<-HTML
    <div class="row g-0 border-bottom border-dark">
      <div class="col-lg-12 #{options[:height]}">
        <span>#{options[:title]}</span>
        <p class="text-center m-0">
          <strong>#{options[:value]}</strong>
        </p>
      </div>
    </div>
    HTML
    column.html_safe
  end

  def table_column **options
    column = <<-HTML
      <div class="col-lg-#{options[:size]} #{options[:last] ? '' : 'border-end border-dark'} #{options[:height]}">
        <span>#{options[:title]}</span>
        <p class="text-center m-0">
          <strong>#{options[:value]}</strong>
        </p>
      </div>
    HTML
    column.html_safe
  end

  def summary_footer **options
    footer = <<-HTML
      <div class="row g-0 mt-3">
        <div class="col-lg-2">
          <p class="text-black">Page #{options[:page]} of 16</p>
        </div>
        <div class="col-lg-10">
          <p class="text-black"><strong>Modification to the wording or format of the Provider Application may invalidate the application.</strong></p>
        </div>
      </div>
    HTML
    footer.html_safe
  end

end