class ExtensionDowncase
    def call(filename)
      extension = File.extname(filename).downcase
      "#{filename}#{extension}"
    end
end