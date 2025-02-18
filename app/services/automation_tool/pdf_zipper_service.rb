class AutomationTool::PdfZipperService < ApplicationService
  PDF_FOLDER = Rails.root.join('public', 'autopopulate_providers_output').to_s
  ZIP_FILE_PATH = Rails.root.join('public', 'autopopulate_providers_output.zip')

  def self.create_zip
    # Ensure old zip file is deleted before creating a new one
    File.delete(ZIP_FILE_PATH) if File.exist?(ZIP_FILE_PATH)

    # Fetch only the actual PDF files in the folder
    pdf_files = Dir.entries(PDF_FOLDER).select { |f| f.end_with?('.pdf') }

    # Debugging: Print filenames before zipping
    puts "Zipping these files: #{pdf_files.inspect}"

    # Create a new ZIP file
    Zip::File.open(ZIP_FILE_PATH, Zip::File::CREATE) do |zipfile|
      pdf_files.each do |filename|
        file_path = File.join(PDF_FOLDER, filename)

        # Add only valid files
        zipfile.add(filename, file_path) if File.file?(file_path)
      end
    end

    ZIP_FILE_PATH
  end
  
  def self.clean_up
    # Delete only the PDFs that exist in the actual folder
    Dir.entries(PDF_FOLDER).each do |filename|
      file_path = File.join(PDF_FOLDER, filename)
      File.delete(file_path) if filename.end_with?('.pdf') && File.file?(file_path)
    end
  end
end