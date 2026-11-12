# Searching For

Post what you're searching for; others comment with leads. Search is powered by Typesense.


New, edited, and deleted posts are synced to Typesense by `ItemIndexJob`.
If Typesense can't be reached, search falls back to a basic SQL `LIKE` query.
