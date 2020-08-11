# URL Shortener
A simple app with an api for making shortened URLs and redirecting web users
from the short URL to the original target.

## Redirection behavior
A GET request to `/<slug>` checks the links table to see if there is a link
saved for `<slug>`, and if so redirects user. If `<slug>` does not exist in
the database, displays a simple text page saying so with status 404.

## API Endpoints
### `POST /api/v1/links`
Create a new shortened URL
#### Header
Requires a bearer token authentication (see authentication)
#### Body
Takes a JSON payload. Requires a `"target"` parameter for the target URL.
Accepts an optional `"slug"` parameter for a custom slug. If no slug is
provided, a slug is generated for you. See _Slugs_ below for more details.
* Example with custom slug:
  ```JSON
  {"target": "http://example.com", "slug": "example"}
  ```
* Example without custom slug:
  ```JSON
  {"target": "http://my.example.com/asdf"}
  ```
#### Responses
- **201: Created**: For successful creation. The body is the slug and target
  of the newly created link. Example:
  ```JSON
  {"target": "http://my.example.com/asdf", "slug": "e4h3"}
  ```
- **401: Unauthorized**: Means that either no authentication was included or
  the bearer token was invalid.
- **422: Unprocessable Entity**: Something was wrong with the data sent by the
  client. This will reply with an `"errors"` object listing the issues.
  For example, if the custom slug requested is already in use:
  ```JSON
  {
    "errors": {
      "slug": ["has already been taken"]
      }
  }
  ```

### `DELETE /api/v1/links`
Destroy an existing shortened link. NOTE: once a link has been destroyed, that
slug becomes available to any user. This might be changed in future versions,
possibly by disabling shortened URLs instead of deleting them.
#### Header
Requires a bearer token authentication (see authentication)
#### Body
N/A
#### Responses
- **204: No Content**: For successful deletion.
- **401: Unauthorized**: Means that either no authentication was included or
  the bearer token was invalid.
- **403: Forbidden**: Means that the slug the client is attempting to delete
  does not belong to the user whose auth token is included in the request.
- **404: Not Found**: The slug the client wants to delete does not exist.

### `GET /api/v1/links`
Returns a list of the slugs associated with the user sending the request.
#### Header
Requires a bearer token authentication (see authentication)
#### Body
N/A
#### Responses
- **200: Ok**: Returns a list of JSON objects, showing the slug and target for
  each shortened URL created by the authenticated user. Example:
  ```JSON
  [
    {"slug": "aQ3", "target": "http://example.com/first_url"},
    {"slug": "customslug", "target": "http://two.example.com"}
  ]
  ```
- **401: Unauthorized**: Means that either no authentication was included or
  the bearer token was invalid.


## Development setup
### Requirements
The app uses [Ruby 2.7.1](https://www.ruby-lang.org/en/news/2020/03/31/ruby-2-7-1-released/).
The database is [PostgreSQL](https://www.postgresql.org/download/), and I used
version 12.2.

### Installation
Clone the repo, then run `$ rails db:setup` to create the database.

### Tests
The test suite can be run with `$ rails test`. The tests are all in the
`/tests` directory. This app uses yaml fixtures, which are located in
`/tests/fixtures/`.

## Original requirements

### Product Requirements:
- Clients should be able to create a shortened URL from a longer URL.
- Clients should be able to specify a custom slug.
- Clients should be able to expire / delete previous URLs.
- Users should be able to open the URL and get redirected.

### Project Requirements:
- The project should include an automated test suite.
- The project should include a README file with instructions for running the
  web service and its tests. You should also use the README to provide context
  on choices made during development.
- The project should be packaged as a zip file or submitted via a hosted git
  platform (Github, Gitlab, etc).
