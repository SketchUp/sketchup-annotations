require 'sketchup.rb'

require 'ex_annotations/constants/view'
require 'ex_annotations/drawing_helper'

module Examples::Annotations

  MODEL_SERVICE = if defined?(Sketchup::ModelService)
    Sketchup::ModelService
  else
    require 'ex_annotations/mock_service'
    MockService
  end


  class AnnotationService < MODEL_SERVICE

    include DrawingHelper
    include ViewConstants

    def initialize
      super('Annotations')

      @annotations = []
    end

    def activate
      super
      update_info(Sketchup.active_model)
    end


    # @param [Sketchup::View] view
    def start(view)
      puts "start (#{self.class.name})"
      start_observing_app
    end

    # @param [Sketchup::View] view
    def stop(view)
      puts "stop (#{self.class.name})"
      stop_observing_app
      reset(view.model)
    end


    DICTIONARY_NAME = 'ex_annotations'
    VIEW_ANNOTATIONS = 'view_annotations'
    MODEL_ANNOTATIONS = 'model_annotations'

    # @param [Sketchup::View] view
    def draw(view)
      view.model.pages.each { |page|
        view_data = page.get_attribute(DICTIONARY_NAME, VIEW_ANNOTATIONS, [])
        # draw_view_annotations(view, view_data)

        model_data = page.get_attribute(DICTIONARY_NAME, MODEL_ANNOTATIONS, [])
        # draw_model_annotations(view, model_data)
      }
    end


    # @param [Sketchup::Model] model
    def onOpenModel(model)
      puts "onOpenModel (#{self.class.name})"
      update_info(model)
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
      # @model_info = {}
      # @display_info = false

      # @button_points = nil
      # @button_hover = false
      # @button_pressed = false

      # model.tools.remove_observer(self)

      model.active_view.invalidate
    end

    def start_observing_app
      # TODO: Need to figure out how model services works with Mac's MDI.
      return unless Sketchup.platform == :platform_win
      Sketchup.remove_observer(self)
      Sketchup.add_observer(self)
    end

    def stop_observing_app
      return unless Sketchup.platform == :platform_win
      Sketchup.remove_observer(self)
    end

  end


  # Examples::Annotations.service
  def self.service
    @service
  end

  def self.start_service
    unless defined?(Sketchup::ModelService)
      warn 'ModelService not supported by this SketchUp version.'
      return
    end

    model = Sketchup.active_model
    @service = AnnotationService.new
    model.services.remove(@service) if @service
    model.services.add(@service)
    @service
  end

  def self.start_service_as_tool
    service = AnnotationService.new
    model = Sketchup.active_model
    model.select_tool(service)
    service
  end

  unless file_loaded?(__FILE__)
    self.start_service
    file_loaded( __FILE__ )
  end

end
