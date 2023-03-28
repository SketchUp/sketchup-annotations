require 'sketchup.rb'
require 'extensions.rb'

module Trimble
  module Annotations

  file = __FILE__.dup
  # Account for Ruby encoding bug under Windows.
  file.force_encoding('UTF-8') if file.respond_to?(:force_encoding)
  # Support folder should be named the same as the root .rb file.
  folder_name = File.basename(file, '.*')

  PATH_ROOT     = File.dirname(file).freeze
  PATH          = File.join(PATH_ROOT, folder_name).freeze

  EXTENSION_ID       = 'su_annotations'.freeze
  EXTENSION_NAME     = 'SketchUp Annotations'.freeze
  EXTENSION_VERSION  = '1.1.1'.freeze

  unless file_loaded?(__FILE__)
    loader = File.join(PATH, 'core.rb')
    ex = SketchupExtension.new(EXTENSION_NAME, loader)
    ex.description = 'Model annotations.'
    ex.version     = EXTENSION_VERSION
    ex.copyright   = 'Trimble Inc © 2022-2023'
    ex.creator     = 'SketchUp Team'
    Sketchup.register_extension(ex, true)
  end

  end # module Annotations
end # module Trimble

file_loaded(__FILE__)
