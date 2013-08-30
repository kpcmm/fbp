require 'RMagick'
include Magick

cat = ImageList.new("duck.gif")
cat.display
exit