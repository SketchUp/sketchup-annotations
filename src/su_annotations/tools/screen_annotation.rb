require 'su_annotations/tools/iannotation'

module Trimble::Annotations
  class ScreenAnnotationTool < IAnnotationTool

    # @param [Sketchup::View] view
    # def getExtents
    #   bounds = Geom::BoundingBox.new
    #   bounds.add(@points) unless @points.empty?
    #   bounds
    # end

    # @param [Sketchup::View] view
    def draw(view)
      return if @points.size < 2

      view.line_stipple = ''
      view.line_width = @line_width
      view.drawing_color = @color
      view.draw2d(GL_LINE_STRIP, @points)
    end

    private

    # @return [Symbol]
    def annotation_type
      :annotate2d
    end

    # @param [Sketchup::View] view
    def record_input_point(flags, x, y, view)
      Geom::Point3d.new(x, y, 0)
    end

  end
end
