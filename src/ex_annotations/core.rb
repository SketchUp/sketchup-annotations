#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'

require 'ex_annotations/service'

module Examples::Annotations

  unless file_loaded?( __FILE__ )
    menu = UI.menu('Tools').add_submenu('Annotations')
    menu.add_item('Screen Annotations') { self.activate_screen_annotations }
    menu.add_item('Model Annotations') { self.activate_model_annotations }
  end

  def self.activate_screen_annotations
  end

  def self.activate_model_annotations
  end

  # @note Debug method to reload the plugin.
  #
  # @example
  #   Examples::Annotations.reload
  #
  # @return [Integer] Number of files reloaded.
  # @since 1.0.0
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    load __FILE__
    if defined?( PATH ) && File.exist?( PATH )
      x = Dir.glob( File.join(PATH, '*.rb') ).each { |file|
        load file
      }
      x.length + 1
    else
      1
    end
  ensure
    $VERBOSE = original_verbose
  end

end # module

file_loaded( __FILE__ )
