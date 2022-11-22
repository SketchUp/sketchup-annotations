module Trimble::Annotations
module DrawingHelper

  # @param [Geom::Point3d] bottom_left
  # @param [Geom::Point3d] top_right
  # @param [Integer] line_width
  def rectangle_fill_points(bottom_left, top_right)
    [
      Geom::Point3d.new(bottom_left.x, bottom_left.y, 0),
      Geom::Point3d.new(top_right.x, bottom_left.y, 0),
      Geom::Point3d.new(top_right.x, top_right.y, 0),
      Geom::Point3d.new(bottom_left.x, top_right.y, 0),
    ]
  end

  # @param [Geom::Point3d] bottom_left
  # @param [Geom::Point3d] top_right
  # @param [Integer] line_width
  def rectangle_stroke_points(bottom_left, top_right, line_width: 1)
    o = line_width / 2.0
    [
      # Horizontal Bottom
      Geom::Point3d.new(bottom_left.x, bottom_left.y - o, 0),
      Geom::Point3d.new(top_right.x, bottom_left.y - o, 0),

      # Vertical Right
      Geom::Point3d.new(top_right.x - o, bottom_left.y, 0),
      Geom::Point3d.new(top_right.x - o, top_right.y, 0),

      # Horizontal Top
      Geom::Point3d.new(top_right.x, top_right.y + o, 0),
      Geom::Point3d.new(bottom_left.x, top_right.y + o, 0),

      # Vertical Left
      Geom::Point3d.new(bottom_left.x + o, top_right.y, 0),
      Geom::Point3d.new(bottom_left.x + o, bottom_left.y, 0),
    ]
  end

  # @param [Sketchup::View] view
  # @param [Geom::Point3d] bottom_left
  # @param [Geom::Point3d] top_right
  # @param [Integer] line_width
  def draw2d_rectangle_filled(view, bottom_left, top_right)
    points = rectangle_fill_points(bottom_left, top_right)
    view.draw2d(GL_QUADS, points)
  end

  # @param [Sketchup::View] view
  # @param [Geom::Point3d] bottom_left
  # @param [Geom::Point3d] top_right
  # @param [Integer] line_width
  def draw2d_rectangle_stroked(view, bottom_left, top_right, line_width: 1)
    points = rectangle_stroke_points(bottom_left, top_right, line_width: line_width)
    view.line_width = line_width
    view.draw2d(GL_LINES, points)
  end

end
end
