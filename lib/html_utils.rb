module HtmlUtils
	include ActionView::Helpers::TagHelper
	include ActionView::Helpers::FormOptionsHelper
	include ActionView::Helpers::FormTagHelper
	extend self

	class << self
		include Rails.application.routes.url_helpers
	end

	def radio_toggle **options
    options[:margin_y] || 'my-3'
		options[:container_class] ||= "d-flex align-items-center #{options[:margin_y]}"
		options[:button_class] ||= 'btn btn-xs btn-toggle has-to-show to-change-value has-to-hide'
		options[:name] ||= ''
		options[:label] ||= ''
		options[:toshow] ||= ''
    options[:tohide] ||= ''

		toggle = <<-HTML
			<div class="#{ options[:container_class] }">
        <button type="button" class="#{ options[:button_class] }" data-tochange="#{ options[:name] }" data-toshow="#{ options[:toshow] }" data-toggle="button" aria-pressed="false" autocomplete="off" data-tohide="#{options[:tohide]}">
          <div class="handle"></div>
        </button>
        <small class="ms-2 fw-semibold text-dark-grey">#{ options[:label] }</small>
			</div>
		HTML

		toggle.html_safe
	end

  def radio_options **options

    options[:label_class] ||= 'form-label'
		options[:container_class] ||= 'd-flex me-4 gap-2'
    options[:name] ||= ''
		options[:label] ||= ''
    options[:value_on] ||= 'yes'
    options[:value_off] ||= 'no'

    option = <<-HTML
      <label class="#{ options[:label_class] }"> #{ options[:label] } </label>
      <div class="#{ options[:container_class] }">
          <span>
          <input type="radio" value="#{ options[:value_on] }" name="#{ options[:name] }" required>
          <span>#{ options[:value_on].upcase }</span>
          </span>
          <span>
          <input type="radio" value="#{ options[:value_off] }" name="#{ options[:name] }" required>
          <span>#{ options[:value_off].upcase }</span>
          </span>
        </div>
    HTML

    option.html_safe
  end

  def generate_view_link **options

   options[:file_url] ||= nil
   options[:link_class] ||= 'btn btn-outline-primary btn-sm mt-2 fw-semibold'

   html = if options[:file_url].present?
      <<-HTML
        <a href="#{ options[:file_url] }" target="_blank" class="#{ options[:link_class] }">View File</a>
      HTML
   else
      <<-HTML
        <span class="text-muted">No File Uploaded</span>
      HTML
   end

   html.html_safe
  end

  def form_add_required_attribute **options
    options[:form_id] ||= ''
    options[:required_fields] ||= ''

    script = <<-HTML
    <script>
      $(document).ready(function(){
        addRequiredAttribute('#{ options[:form_id] }', '#{ options[:required_fields] }')
      });
    </script>
    HTML

    script.html_safe
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

  def two_column_with_yes **options
    columns = <<-HTML
    <div class="row g-0 border-bottom border-dark">
      <div class="col-lg-11">
        <div class="row g-0">
          <div class="col-lg-12 border-bottom border-dark #{options[:height].present? ? options[:height] : ''}">
            <span>#{options[:text1]}</span>
          </div>
          <div class="col-lg-12 h-50px">
            <span>#{options[:text2].present? ? options[:text2] : 'Please provide explanation below:'}</span>
            <p class="text-center">
              <strong>
                #{options[:explanation]}
              </strong>
            </p>
          </div>
        </div>
      </div>
      <div class="col-lg-1 border-start border-dark d-flex justify-content-center align-items-center">
        <span>
          <!-- answer is from the disclosures from provider app they meta_key as q1 to q26 -->
          #{options[:answer]}
        </span>
      </div>
    </div>
    HTML
    columns.html_safe
  end

end