# TODO: update the "build" method so that it merges
# the specified presentation with its theme, and saves it into the 
# presentations folder.
# => merge media directories (fonts is a subdirectory)
# => merge stylesheets: system, theme, local
# => SPROCKETIZE: concatinate scripts: system, theme, local

# TODO:
# => fix vendor & require mess
# => switch to emile for animations
# => syntax highlighting (pygments)


module Hacknote

  class Helper
    
    # Creates a url-safe path from a string
    def self.pathize(value)
      # replace repeating spaces & dashes with an underscore
      # remove all non-word chars
      # replace underscores with dashes
      value.strip.downcase.gsub(/[\s-]+/, '_').gsub(/\W/, '').gsub(/_/, '-')
    end
    
    # Returns a unique version of the given path, ie, my-path -> "my-path-1"
    def self.unique_path(path)
      unique = path
      i = 0;
      while File.directory?(unique)
        i = i.succ
        unique = "#{path}-#{i.succ}"
        raise NameError, 'There are already at least 20 of these' if i >= 20
      end
      unique
    end
    
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
    
    # => MOVE THIS TO BUILDER
    def self.sprocketize(name, options = {})
      # Concatinate scripts:
      # => system, theme, local
      #
      # load project yaml to get theme
      # add project and theme script dirs to load path
      #
      # app/hacknote.js:
      # require <theme>
      # require <project>

      options = {
        :destination    => File.join(project_save_path , 'hacknote.js'),
        :strip_comments => true
      }.merge(options)
    
      # require_sprockets
    
      Dir.mkdir(OUTPUT_DIR) unless File.directory?(OUTPUT_DIR)
      
      # => add theme script path
      # => add workspace script path
      load_path = ['app', 'vendor']

      secretary = Sprockets::Secretary.new(
        :root           => ROOT_DIR,
        :load_path      => load_path,
        :source_files   => ['app/hacknote.js'],
        :strip_comments => options[:strip_comments]
      )
    
      secretary.concatenation.save_to(options[:destination])
    end
    
    def self.list(dev=true)
      dir = (dev) ? WORKSPACE_DIR : OUTPUT_DIR
      Dir.entries(dir).select do |d|
        d.match(/^\w/)
      end
    end
    
    def self.create(name = nil, theme = nil)
      name = 'Untitled Hacknote' if name.nil?
      theme = 'default' if theme.nil?
      
      path = File.join(WORKSPACE_DIR, pathize(name))
      path = unique_path(path)
      
      if File.directory?(File.join(THEME_DIR, theme))
        
        libpath = File.join(LIB_DIR, 'base')
        
        # Make sure the base template exists
        if File.directory?(libpath)

          # Once path and theme are found, build stuff
          File::makedirs(path)
          
          # copy libpath contents into presentation
          cp_r("#{libpath}/.", path, :verbose => false)
          
          # inject info into the yaml file
          metapath = File.join(path, 'meta.yml')
          
          yaml = YAML.load_file(metapath)
          yaml['theme'] = theme
          yaml['title'] = name
          yaml['author'] = `git config --get user.name`.strip
          yaml['email'] = `git config --get user.email`.strip
          
          File.open(metapath, File::CREAT|File::TRUNC|File::RDWR, 0777) do |f|
            f.write(YAML.dump(yaml))
          end

        else
          raise NameError, "Cannot find base presentation files."
        end
        
      else
        raise NameError, "Unknown theme '#{theme}'."
      end
    end
    
    # Builds the distribution
    def self.build(project = 1)
      
      if project.is_a?(Numeric)
        project = list[project - 1]
      end
      
      source = File.join(WORKSPACE_DIR, project)
      destin = File.join(OUTPUT_DIR, project)
      puts source
      puts destin
      
      # Concatinate the scripts to a single file
      #sprocketize(project)

      return

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
  
    # DELETE
    def self.require_sprockets
      throw Error.new
      require_submodule('Sprockets', 'sprockets')
    end
  
    # DELETE
    def self.get_submodule(name, path)
      throw Error.new
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
    
    # DELETE
    def self.require_submodule(name, path)
      throw Error.new
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
