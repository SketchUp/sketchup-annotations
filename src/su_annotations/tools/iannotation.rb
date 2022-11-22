require 'su_annotations/annotation_manager'

module Trimble::Annotations
  class IAnnotationTool

    def initialize
      @points = []
      @line_width = 3
      @color = Sketchup::Color.new('red')

      @annotating = false
    end

    def enableVCB?
      return true
    end

    def activate
      update_ui
    end

    # @param [Sketchup::View] view
    def deactivate(view)
      view.invalidate
    end

    # @param [Sketchup::View] view
    def suspend(view)
      view.invalidate
    end

    # @param [Sketchup::View] view
    def resume(view)
      update_ui
      view.invalidate
    end


    # @param [Sketchup::View] view
    def onLButtonDown(flags, x, y, view)
      if view.model.pages.selected_page.nil?
        UI.messagebox("Create a Scene to start annotating.")
        return
      end

      collect_input_point(flags, x, y, view)
      @annotating = true
      view.invalidate
    end

    # @param [Sketchup::View] view
    def onLButtonUp(flags, x, y, view)
      return if view.model.pages.selected_page.nil?

      collect_input_point(flags, x, y, view)
      page = view.model.pages.selected_page
      AnnotationManager.store(page, annotation_type, @points, @line_width, @color)
      @annotating = false
      @points.clear
      view.invalidate
    end

    # @param [Sketchup::View] view
    def onMouseMove(flags, x, y, view)
      return unless annotating?

      collect_input_point(flags, x, y, view)
      view.invalidate
    end


    # @param [Sketchup::View] view
    def onUserText(text, view)
      @line_width = text.to_i
      update_ui
      view.invalidate
    rescue ArgumentError
      view.tooltip = 'Invalid length'
    end

    private

    # @return [Symbol]
    def annotation_type
      raise NotImplementedError
    end

    # @param [Sketchup::View] view
    def record_input_point(flags, x, y, view)
      raise NotImplementedError
    end

    # @param [Sketchup::View] view
    def collect_input_point(flags, x, y, view)
      point = record_input_point(flags, x, y, view)
      @points << point if point
    end

    def annotating?
      @annotating
    end

    def update_ui
      # TODO: Update statubar text.
      Sketchup.vcb_label = "Line Width"
      Sketchup.vcb_value = @line_width
    end

  end # class
end # module
