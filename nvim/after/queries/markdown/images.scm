; extends

; YouTube Iframe Thumbnail Placeholder
((html_block) @image.src
  (#match? @image.src "youtube.com/embed/")
  (#set! image.ext "youtube")
  (#set! image.type "image")
) @image
