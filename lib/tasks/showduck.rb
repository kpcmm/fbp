require 'RMagick'
include Magick

# cat = ImageList.new("duck.gif")
# cat.minify!
# cat.display

# Create a 100x100 red image.
f = Image.new(60,120) { self.background_color = "red" }
#f.display


Text = 'RMagick\nline 2'
granite = Magick::ImageList.new('granite:')
canvas = Magick::ImageList.new
#canvas.new_image(100, 300, Magick::TextureFill.new(granite))
canvas.new_image(50, 300)

text = Magick::Draw.new
text.font_family = 'helvetica'
text.pointsize = 26
text.gravity = Magick::CenterGravity
text.rotation = -90

# text.annotate(canvas, 0,0,2,2, Text) {
#    self.fill = 'gray83'
# }

# text.annotate(canvas, 0,0,-1.5,-1.5, Text) {
#    self.fill = 'gray40'
# }

text.annotate(canvas, 0,0,0,0, Text) {
   self.fill = 'black'
 }

canvas.display
exit