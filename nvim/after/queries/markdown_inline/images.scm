; extends

(shortcut_link 
  (link_text) @image.src 
  (#match? @image.src "\\.(png|jpe?g|gif|webp|bmp|svg|pdf)(\\||$)")
  (#gsub! @image.src "\\|.*" "")
) @image
