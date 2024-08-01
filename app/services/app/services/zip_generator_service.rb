require 'zip'

class ZipGeneratorService
  def self.create_zip(client)
    temp_file = Tempfile.new(["client_#{client.id}_pdfs", '.zip'])

    begin
      Zip::OutputStream.open(temp_file.path) do |zos|
        client.pdf_file_paths.each do |file_path|
          full_path = Rails.root.join('lib', 'data', file_path)
          if File.exist?(full_path)
            zos.put_next_entry(File.basename(file_path))
            zos.print IO.read(full_path)
          else
            Rails.logger.error "File not found: #{full_path}"
          end
        end
      end
      temp_file
    ensure
      temp_file.close
    end
  end
end
