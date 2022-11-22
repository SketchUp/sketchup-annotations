require 'su_annotations/tools/iannotation'

module Trimble::Annotations
  class ModelAnnotationTool < IAnnotationTool

    # @param [Sketchup::View] view
    def getExtents
      bounds = Geom::BoundingBox.new
      bounds.add(@points) unless @points.empty?
      bounds
    end

    # @param [Sketchup::View] view
    def draw(view)
      return if @points.size < 2

      view.line_stipple = ''
      view.line_width = @line_width
      view.drawing_color = @color
      view.draw(GL_LINE_STRIP, @points)
    end

    private

    # @return [Symbol]
    def annotation_type
      :annotate3d
    end

    # @param [Sketchup::View] view
    def record_input_point(flags, x, y, view)
      ray = view.pickray(x, y)
      hit = view.model.raytest(ray, true)
      return hit[0] if hit

      ground = [ORIGIN, Z_AXIS]
      Geom.intersect_line_plane(ray, ground)
    end

  end
end
