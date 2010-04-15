module Hacknote
  
  ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Returns a path to the specified folder inside the root directory
  def self.root(name)
    File.join(ROOT_DIR, name)
  end

  LIB_DIR             = root('lib')
  WORKSPACE_DIR       = root('workspace')
  OUTPUT_DIR          = root('presentations')
  THEME_DIR           = root('themes')

  SYNTAX_HIGHLIGHTERS = [:pygments, :coderay, :none]

  %w[sprockets].each do |name|
    $:.unshift File.join(Hacknote::ROOT_DIR, 'vendor', name, 'lib')
  end
  
end
