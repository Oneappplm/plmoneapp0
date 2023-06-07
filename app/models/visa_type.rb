class VisaType < ApplicationRecord
  default_scope { order(:name)}

  def self.generate_visas
    visas = [ 
              'A-1', 'A-2', 'A-3', 'B-1', 'B-2', 'C-1', 'C-2', 'C-3', 'C-4', 'D-1', 'D-2', 'E-1', 'E-2', 'E-3', 'F-1', 'F-2', 'G-1', 'G-2', 'G-3', 'G-4', 'G-5', 'H-1B', 'H-1C', 'H-2A', 'H-2B', 'H-3', 'H-4', 'I', 'J-1', 'J-2', 'L-1', 'L-2', 'M-1', 'M-2', 'NATO 1-7', 'O-1', 'O-2', 'O-3', 'P-1', 'P-2', 'P-3', 'P-4', 'Q-1', 'Q-2', 'Q-3', 'R-1', 'R-2', 'TD', 'TN-1', 'WB', 'WT'
            ]
    visas.each do |visa|
      VisaType.find_or_create_by(name: visa.strip)
    end
  end
end