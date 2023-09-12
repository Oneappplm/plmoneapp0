module HtmlUtils
  include ApplicationHelper
	include ActionView::Helpers::TagHelper
	include ActionView::Helpers::FormOptionsHelper
	include ActionView::Helpers::FormTagHelper
  include Rails.application.routes.url_helpers
	extend self

	def radio_toggle **options
    options[:active] ||= ''
		options[:container_class] ||= "d-flex align-items-center"
		options[:button_class] ||= "btn btn-xs btn-toggle has-to-show to-change-value has-to-hide #{options[:active]}"
		options[:name] ||= ''
		options[:label] ||= ''
		options[:toshow] ||= ''
    options[:tohide] ||= ''
    options[:hidden_field] ||= false
    options[:data] ||= current_provider_source.finder(options[:name])
    options[:data_value] ||= 'no'

		toggle = <<-HTML
			<div class="#{ options[:container_class] }">
        <button type="button" class="#{ options[:button_class] } #{ options[:data]&.active_class }" data-tochange="#{ options[:name] }" data-toshow="#{ options[:toshow] }" data-toggle="button" aria-pressed="false" autocomplete="off" data-tohide="#{options[:tohide]}">
          <div class="handle"></div>
        </button>
        <small class="ms-2 fw-semibold text-dark-grey">#{ options[:label] }</small>
			</div>
		HTML

    if options[:hidden_field]
      toggle += <<-HTML
        <input type="hidden" id="#{ options[:name] }" name="#{ options[:name] }" value="#{ options[:data]&.data_value || options[:data_value] }">
      HTML
    end

		toggle.html_safe
	end


  def radio_options **options

    options[:label_class] ||= 'form-label'
		options[:container_class] ||= 'd-flex me-4 gap-2'
    options[:name] ||= ''
		options[:label] ||= ''
    options[:value_on] ||= 'yes'
    options[:value_off] ||= 'no'
    options[:to_show] ||= ''
    options[:required] ||= false

    option = <<-HTML
      <label class="#{ options[:label_class] }"> #{ options[:label] } </label>
      <div class="#{ options[:container_class] }">
          <span>
          <input type="radio" value="#{ options[:value_on] }" name="#{ options[:name] }" #{ options[:required] ? 'required' : '' } >
          <span>#{ options[:value_on].upcase }</span>
          </span>
          <span>
          <input type="radio" value="#{ options[:value_off] }" name="#{ options[:name] }" #{ options[:required] ? 'required' : '' } >
          <span>#{ options[:value_off].upcase }</span>
          </span>
        </div>
    HTML

    if options[:to_show].present?
      option += <<-HTML
        <script>
          $(document).ready(function(){
            $('input[name="#{ options[:name] }"]').change(function(){
              var value = $(this).val();

              if(value == '#{ options[:value_on] }'){
                $('##{ options[:to_show] }').show();
              }else{
                $('##{ options[:to_show] }').hide();
              }
            });

            $('input[name="#{ options[:name] }"]').trigger('change');
          });
        </script>
      HTML
    end

    option.html_safe
  end

  def dropdown **options
    options[:label] ||= ''
    options[:multiple] ||= false
    options[:name] ||= ''

    value = options[:value]


    dropdown_class = ['form-select']
    if value.nil?
      dropdown_class << 'border-dark'
    elsif value.to_s.strip.blank?
      dropdown_class << 'border-danger'
    else
      dropdown_class << 'border-dark'
    end

    option = <<-HTML
      <label class="text-dark-grey">#{options[:label]}</label>
      <div class="#{options[:multiple] ? 'multi' : 'single'}-select multi-select-#{options[:name]} #{dropdown_class.join(' ')}" name="#{options[:name]}" id="#{options[:name]}" placeholder="#{options[:label]}" ></div>
    HTML

    option.html_safe
  end

  def virtual_select **options
    options[:collection] ||= []
    options[:id] ||= ''
    options[:search] ||= true
    options[:hide_clear_button] ||= true
    options[:multiple] ||= false
    options[:mark_search_results] ||= true
    options[:show_value_as_tags] ||= false
    options[:selected_value] ||= ''

    script = <<-HTML
      <script>
        $(document).ready(function(){
          var collection = '#{ options[:collection] }';
          VirtualSelect.init({
            ele: '##{ options[:id]}',
            options: collection,
            search: '#{ options[:search] }',
            hideClearButton: '#{ options[:hide_clear_button] }',
            multiple: '#{ options[:multiple] }',
            markSearchResults: '#{ options[:mark_search_results] }',
            showValueAsTags: '#{ options[:show_value_as_tags] }',
            selectedValue: '#{ options[:selected_value] }'
          });
        });
      </script>
    HTML

    script.html_safe
  end

  def generate_view_link **options

   options[:file_url] ||= nil
   options[:link_class] ||= 'btn btn-outline-primary btn-sm py-1 mt-2 fw-semibold'
   options[:link_title] ||= 'View Uploaded file'
   options[:remove_icon] ||= false

   html = if options[:file_url].present?
      <<-HTML
        <a href="#{ options[:file_url] }" target="_blank" class="#{ options[:link_class] }">
          #{ options[:link_title] }
          #{ if options[:remove_icon] then '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" onclick="removeFile(this, event)" stroke="currentColor" style="height: 15px; color: red; margin-left: 4px;"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>' end }
        </a>
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
          <h3 class="p-1">#{options[:title]}</h3>
        </div>
      </div>
    HTML
    header.html_safe
  end

  def table_sub_section_header **options
    header = <<-HTML
      <div class="row g-0 border-bottom border-dark">
        <div class="col-lg-12">
          <h5 class="p-1">#{options[:title]}</h5>
        </div>
      </div>
    HTML
    header.html_safe
  end

  def single_column **options
    column = <<-HTML
    <div class="row g-0 #{options[:is_last_field] == true ? '' : 'border-bottom'} border-dark">
      <div class="col-lg-12 p-1 #{options[:height]}">
        <span>#{options[:title]}</span>
        <p class="m-0">
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
        <span class="p-1">#{options[:title]}</span>
        <p class="m-0 p-1">
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
    <div class="row g-0 #{options[:is_last_field] ? '' : 'border-bottom'} border-dark">
      <div class="col-lg-11">
        <div class="row g-0">
          <div class="col-lg-12 p-1 border-bottom border-dark #{options[:height].present? ? options[:height] : ''}">
            <span>#{options[:text1]}</span>
          </div>
          <div class="col-lg-12 h-50px">
            <span class="p-1">#{options[:text2].present? ? options[:text2] : 'Please provide explanation below:'}</span>
            <p class="p-1">
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

  def multi_select_dropdown **options
    multi_select = <<-HTML
      <div class="multi-select form-control border border-dark #{options[:classes]}" name="#{options[:name]}" id="#{options[:id]}">
      </div>
    HTML

    multi_select.html_safe
  end

  def multiple_file_uploads **options
    return unless options[:model].present?

    options[:input_field_name] ||= ''
    options[:input_model_name] ||= options[:model].class.name.downcase
    options[:input_field_label] ||= options[:input_field_name].titleize
    options[:input_field_placeholder] ||= options[:input_field_label]
    options[:input_field_css_class] ||= 'form-control border border-dark'
    options[:anchor_link] ||= nil
    options[:anchor_target] ||= '_blank'
    options[:anchor_label] ||= 'download template here'

    input_file_name = "#{ options[:input_model_name] }[#{ options[:input_field_name] }][]"

    html = <<-HTML
        <label>
          #{ options[:input_field_label] }
      HTML

    if options[:anchor_link].present?
      html += <<-HTML
          <a href="#{ options[:anchor_link] }" target="#{ options[:anchor_target] }">#{ options[:anchor_label] }</a>
        HTML
    end

    html += <<-HTML
        </label>
        <input name="#{ input_file_name }" type="hidden" value="" autocomplete="off">
        <input placeholder="#{ options[:input_field_placeholder] }" class="#{ options[:input_field_css_class] }" multiple="multiple" type="file" name="#{ input_file_name }">
      HTML

    if options[:model].send(options[:input_field_name]).present? && !options[:model].send('pending_submitted_documents').include?(options[:input_field_name])
      html += <<-HTML
        <div class="d-flex gap-2">
      HTML
      options[:model].send(options[:input_field_name]).each do |file|
        html += <<-HTML
          <div class="upload-file">
            <input multiple="multiple" value="#{ file.identifier }" autocomplete="off" type="hidden" name="#{ input_file_name }">
            #{ generate_view_link(file_url: file.url, link_title: file.identifier, remove_icon: true) }
          </div>
        HTML
      end
      html += <<-HTML
        </div>
      HTML
    else
      html += <<-HTML
        <span class="text-muted">No File Uploaded</span>
      HTML
    end

    html.html_safe
  end
end