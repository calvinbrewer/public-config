# This is an extension on the default VCL that section.io has created to get
# you up and running with Varnish.
#
# Please note: There is an underlying default Varnish behavior that occurs after the VCL logic
# you see below. You can see the builtin code here
# https://github.com/varnishcache/varnish-cache/blob/5.2/bin/varnishd/builtin.vcl
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and http://varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
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


# Method: vcl_recv
# Documentation: https://varnish-cache.org/docs/5.2/users-guide/vcl-built-in-subs.html#vcl-recv
# Description: Happens before we check if we have this in cache already.
#
# Purpose: Typically you clean up the request here, removing cookies you don't need,
# rewriting the request, etc.
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
}


# Method: vcl_backend_fetch
# Documentation: https://varnish-cache.org/docs/5.2/users-guide/vcl-built-in-subs.html#vcl-backend-fetch
# Description: Called before sending the backend request.
#
# Purpose: Typically you alter the request for the backend here. Overriding to the
# required hostname, upstream Proto matching, etc
sub vcl_backend_fetch {
    # No default section.io code for vcl_backend_fetch
}


# Method: vcl_backend_response
# Documentation: https://varnish-cache.org/docs/5.2/users-guide/vcl-built-in-subs.html#vcl-backend-response
# Description: Happens after reading the response headers from the backend.
#
# Purpose: Here you clean the response headers, removing Set-Cookie headers
# and other mistakes your backend may produce. This is also where you can manually
# set cache TTL periods.
sub vcl_backend_response {

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

include "section-features.vcl";
