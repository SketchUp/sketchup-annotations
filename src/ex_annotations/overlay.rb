require 'sketchup.rb'

require 'ex_annotations/constants/view'
require 'ex_annotations/annotation_manager'
require 'ex_annotations/drawing_helper'

module Examples::Annotations

  OVERLAY = if defined?(Sketchup::Overlay)
    Sketchup::Overlay
  else
    require 'ex_annotations/mock_overlay'
    MockOverlay
  end


  class AnnotationOverlay < OVERLAY

    OVERLAY_ID = 'thomthom.annotations'.freeze

    include DrawingHelper
    include ViewConstants

    def initialize
      description = 'Annotate in screen or model space.'
      super(OVERLAY_ID, 'Annotations', description: description)
    end

    def activate
      super
      update_info(Sketchup.active_model)
    end


    def start
      puts "start (#{self.class.name})"
      start_observing_app
    end

    def stop
      puts "stop (#{self.class.name})"
      stop_observing_app
      reset(Sketchup.active_model)
    end


    DICTIONARY_NAME = 'ex_annotations'
    VIEW_ANNOTATIONS = 'view_annotations'
    MODEL_ANNOTATIONS = 'model_annotations'

    # @param [Sketchup::View] view
    def draw(view)
      view.line_stipple = ''
      annotations = AnnotationManager.load(view.model.pages.selected_page)
      annotations.each { |type, list|
        list.each { |color, line_width, points|
          view.drawing_color = color
          view.line_width = line_width
          if type == :annotate2d # KLUDGE
            view.draw2d(GL_LINE_STRIP, points)
          else
            view.draw(GL_LINE_STRIP, points)
          end
        }
      }
    end


    # @param [Sketchup::Model] model
    def onOpenModel(model)
      puts "onOpenModel (#{self.class.name})"
      reset(model)
    end

    # @param [Sketchup::Model] model
    def onNewModel(model)
      puts "onNewModel (#{self.class.name})"
      reset(model)
    end

    # @param [Sketchup::View] view
    def onViewChanged(view)
      @button_points = nil
      view.invalidate
    end

    private

    def reset(model)
      puts "reset (#{self.class.name})"

      # model.tools.remove_observer(self)

      # model.active_view.invalidate
    end

    def start_observing_app
      # TODO: Need to figure out how model overlays works with Mac's MDI.
      return unless Sketchup.platform == :platform_win
      Sketchup.remove_observer(self)
      Sketchup.add_observer(self)
    end

    def stop_observing_app
      return unless Sketchup.platform == :platform_win
      Sketchup.remove_observer(self)
    end

  end

  class AppObserver < Sketchup::AppObserver

    def expectsStartupModelNotifications
      true
    end

    def register_overlay(model)
      overlay = AnnotationOverlay.new
      model.overlays.add(overlay)
    end
    alias_method :onNewModel, :register_overlay
    alias_method :onOpenModel, :register_overlay

  end

  def self.start_app_observer
    unless defined?(Sketchup::Overlay)
      warn 'Overlay not supported by this SketchUp version.'
      return
    end

    observer = AppObserver.new
    Sketchup.add_observer(observer)
  end

  def self.start_overlay_as_tool
    overlay = AnnotationOverlay.new
    model = Sketchup.active_model
    model.select_tool(overlay)
    overlay
  end

  unless file_loaded?(__FILE__)
    self.start_app_observer
    file_loaded( __FILE__ )
  end

end
