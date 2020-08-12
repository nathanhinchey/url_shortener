# URL Shortener
A simple app with an api for making shortened URLs and redirecting web users
from the short URL to the original target.

## Redirection behavior
A GET request to `/<slug>` checks the links table to see if there is a link
saved for `<slug>`, and if so redirects user. If `<slug>` does not exist in
the database, displays a simple text page saying so with status 404.

## Authentication
The system uses username and password to request a JSON Web Token (JWT) which
the client then sends as a bearer token with each link request. Creating a
user account simply involves posting a valid email address and a password to
the user creation endpoint, because I didn't want to focus on that.

**NOTE:** This api should be implemented with HTTPS because nearly every
request will include sensitive information (auth tokens and/or passwords).

## API endpoint for user creation
### `POST /api/v1/users`
Create a new user
#### Header
No headers required
#### Body
Takes a JSON payload including an email address and a new password. Example:
```JSON
{"email": "creator@example.com", "password": "mySecurePassword"}
```
#### Responses
- **201 Created**: For successfully created user. Responds with the email of
  the newly created user. Example:
  ```JSON
  {"email": "creator@example.com"}
  ```
- **422 Unprocessable Entity**: For when there is an issue with the data sent
  by the client. For example, if the email is invalid and no password was
  included in the request:
  ```JSON
  {
    "errors": {
      "email": ["in invalid"],
      "password": ["can't be blank"]
    }
  }
  ```

## API endpoint retrieving JSON Web Token
TODO: add unsuccessful attempts counting and restrictions.
### `POST /api/v1/user_token`
Request a new JWT to send for auth. JWTs expire after 1 day.
#### Header
No headers required
#### Body
Takes a JSON payload including an email address and the assuociated password.
Example:
```JSON
{"email": "creator@example.com", "password": "mySecurePassword"}
```
#### Responses
- **201 Created**: Returns the JWT. Example:
```JSON
{"jwt": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9"}
```
- **404 Not Found**: To provide as little information as possible to malicious
  actors, any email/password mismatch (including unregistered emails) returns
  a 404 not found.

## API endpoints for links
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
- **201 Created**: For successful creation. The body is the slug and target
  of the newly created link. Example:
  ```JSON
  {"target": "http://my.example.com/asdf", "slug": "e4h3"}
  ```
- **401 Unauthorized**: Means that either no authentication was included or
  the bearer token was invalid.
- **422 Unprocessable Entity**: Something was wrong with the data sent by the
  client. This will reply with an `"errors"` object listing the issues.
  For example, if the target is not a valid URL and the custom slug requested
  is already in use:
  ```JSON
  {
    "errors": {
      "slug": ["has already been taken"],
      "target": ["is invalid"]
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
- **204 No Content**: For successful deletion.
- **401 Unauthorized**: Means that either no authentication was included or
  the bearer token was invalid.
- **403 Forbidden**: Means that the slug the client is attempting to delete
  does not belong to the user whose auth token is included in the request.
- **404 Not Found**: The slug the client wants to delete does not exist.

### `GET /api/v1/links`
Returns a list of the slugs associated with the user sending the request.
#### Header
Requires a bearer token authentication (see authentication)
#### Body
N/A
#### Responses
- **200 Ok**: Returns a list of JSON objects, showing the slug and target for
  each shortened URL created by the authenticated user. Example:
  ```JSON
  [
    {"slug": "aQ3", "target": "http://example.com/first_url"},
    {"slug": "customslug", "target": "http://two.example.com"}
  ]
  ```
- **401 Unauthorized**: Means that either no authentication was included or
  the bearer token was invalid.

## Development
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

### Development choices
#### Rails API-only application
Since I didn't intend to build a web front end, I went with this lighter
weight option. Plus I'd never used it before, so that was fun.
```shell
$ rails . --git --database=postgresql --api
```

#### PostgreSQL
For the very basic database actions I'm using I could have really used any db,
I'm just more familiar with PostgreSQL, so if I wanted to add jsonb columns or
anything like that I could already know how to do it.

#### Knock
I'm using the [Knock](https://github.com/nsarno/knock) gem to handle auth,
because it's a very simple system specifically intended to work with Rails
API-only applications.

#### Generating slugs
When slugs are not custom they are generated by converting an integer into a
high base number, using alphanumeric characters that I find easy to read
uniquely even when handwritten. (See the `NON_CONFUSING_CHARACTERS` constant
in `link.rb`).

The integer is a `slug_number` which is stored as an integer column in the
`links` table. Initially I had intended to use the ID, but that caused an
issue of possible collisions with custom slugs, as well as any slugs I wanted
to avoid. When using a column specifically for this purport, In the case of
such a collision, we can simply increment the `slug_number`.

I considered a few way to generate slugs from URLs. This approach had a couple
of advantages:
1. It will be the shortest length available within the character set
2. Before the introduction of custom slugs, there is no possibility of
   collision (unlike if we used a hash function).

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
