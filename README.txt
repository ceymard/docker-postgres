A dockerfile to create an image of postgres based on the official *alpine image,
with these extensions:

* pg_cron (preloaded)     https://github.com/citusdata/pg_cron
* http                    https://github.com/pramsey/pgsql-http
* envvar                  https://github.com/theory/pg-envvar
* postgis                 https://postgis.net
* pg_jsonschema           https://github.com/supabase/pg_jsonschema
* pljs                    https://github.com/plv8/pljs
* postcbor                https://github.com/ceymard/postcbor

./build.sh builds the image, tagged with the current branch name, and smoke-tests it.
