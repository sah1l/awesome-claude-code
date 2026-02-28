## Examples

### AAA pattern test
```javascript
// Arrange
test('deactivateUser_whenAlreadyInactive_returnsNoOp', () => {
  const user = createTestUser({ active: false })
  const repo = new InMemoryUserRepo([user])

  // Act
  const result = await repo.deactivate(user.id)

  // Assert
  expect(result.active).toBe(false)
  expect(result.deactivatedAt).toBeUndefined()
})
```

### Good test naming
- `parseConfig_withMissingRequiredField_throwsValidationError`
- `calculateDiscount_forPremiumUserOver100_applies15Percent`
- `fetchUsers_withNoInternet_throwsNetworkError`

### Framework detection
- Detects `jest.config.*` → Jest
- Detects `vitest.config.*` → Vitest
- Detects `*_test.go` → Go testing
- Detects `Cargo.toml` → Rust (cargo test)

## $ARGUMENTS
When invoked with arguments, treat them as the test description and generate a test following these patterns.