module Hacknote
  ROOT_DIR            = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  THEME_DIR           = File.join(ROOT_DIR, 'themes')
  SAVE_DIR            = File.join(ROOT_DIR, 'presentation')
  SOURCE_FILE         = File.join(ROOT_DIR, 'presentation.md')
  SYNTAX_HIGHLIGHTERS = [:pygments, :coderay, :none]

  %w[sprockets].each do |name|
    $:.unshift File.join(Hacknote::ROOT_DIR, 'vendor', name, 'lib')
  end
end
