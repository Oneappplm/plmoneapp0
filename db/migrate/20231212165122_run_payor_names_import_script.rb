class RunPayorNamesImportScript < ActiveRecord::Migration[7.0]
  def change
		Import::PayorNamesService.call(Rails.root.join('lib', 'data', 'payor_list.xlsx'))
  end
end
