class RunBoardNamesImportScript < ActiveRecord::Migration[7.0]
  def change
    Import::BoardNamesService.call(Rails.root.join('lib', 'data', 'board_names.xlsx'))
  end
end
