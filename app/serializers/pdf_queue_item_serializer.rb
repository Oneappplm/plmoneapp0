# app/serializers/pdf_queue_item_serializer.rb
class PdfQueueItemSerializer < ActiveModel::Serializer
  attributes :id, :file_name, :file_path, :status, :message, :created_at, :updated_at
end
