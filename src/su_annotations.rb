require 'sketchup.rb'
require 'extensions.rb'

module Trimble
  module Annotations

  PLUGIN_ID       = 'su_annotations'.freeze
  PLUGIN_NAME     = 'SketchUp Annotations'.freeze
  PLUGIN_VERSION  = '1.0.0'.freeze

  FILENAMESPACE = File.basename( __FILE__, '.rb' )
  PATH_ROOT     = File.dirname( __FILE__ ).freeze
  PATH          = File.join( PATH_ROOT, FILENAMESPACE ).freeze

  unless file_loaded?( __FILE__ )
    loader = File.join( PATH, 'core.rb' )
    ex = SketchupExtension.new( PLUGIN_NAME, loader )
    ex.description = 'Model annotations.'
    ex.version     = PLUGIN_VERSION
    ex.copyright   = 'Trimble Inc © 2022'
    ex.creator     = 'SketchUp Team'
    Sketchup.register_extension( ex, true )
  end

  end # module Annotations
end # module Trimble

file_loaded( __FILE__ )
