module Hacknote

  class Helper
    def self.has_git?
      begin
        `git --version`
        return true
      rescue Error => e
        return false
      end
    end
  
    def self.require_git
      return if has_git?
      puts "\nHacknote requires Git in order to load its dependencies."
      puts "\nMake sure you've got Git installed and in your path."
      puts "\nFor more information, visit:\n\n"
      puts "  http://book.git-scm.com/2_installing_git.html"
      exit
    end
  
    def self.htmlize(content = 'No content')
      return RDiscount.new(content).to_html
    end
  
    def self.sprocketize(options = {})
      options = {
        :destination    => File.join(SAVE_DIR , 'hacknote.js'),
        :strip_comments => true
      }.merge(options)
    
      require_sprockets
    
      Dir.mkdir(SAVE_DIR) unless File.directory?(SAVE_DIR)
    
      load_path = ['app', 'vendor']

      secretary = Sprockets::Secretary.new(
        :root           => ROOT_DIR,
        :load_path      => load_path,
        :source_files   => ['app/hacknote.js'],
        :strip_comments => options[:strip_comments]
      )
    
      secretary.concatenation.save_to(options[:destination])
    end
    
    # Builds the distribution
    def self.build
      # Concatinate the scripts to a single file
      sprocketize

      # Build
      Builder.new(SOURCE_FILE, SAVE_DIR).save
    end
    
    def self.syntax_highlighter
      if ENV['SYNTAX_HIGHLIGHTER']
        highlighter = ENV['SYNTAX_HIGHLIGHTER'].to_sym
        require_highlighter(highlighter, true)
        return highlighter
      end
    
      SYNTAX_HIGHLIGHTERS.detect { |n| require_highlighter(n) }
    end
  
    def self.require_highlighter(name, verbose=false)
      case name
      when :pygments
        success = system("pygmentize -V")
        if !success && verbose
          puts "\nYou asked to use Pygments, but I can't find the 'pygmentize' binary."
          puts "To install, visit:\n"
          puts "  http://pygments.org/docs/installation/\n\n"
          exit
        end
        return success # (we have pygments)
      when :coderay
        begin
          require 'coderay'
        rescue LoadError => e
          if verbose
            puts "\nYou asked to use CodeRay, but I can't find the 'coderay' gem. Just run:\n\n"
            puts "  $ gem install coderay"
            puts "\nand you should be all set.\n\n"
            exit
          end
          return false
        end
        return true # (we have CodeRay)
      when :none
        return true
      else
        puts "\nYou asked to use a syntax highlighter I don't recognize."
        puts "Valid options: #{SYNTAX_HIGHLIGHTERS.join(', ')}\n\n"
        exit
      end
    end
  
    def self.require_sprockets
      require_submodule('Sprockets', 'sprockets')
    end
  
    def self.get_submodule(name, path)
      require_git
      puts "\nYou seem to be missing #{name}. Obtaining it via git...\n\n"
    
      Kernel.system("git submodule init")
      return true if Kernel.system("git submodule update vendor/#{path}")
      # If we got this far, something went wrong.
      puts "\nLooks like it didn't work. Try it manually:\n\n"
      puts "  $ git submodule init"
      puts "  $ git submodule update vendor/#{path}"
      false
    end
  
    def self.require_submodule(name, path)
      begin
        require path
      rescue LoadError => e
        # Wait until we notice that a submodule is missing before we bother the
        # user about installing git. (Maybe they brought all the files over
        # from a different machine.)
        missing_file = e.message.sub('no such file to load -- ', '')
        if missing_file == path
          # Missing a git submodule.
          retry if get_submodule(name, path)
        else
          # Missing a gem.
          puts "\nIt looks like #{name} is missing the '#{missing_file}' gem. Just run:\n\n"
          puts "  $ gem install #{missing_file}"
          puts "\nand you should be all set.\n\n"
        end
        exit
      end
    end
  end

end
