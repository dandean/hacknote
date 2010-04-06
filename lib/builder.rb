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
      @theme = theme
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
      
      # concatinate all slide html
      content = ''
      @slides.each{|s|
        content << "\n<div class='slide' data-type='#{s.type}' data-handler='#{s.handler}'>\n"
        content << "<div class='content'>"
        content << s.html.strip
        content << "\n</div>\n"
        content << "\n</div>\n"
      }
      
      # inject data into html
      return Mustache.render_file("index", {
        :theme => @theme,
        :content => content
      })
    end
    
    def save
      # Move theme resources into path
      cp_r(@theme_path, @save_path)

      # Save html to the path
      File.open(File.join(@save_path, 'index.html'), 'w'){|f| f.write(self.to_html) }
    end
    
  end

end
