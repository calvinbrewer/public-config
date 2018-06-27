
vcl 4.0;

# Tells Varnish the location of the upstream. Do not change .host and .port.
backend default {
    .host = "next-hop";
    .port = "80";
    .first_byte_timeout = 125s;
    .between_bytes_timeout = 125s;
}

# The following VMODs are available for use if required:
#import std; # see https://www.varnish-cache.org/docs/5.2/reference/vmod_std.generated.html
#import header; # see https://github.com/varnish/varnish-modules


sub vcl_recv {

    # section.io default code
    #
    # Purpose: If the request method is not GET, HEAD or PURGE, return pass.
    # Documentation: Reference documentation for vcl_recv.
    if (req.method != "GET" && req.method != "HEAD" && req.method != "PURGE") {
        return (pass);
    }


    # section.io default code
    #
    # Purpose: If the request contains auth header return pass.
    # Documentation: Reference documentation for vcl_recv.
    if (req.http.Authorization) {
        /* Not cacheable by default */
        return (pass);
    }
    
    return (hash);
}

# Method: vcl_backend_response
# Documentation: https://varnish-cache.org/docs/5.2/users-guide/vcl-built-in-subs.html#vcl-backend-response
# Description: Happens after reading the response headers from the backend.
#
# Purpose: Here you clean the response headers, removing Set-Cookie headers
# and other mistakes your backend may produce. This is also where you can manually
# set cache TTL periods.
sub vcl_backend_response {
    if (beresp.status < 400) {
        set beresp.ttl = 1h;
        unset beresp.http.set-cookie;
        return (deliver);
    }
    
    set beresp.uncacheable = true;
    set beresp.ttl = 120s;
    return (deliver);
}


# Method: vcl_deliver
# Documentation: https://varnish-cache.org/docs/5.2/users-guide/vcl-built-in-subs.html#vcl-deliver
# Description: Happens when we have all the pieces we need, and are about to send the
# response to the client.
#
# Purpose: You can do accounting logic or modify the final object here.
sub vcl_deliver {
    # section.io default code
    #
    # Purpose: We are setting 'HIT' or 'MISS' as a custom header for easy debugging.
    if (resp.http.X-Varnish ~ "\d+\s\d+") {
       set resp.http.section-io-cache = "Hit";
    } else {
       set resp.http.section-io-cache = "Miss";
    }
}


# Method: vcl_hash
# Documentation: https://varnish-cache.org/docs/5.2/users-guide/vcl-built-in-subs.html#vcl-hash
# Description: This method is used to build up a key to look up the object in Varnish.
#
# Purpose: You can specify which headers you want to cache by.
sub vcl_hash {
    # section.io default code
    #
    # Purpose: Split cache by HTTP and HTTPS protocol.
    hash_data(req.http.X-Forwarded-Proto);
}