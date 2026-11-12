# Searching For

Post what you're searching for; others comment with leads. Search is powered by Typesense.

## Setup

```sh
bin/setup
export TYPESENSE_API_KEY=...        # your Typesense admin key
# optional: TYPESENSE_HOST (localhost), TYPESENSE_PORT (8108), TYPESENSE_PROTOCOL (http)
bin/rails typesense:reindex          # create the "items" collection and index existing posts
bin/dev
```

New, edited, and deleted posts are synced to Typesense by `ItemIndexJob`.
If Typesense can't be reached, search falls back to a basic SQL `LIKE` query.
