#frozen_string_literal: true

namespace :help_codes do
  desc "Add default help codes"
  task :seed_data => :environment do
   Import::HelpCodesService.call(Rails.root.join('lib', 'data', 'help_codes.csv')) 
  end
 end
 