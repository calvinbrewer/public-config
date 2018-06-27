local chunk, eof = gz.inflate_chunk()

chunk = chunk:gsub("maps.googleapis.com", "maps.cjb.io")

gz.deflate_chunk(chunk)
