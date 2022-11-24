require 'sketchup.rb'

require 'su_annotations/tools/annotation_eraser'
require 'su_annotations/tools/model_annotation'
require 'su_annotations/tools/screen_annotation'
require 'su_annotations/annotation_manager'
require 'su_annotations/overlay'

module Trimble::Annotations

  ICON_EXT = Sketchup.platform == :platform_win ? 'svg' : 'pdf'

  def self.icon(basename)
    File.join(PATH, 'icons', "#{basename}.#{ICON_EXT}")
  end

  unless file_loaded?(__FILE__)
    icon_path = File.join(PATH)

    cmd = UI::Command.new('Screen Annotations') { self.activate_screen_annotations }
    cmd.tooltip = 'Annotate scene in 2D space.'
    cmd.status_bar_text = 'Draw 2D annotations for the currently active scene.'
    cmd.large_icon = self.icon('tb_2d_annotations')
    cmd.small_icon = self.icon('tb_2d_annotations')
    cmd_screen_annotations = cmd

    cmd = UI::Command.new('Model Annotations') { self.activate_model_annotations }
    cmd.tooltip = 'Annotate scene in 3D space.'
    cmd.status_bar_text = 'Draw 3D annotations for the currently active scene.'
    cmd.large_icon = self.icon('tb_3d_annotations')
    cmd.small_icon = self.icon('tb_3d_annotations')
    cmd_model_annotations = cmd

    cmd = UI::Command.new('Erase Annotations') { self.activate_annotations_eraser }
    cmd.tooltip = 'Erase annotations.'
    cmd.status_bar_text = 'Draw 3D annotations for the currently active scene.'
    cmd.large_icon = self.icon('tb_eraser')
    cmd.small_icon = self.icon('tb_eraser')
    cmd_erase_annotations = cmd

    menu = UI.menu('Draw').add_submenu('Annotations')
    menu.add_item(cmd_screen_annotations)
    menu.add_item(cmd_model_annotations)
    menu.add_separator
    menu.add_item(cmd_erase_annotations)

    toolbar = UI::Toolbar.new('Annotations')
    toolbar.add_item(cmd_screen_annotations)
    toolbar.add_item(cmd_model_annotations)
    toolbar.add_separator
    toolbar.add_item(cmd_erase_annotations)
    toolbar.restore
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

  def self.activate_annotations_eraser
    return if !self.activate_tool_checks

    tool = AnnotationEraserTool.new
    Sketchup.active_model.select_tool(tool)
  end

  def self.activate_tool_checks
    unless defined?(Sketchup::Overlay)
      message = "This version of SketchUp doesn't support overlays."
      UI.messagebox(message)
      return false
    end

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
      UI.show_inspector("Overlays")

      message = 'Enable the Annotations Overlay to start annotating.'
      UI.messagebox(message)
      return false
    end

    true
  end

  # @note Debug method to reload the plugin.
  #
  # @example
  #   Trimble::Annotations.reload
  #
  # @return [Integer] Number of files reloaded.
  def self.reload
    original_verbose = $VERBOSE
    $VERBOSE = nil
    load __FILE__ # rubocop:disable SketchupSuggestions/FileEncoding
    if defined?(PATH) && File.exist?(PATH)
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

file_loaded(__FILE__)
