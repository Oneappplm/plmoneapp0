class ChangePriceScaleInVerificationProducts < ActiveRecord::Migration[7.0]
  def change
    change_column :verification_products, :price, :decimal, precision: 12, scale: 6
  end
end
