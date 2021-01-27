module Examples::Annotations
  module AnnotationManager

    # @param [Sketchup::Page] page
    # @param [Symbol] type
    # @param [Array<Geom::Point3d>] points
    # @param [Integer] line_width
    # @param [Sketchup::Color] color
    def self.store(page, type, points, line_width, color)
      puts "TODO: Store annotation (#{points.size} points)"
    end

  end # class
end # module
