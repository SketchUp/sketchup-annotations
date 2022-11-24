module Trimble::Annotations
  module CursorManager

    # @param [String] basename
    def self.cursor_path(basename)
      Trimble::Annotations.icon(basename)
    end

    def self.create_cursor(basename, x, y)
      path = self.cursor_path(basename)
      UI.create_cursor(path, x, y)
    end

    def self.annotate_2d
      @annotate_2d ||= self.create_cursor('tb_2d_annotations', 3, 26)
    end

    def self.annotate_3d
      @annotate_3d ||= self.create_cursor('tb_3d_annotations', 3, 26)
    end

    def self.erase_annotations
      @eraser ||= self.create_cursor('tb_eraser', 8, 23)
    end

  end # class
end # module
