module Hacknote

  class Builder
    attr_reader :slides, :html

    def initialize(source_path, save_path, theme = 'default')
      content = ''
      @slides = []
      
      raise ArgumentError.new('`source_path` must be specified') if source_path.nil?
      raise ArgumentError.new('`save_path` must be specified') if save_path.nil? 
      
      @source_path = source_path
      @save_path = save_path
      @theme_path = File.join(THEME_DIR, theme)
      
      raise IOError.new("Theme directory does not exist") if !File.directory?(@theme_path)

      # Open the presentation file and pull out the content
      file = File.open(source_path)
      file.each {|line| content << line }
      file.close
      
      # Search the presentation content for slides
      content.scan(/!SLIDE.+?(?=\n!SLIDE)/m){|match|
        result = match.to_s.strip
        
        # Add this slide if there is content
        if !result.empty?
          slides << Hacknote::Slide.new(result)
        end
      }
    end
    
    def to_html
      # Move theme resources into save path
      
      # Render slides as HTML
      # - Pull themes/mytheme/template.erb
      Mustache.template_path = THEME_DIR
      
      
      puts Mustache.render_file("index", :wow => "cool")
      
      # - Inject slide html into template content
      # - Return string
    end
    
    def save
      self.to_html
      # Save html to the path
      # Move theme resources into path
      # Move hacknote dependencies  into path
    end
    
  end

end
