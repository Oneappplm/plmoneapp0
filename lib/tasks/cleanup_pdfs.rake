namespace :cleanup do
  desc "Remove old generated PDFs (older than 2 days)"
  task old_pdfs: :environment do
    Dir.glob(Rails.root.join("public/generated_pdfs/*.pdf")).each do |file|
      if File.mtime(file) < 1.days.ago
        File.delete(file)
        puts "Deleted #{file}"
      end
    end
  end
end
