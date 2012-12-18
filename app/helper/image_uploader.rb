# Module that takes care of image upload related methods.
module ImageUploader

  def self.upload_image(file, root)
    FileUtils::cp(file[:tempfile].path, File.join(root.to_s, "public", "images", file[:filename]))
    file[:filename]
  end

  def self.image(filename, root)
    send_file(File.join(root.to_s, "public", "images", filename.to_s))
  end

  def self.delete_image(filename, root)
    FileUtils.remove(File.join(root.to_s, "public", "images", filename.to_s))
  end

end