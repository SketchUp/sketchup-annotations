#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'

require 'ex_annotations/tools/model_annotation'
require 'ex_annotations/tools/screen_annotation'
require 'ex_annotations/annotation_manager'
require 'ex_annotations/overlay'

module Examples::Annotations

  unless file_loaded?( __FILE__ )
    menu = UI.menu('Draw').add_submenu('Annotations')
    menu.add_item('Screen Annotations') { self.activate_screen_annotations }
    menu.add_item('Model Annotations') { self.activate_model_annotations }
  end

  def self.activate_screen_annotations
    return if !self.activate_tool_checks

    tool = ScreenAnnotationTool.new
    Sketchup.active_model.select_tool(tool)
  end

  def self.activate_model_annotations
    return if !self.activate_tool_checks

    tool = ModelAnnotationTool.new
    Sketchup.active_model.select_tool(tool)
  end

  def self.activate_tool_checks
    model = Sketchup.active_model
    if model.nil?
      message = 'There must be an active model to start annotating.'
      UI.messagebox(message)
      return false
    end

    overlay = model.overlays.find { |overlay|
      overlay.overlay_id == AnnotationOverlay::OVERLAY_ID
    }
    if overlay.nil?
      message = 'Unexpected error. Annotation Overlay not registered.'
      UI.messagebox(message)
      return false
    end
    if !overlay.enabled?
      message = 'Enable the Annotations Overlay to start annotating.'
      UI.messagebox(message)
      return false
    end

    true
  end

  # @note Debug method to reload the plugin.
  #
  # @example
  #   Examples::Annotations.reload
  #
  # @return [Integer] Number of files reloaded.
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    load __FILE__
    if defined?( PATH ) && File.exist?( PATH )
      x = Dir.glob( File.join(PATH, '**/*.rb') ).each { |file|
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
