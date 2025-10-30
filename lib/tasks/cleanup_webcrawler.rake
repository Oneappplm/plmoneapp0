# lib/tasks/cleanup_webcrawler.rake
namespace :cleanup do
  desc "Delete old or temporary screenshot and PDF files from /public/webscrape"
  task old_webcrawler_files: :environment do
    base_path = Rails.root.join('public', 'webscrape')

    puts "🧹 Cleaning up old webcrawler files from: #{base_path}"

    if Dir.exist?(base_path)
      deleted_files = 0

      Dir.glob("#{base_path}/**/*.{png,pdf}").each do |file|
        begin
          File.delete(file)
          deleted_files += 1
          puts "🗑️ Deleted: #{file}"
        rescue => e
          puts "⚠️ Failed to delete #{file}: #{e.message}"
        end
      end

      puts "✅ Cleanup complete. Total deleted: #{deleted_files} files."
    else
      puts "⚠️ Directory not found: #{base_path}"
    end

    # Optional: cleanup old WebcrawlerLog entries (older than 7 days)
    if defined?(WebcrawlerLog)
      old_logs = WebcrawlerLog.where("created_at < ?", 7.days.ago)
      count = old_logs.count
      old_logs.delete_all
      puts "🧾 Deleted #{count} old WebcrawlerLog entries (older than 7 days)."
    end
  end

  desc "Delete old uploads not in any active queue"
  task old_uploads: :environment do
    uploads_dir = Rails.root.join("public", "uploads")
    used_paths = PdfQueueItem.pluck(:file_path).compact.map { |p| p.sub(%r{^/}, "") }

    Dir.glob("#{uploads_dir}/**/*").each do |path|
      next if File.directory?(path)

      relative = Pathname.new(path).relative_path_from(Rails.root.join("public")).to_s
      unless used_paths.include?(relative)
        File.delete(path)
        Rails.logger.info "🗑️ Deleted old file: #{relative}"
      end
    end

    # remove empty folders
    Dir.glob("#{uploads_dir}/**/*").select { |d| File.directory?(d) && (Dir.children(d).empty?) }.each do |dir|
      Dir.rmdir(dir)
      Rails.logger.info "🧹 Removed empty folder: #{dir}"
    end
end
