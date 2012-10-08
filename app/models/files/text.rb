module Files

  class Images

    attr_accessor :images


    def initialize
      @images = []
    end

    def add_image(filename)
      @images.put(filename)
    end

  end

end