module Trimble::Annotations
  module AnnotationManager

    DICTIONARY_NAME = 'su_annotations'

    # @param [Sketchup::Page] page
    # @param [Symbol] type
    # @param [Array<Geom::Point3d>] points
    # @param [Integer] line_width
    # @param [Sketchup::Color] color
    def self.store(page, type, points, line_width, color)
      data = [color, line_width, points]
      list = page.get_attribute(DICTIONARY_NAME, type, [])
      list << data
      page.set_attribute(DICTIONARY_NAME, type, list)
      page.model.active_view.invalidate
      nil
    end

    # @param [Sketchup::Page] page
    # @return [Hash]
    def self.load(page)
      return {} if page.nil?

      dictionary = page.attribute_dictionary(DICTIONARY_NAME, false)
      return {} if dictionary.nil?

      annotations = {}
      dictionary.each { |type, data|
        annotations[type.to_sym] = data
      }
      annotations
    end

    # @param [Sketchup::Page] page
    # @param [Symbol] type
    # @param [Array<Integer>] indicies
    def self.erase_at(page, type, indicies)
      list = page.get_attribute(DICTIONARY_NAME, type, [])
      list = list.reject.with_index { |points, i| indicies.include?(i) }
      page.set_attribute(DICTIONARY_NAME, type, list)
      page.model.active_view.invalidate
      nil
    end

  end # class
end # module
