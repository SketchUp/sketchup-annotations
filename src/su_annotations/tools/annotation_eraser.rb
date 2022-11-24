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

    # @param [Integer] reason
    # @param [Sketchup::View] view
    def onCancel(reason, view)
      @curves = {}
      @erasing = false
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

      ph = view.pick_helper
      ph.init(x, y, @aperture)

      @annotations.each { |type, curves|
        pick = nil

        case type
        when :annotate3d
          curves.each_with_index { |data, i|
            color, line_width, points = data # TODO: make reusable utility
            pick = ph.pick_segment(points)
            next unless pick

            @curves[type] ||= []
            @curves[type] << { index: i, color: color, line_width: line_width, points: points }
          }
        when :annotate2d
          curves.each_with_index { |data, i|
            color, line_width, points = data # TODO: make reusable utility
            pick = pick_2d_segment?(screen_point, points)
            next unless pick

            @curves[type] ||= []
            @curves[type] << { index: i, color: color, line_width: line_width, points: points }
          }
        end
      }
    end

    # @param [Geom::Point3d] screen_point
    # @param [Array<Geom::Point3d>] points
    def pick_2d_segment?(screen_point, points)
      points.each_cons(2) { |segment|
        pick_on_segment = screen_point.project_to_line(segment)
        pt1, pt2 = segment
        v1 = pick_on_segment.vector_to(pt1)
        v2 = pick_on_segment.vector_to(pt2)
        # If vectors are zero length, the projected pick is on the vertex.
        # If the projected pick on on the segment the vectors should be opposing.
        if !v1.valid? || !v2.valid? || !v1.samedirection?(v2)
          return true if screen_point.distance(pick_on_segment) <= @aperture
        end
      }
      false
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
