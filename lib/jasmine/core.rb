module Jasmine
  class Core
    def initialize(root)
      @root = root
    end

    def path
      @path ||= File.join(root, 'node_modules', 'jasmine-core', 'lib', 'jasmine-core')
    end

    def boot_dir
      path
    end

    def boot_files
      ['boot.js']
    end

    def js_files
      @js_files ||=
        begin
          files = ['jasmine.js']
          files += Dir.glob(File.join(path, "*.js"))
          files = files.collect { |f| File.basename(f) }.uniq
          files.reject { |f| f =~ /boot/ }
        end
    end

    def css_files
      @css_files ||= Dir.glob(File.join(path, "*.css"))
        .collect { |f| File.basename(f) }
    end

    def images_dir
      @images_dir ||= File.join(root, 'images')
    end

    private

    attr_reader :root
  end
end

