; Zed wants an injection query with a content capture. Ahoy has nothing to
; inject into, so this is the same no-op the other Zed extensions use: the
; comment body is handed to the "comment" language, which leaves it alone.
((comment) @injection.content
  (#set! injection.language "comment"))
