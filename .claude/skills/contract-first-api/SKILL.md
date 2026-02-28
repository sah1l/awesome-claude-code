# Contract-First API Development

## Why This Skill Exists
Most API bugs happen at boundaries — the frontend expects one shape, the backend returns another, and you find out at runtime. Contract-first development eliminates this class of bugs by defining the API contract (types and schemas) before writing any implementation. Changes break at compile time, not in production.

## What Is Contract-First?

Traditional workflow:
```
Backend writes endpoint → Frontend discovers the shape → Both sides adjust → Repeat
```

Contract-first workflow:
```
Define contract (shared types) → Backend implements contract → Frontend consumes contract → Both verified at compile time
```

The contract is the single source of truth. Server and client are both derived from it.

## Why Contract-First?

| Benefit | How |
|---------|-----|
| Catch breaking changes at build time | Type errors when contract changes |
| Parallel frontend/backend development | Frontend codes against the contract, not the implementation |
| Auto-generated documentation | Contract IS the docs — always accurate |
| Auto-generated client SDKs | No hand-written API clients |
| Consistent error handling | Error types defined in the contract |
| Easier testing | Mock servers generated from the contract |

## Patterns by Stack

### TypeScript — tRPC / oRPC

Define procedures with input/output schemas:

```typescript
// contract: shared between server and client
import { z } from 'zod'

const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1),
  role: z.enum(['admin', 'member', 'viewer']),
})

const CreateUserInput = UserSchema.omit({ id: true })

// server: implements the contract
const appRouter = router({
  users: router({
    list: publicProcedure
      .input(z.object({ role: z.enum(['admin', 'member', 'viewer']).optional() }))
      .output(z.array(UserSchema))
      .query(async ({ input }) => {
        return db.users.findMany({ where: input })
      }),

    create: protectedProcedure
      .input(CreateUserInput)
      .output(UserSchema)
      .mutation(async ({ input }) => {
        return db.users.create({ data: input })
      }),
  }),
})

// client: fully typed, auto-completed
const users = await trpc.users.list.query({ role: 'admin' })
//    ^? User[] — type inferred from the contract
```

### Python — Pydantic + FastAPI

```python
# contract: Pydantic models define the shape
from pydantic import BaseModel, EmailStr
from enum import Enum

class Role(str, Enum):
    admin = "admin"
    member = "member"
    viewer = "viewer"

class UserResponse(BaseModel):
    id: str
    email: EmailStr
    name: str
    role: Role

class CreateUserRequest(BaseModel):
    email: EmailStr
    name: str
    role: Role

# server: FastAPI validates against the contract automatically
@app.post("/users", response_model=UserResponse, status_code=201)
async def create_user(body: CreateUserRequest) -> UserResponse:
    user = await db.users.create(body.model_dump())
    return UserResponse.model_validate(user)

# Auto-generated OpenAPI docs at /docs — always matches the code
```

### Go — Protocol Buffers / Connect

```protobuf
// contract: .proto file
service UserService {
  rpc ListUsers(ListUsersRequest) returns (ListUsersResponse);
  rpc CreateUser(CreateUserRequest) returns (User);
}

message User {
  string id = 1;
  string email = 2;
  string name = 3;
  Role role = 4;
}

message CreateUserRequest {
  string email = 1;
  string name = 2;
  Role role = 3;
}
```

Generated Go server interface + TypeScript client — both type-safe from the same source.

## Development Workflow

```
1. Define    Write/update the contract (schemas, types, .proto)
     │
2. Generate  Run codegen (tRPC infers, OpenAPI generates, protoc compiles)
     │
3. Server    Implement handlers — compiler enforces the contract
     │
4. Client    Consume the API — fully typed, auto-completed
     │
5. Test      Validate against the contract, not against implementation details
     │
6. Evolve    Change the contract → compiler shows every breakage
```

## Schema Evolution Rules

### Safe Changes (backward-compatible)
- Adding a new optional field
- Adding a new endpoint/procedure
- Adding a new enum value (if clients handle unknown values)
- Widening a type (e.g., `string` → `string | null` in response)

### Breaking Changes (require versioning)
- Removing a field
- Renaming a field
- Changing a field's type
- Making an optional field required
- Removing an enum value
- Changing URL paths or method signatures

### Versioning Strategy
```
Option A: URL versioning     /api/v1/users → /api/v2/users
Option B: Header versioning  Accept: application/vnd.myapp.v2+json
Option C: Schema versioning  Contract includes version, router dispatches
```

**Deprecation flow**: Mark old version as deprecated → run both versions → migrate clients → remove old version. Minimum deprecation window: 2 release cycles.

## Integration with Code Generation

```
Contract (OpenAPI spec / .proto / Zod schemas)
     │
     ├── → Server stubs / handlers
     ├── → Client SDKs (TypeScript, Python, Go, Swift)
     ├── → API documentation (Swagger UI, Redoc)
     ├── → Mock server for frontend development
     └── → Contract tests (validates server matches spec)
```

Tools by ecosystem:
| Ecosystem | Contract Format | Codegen Tool |
|-----------|----------------|--------------|
| TypeScript | Zod schemas | tRPC / oRPC (inferred) |
| OpenAPI | YAML/JSON spec | openapi-generator, orval, hey-api |
| gRPC | .proto files | protoc, buf, connect |
| GraphQL | .graphql schema | graphql-codegen |

## When NOT to Use Contract-First

| Scenario | Why Not | Alternative |
|----------|---------|-------------|
| Quick prototype / hackathon | Overhead slows iteration | Code-first, extract contract later |
| Internal tool with 1 consumer | Overkill for simple CRUD | Direct DB access or simple REST |
| Unstable requirements | Contract changes too often | Rapid iteration, then stabilize |
| Legacy API integration | You don't control the contract | Adapter/anti-corruption layer |

## $ARGUMENTS
When invoked with arguments, treat them as the API or service description and design a contract-first implementation plan: define the contract schemas, outline the server implementation, specify client consumption patterns, and note code generation steps — following these patterns.
