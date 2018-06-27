-- The Content-Length response header must be cleared for any body filters
-- which will modify the body length, especially for gzipped responses.

-- The sectionio.gzip module will warn in the log and disable gzip processing
-- if the Content-Length header remains set.

ngx.header["content-length"] = nil
