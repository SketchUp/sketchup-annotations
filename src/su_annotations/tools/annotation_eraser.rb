require 'su_annotations/annotation_manager'

module Trimble::Annotations
  class AnnotationEraserTool

    PAD = 3 # How much padding when highlighing annotationsn to be erased.

    def initialize
      @curves = {} # Annotations picked to be erased.
      @color = Sketchup::Color.new(255, 192, 192, 96)

      @aperture = 6 # radius
      @annotations = nil

      @erasing = false
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
        UI.messagebox("Select a scene with annotations.")
        return
      end
      @curves = {}
      @annotations = AnnotationManager.load(view.model.pages.selected_page)

      pick_annotation_at(flags, x, y, view)
      @erasing = true
      view.invalidate
    end

    # @param [Sketchup::View] view
    def onLButtonUp(flags, x, y, view)
      return if view.model.pages.selected_page.nil?

      erase_annotation_at(flags, x, y, view)
      @erasing = false
      @curves = {}
      @annotations = nil
      view.invalidate
    end

    # @param [Sketchup::View] view
    def onMouseMove(flags, x, y, view)
      return unless erasing?

      pick_annotation_at(flags, x, y, view)
      view.invalidate
    end

    # @param [Sketchup::View] view
    def draw(view)
      return if @curves.all?(&:empty?)

      view.line_stipple = ''
      view.drawing_color = @color
      @curves.each { |type, curves|
        curves.each { |data|
          line_width = PAD + data[:line_width] + PAD
          view.line_width = line_width
          points = data[:points]
          if type == :annotate3d
            view.draw(GL_LINE_STRIP, points)
          else
            view.draw2d(GL_LINE_STRIP, points)
          end
        }
      }
    end

    private

    # @param [Sketchup::View] view
    def pick_annotation_at(flags, x, y, view)
      screen_point = Geom::Point3d.new(x, y, 0)
      model_point = pick_model_point(flags, x, y, view)

      ph = view.pick_helper
      ph.init(x, y, @aperture)

      @annotations.each { |type, curves|
        case type
        when :annotate3d
          # erase_3d_at(curves, model_point)
          curves.each_with_index { |data, i|
            # TODO: make reusable utility
            color, line_width, points = data
            pick = ph.pick_segment(points)
            next unless pick

            @curves[:annotate3d] ||= []
            @curves[:annotate3d] << { index: i, color: color, line_width: line_width, points: points }
          }
        when :annotate2d
          # erase_2d_at(curves, screen_point)
          curves.each_with_index { |data, i|
            # TODO: make reusable utility
            color, line_width, points = data
            pick = ph.pick_segment(points)
            next unless pick

            @curves[:annotate2d] ||= []
            @curves[:annotate2d] << { index: i, color: color, line_width: line_width, points: points }
          }
        end
      }
    end

    # @param [Sketchup::View] view
    def erase_annotation_at(flags, x, y, view)
      pick_annotation_at(flags, x, y, view)
      return if @curves.empty?

      page = view.model.pages.selected_page
      @curves.each { |type, curves|
        curves.each { |data|
          index = data[:index]
          AnnotationManager.erase_at(page, type, index)
        }
      }
    end

    def erasing?
      @erasing
    end

    # @param [Sketchup::View] view
    def pick_model_point(flags, x, y, view)
      # TODO: deduplicate logic from ModelAnnotationTool
      ray = view.pickray(x, y)
      hit = view.model.raytest(ray, true)
      return hit[0] if hit

      ground = [ORIGIN, Z_AXIS]
      Geom.intersect_line_plane(ray, ground)
    end

    def update_ui
      # TODO: Update statubar text.
      # Sketchup.vcb_label = "Line Width"
      # Sketchup.vcb_value = @line_width
    end

  end # class
end # module
