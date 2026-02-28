## Examples

### Good URL structure
- `GET /users` (list all users)
- `POST /users` (create user)
- `GET /users/123` (get user 123)
- `PATCH /users/123` (update user 123)
- `DELETE /users/123` (delete user 123)

### Error response example
```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Request body is invalid",
    "details": [
      {
        "field": "email",
        "message": "Must be a valid email address",
        "code": "INVALID_FORMAT"
      }
    ]
  }
}
```

### Pagination response
```json
{
  "data": [...],
  "pagination": {
    "cursor": "eyJpZCI6MTAwfQ==",
    "hasMore": true,
    "totalCount": 1432
  }
}
```

### Filtering example
`GET /users?status=active&role=admin&sort=createdAt&order=desc`

## $ARGUMENTS
When invoked with arguments, treat them as the API resource/endpoint description and generate a properly structured API design following these conventions.