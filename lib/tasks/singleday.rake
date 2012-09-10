namespace :singleday do

  desc "Regenerates thumbnails for a given CLASS (and optional ATTACHMENT and STYLES splitted by comma)."
  task :photo_refresh => :environment do
    errors = []
    klass = Paperclip::Task.obtain_class
    names = Paperclip::Task.obtain_attachments(klass)
    styles = (ENV['STYLES'] || ENV['styles'] || '').split(',').map(&:to_sym)
    names.each do |name|
      Paperclip.each_instance_with_attachment(klass, name) do |instance|
        instance.send(name).reprocess!(*styles)
        instance.save(:validate => false)
        errors << [instance.id, instance.errors] unless instance.errors.blank?
      end
    end
    errors.each { |e| puts "#{e.first}: #{e.last.full_messages.inspect}" }
  end

end