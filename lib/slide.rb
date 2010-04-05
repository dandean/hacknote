require 'rdiscount'

module Hacknote

  class Slide
    attr_reader :type, :raw, :html, :handler
    def initialize(content = '')
      # save raw content
      @raw = content.strip
    
      headers = []
      content = []
    
      past_headers = false
    
      @raw.split(/\n/m).each{|line|
        if !past_headers && !line.match(/^(!SLIDE|- )/)
          past_headers = true
        end
      
        if !past_headers
          headers << line.strip
        else
          content << line
        end
      }
    
      # Convert content into html
      @html = RDiscount.new(content.join("\n")).to_html
    
      # Find slide type
      @type = headers[0].match(/^!SLIDE\.\w/) ?
        headers[0].sub(/^!SLIDE\./, "") :
        "default"
    
      # Find custom handler spec
      handler = headers.find {|h| h.match(/^- \$/) }
      if !handler.nil?
        handler = handler.sub(/^- \$/, '').strip
      end
      @handler = handler
    end
  end

end

