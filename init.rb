require 'redmine'

require_dependency 'patches/attachments_patch'
require_dependency 'hooks/view_layouts_base_html_head_hook'

Redmine::Plugin.register :redmine_lightbox2 do
  name 'Redmine Lightbox 2'
  author 'Tobias Fischer'
  description 'This plugin lets you preview image and pdf attachments in a lightbox.'
  version '0.5.1'
  url 'https://github.com/paginagmbh/redmine_lightbox2'
  author_url 'https://github.com/tofi86'
  requires_redmine :version_or_higher => '4.0'
end



# Patches to the Redmine core.
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3

if Rails::VERSION::MAJOR >= 5
  ActiveSupport::Reloader.to_prepare do
    require_dependency 'attachments_controller'
    AttachmentsController.send(:include, RedmineLightbox2::AttachmentsPatch)
  end
elsif Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require_dependency 'attachments_controller'
    AttachmentsController.send(:include, RedmineLightbox2::AttachmentsPatch)
  end
else
  Dispatcher.to_prepare do
    require_dependency 'attachments_controller'
    AttachmentsController.send(:include, RedmineLightbox2::AttachmentsPatch)
  end
end

# Append thumbnails_index_size to settings.yml
settings_path = Rails.root.join('config', 'settings.yml')
settings = File.read settings_path
settings = YAML.load settings

unless settings['thumbnails_index_size']
  settings['thumbnails_index_size'] = { 'format': 'int', 'default': 100 }
  output = YAML.dump settings
  File.write(settings_path, output)
end

# Append translates to ru.yml
translates_path = Rails.root.join('config', 'locales', 'ru.yml')
translates = File.read translates_path
translates = YAML.load translates

unless translates['ru']['setting_thumbnails_index_size']
  translates['ru']['setting_thumbnails_index_size'] = 'Размер первью в таблице (в пикселях)'
  output = YAML.dump translates
  File.write(translates_path, output)
end
