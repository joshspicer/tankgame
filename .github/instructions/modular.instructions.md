---
applyTo: '**'
description: "Guidelines for maintaining code modularity and preventing merge conflicts"
---

## Code Modularity Guidelines

When making code additions or changes, prioritize code modularity by following these principles:

### Creating New Files
- **Prefer NEW files** for new functionality: Create a new Swift file for specific features or components
- **Single responsibility**: Each file should have one clear purpose
- **Minimize conflicts**: Separate files reduce merge conflicts when multiple agents work concurrently

### Modifying Existing Code
- **Avoid unnecessary refactoring**: Do not move or refactor existing code except when absolutely necessary
- **Targeted changes**: Make minimal modifications to achieve your goals
- **Preserve structure**: Keep existing code organization unless specifically requested to change it
