local chunk, eof = gz.inflate_chunk()

chunk = string.gsub(chunk, "maps.googleapis.com", "maps.cjb.io")

gz.deflate_chunk(chunk)
