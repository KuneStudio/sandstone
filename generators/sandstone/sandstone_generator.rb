module Rails
  module Generator
    module Commands
      
      class Create < Base
        def file_add_line_after(file, finder_line, added_line)
          gsub_file(file, Regexp.new('^(\s*' + finder_line + ')\s*$'),
            "\\1\n#{added_line}")
        end
      end
      
      class Destroy < RewindBase
        def file_add_line_after(file, finder_line, added_line)
          gsub_file(
            file, 
            Regexp.new('^(\s*)' + "#{added_line}" + '$'),
            '#\1\2'
          )
        end
      end
    end
  end
end

class SandstoneGenerator < Rails::Generator::Base

  def manifest
    template_dir = File.join(File.dirname(__FILE__), 'templates')
    
    record do |m|
      %w(editors page_templates pages previews sitemaps).each do |system|

        # Handle controllers and helpers
        %w(controller helper).each do |area|
          file = File.join(area.pluralize, "#{system}_#{area}.rb")
          m.file(file, File.join('app', file))
        end
                
        # Handle views
        view_dir = File.join('views', system)
        app_view_dir = File.join('app', view_dir)
        
        m.directory(app_view_dir)
        
        Dir.glob(File.join(template_dir, view_dir, '*')).each do |file|
          m.file(File.join(view_dir, File.basename(file)), 
            File.join(app_view_dir, File.basename(file)))
        end
        
      end
      
      # Handle layouts
      m.directory(File.join('app', 'views', 'layouts'))
      layout_dir = File.join('views', 'layouts')
      Dir.glob(File.join(template_dir, layout_dir, '*')).each do |file|
        m.file(File.join(layout_dir, File.basename(file)), 
          File.join('app', layout_dir, File.basename(file)))
      end
      
      # Handle models
      model_dir = File.join('models')
      Dir.glob(File.join(template_dir, model_dir, '*')).each do |file|
        m.file(File.join(model_dir, File.basename(file)), 
          File.join('app', 'models', File.basename(file)))
      end

      # Handle individual files
      m.file(File.join('sandstone.css'),
        File.join('app', '..', 'public', 'stylesheets', 'sandstone.css'))
      m.file(File.join('helpers', 'sandstone_helper.rb'),
        File.join('app', 'helpers', 'sandstone_helper.rb'))

      # Handle migrations
      Dir.glob(File.join(template_dir, 'migrate', '*')).each do |file|
        m.migration_template(
          File.join('migrate', File.basename(file)),
          'db/migrate',
          :migration_file_name => File.basename(file, '.rb')
        )
      end
    end
  end
    
end