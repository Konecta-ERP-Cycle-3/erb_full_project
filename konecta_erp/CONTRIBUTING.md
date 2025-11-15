# Contributing to Konecta ERP

Thank you for your interest in contributing to Konecta ERP! This document provides guidelines and instructions for contributing.

---

## 🤝 How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [GitHub Issues](https://github.com/Konecta-ERP-Cycle-3/erb_full_project/issues)
2. If not, create a new issue with:
   - Clear description of the bug
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Docker version, etc.)

### Suggesting Features

1. Check if the feature has been suggested before
2. Create a new issue with:
   - Clear description of the feature
   - Use cases and benefits
   - Implementation ideas (if any)

### Code Contributions

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Update documentation
6. Submit a Pull Request

---

## 🔀 Development Workflow

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/erb_full_project.git
cd erb_full_project/konecta_erp
```

### 2. Create Branch

```bash
git checkout -b feature/your-feature-name
```

**Branch Naming**:
- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Critical fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation

### 3. Make Changes

- Write clean, readable code
- Follow coding standards
- Add comments where needed
- Update tests

### 4. Commit Changes

```bash
git add .
git commit -m "feat: Add your feature description"
```

**Commit Message Format**:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `test:` - Tests
- `chore:` - Maintenance

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## 📝 Coding Standards

### .NET (C#)

- Follow C# coding conventions
- Use meaningful variable names
- Add XML documentation comments
- Format code with `dotnet format`

### Java

- Follow Java coding conventions
- Use meaningful variable names
- Add Javadoc comments
- Format code with Maven formatter

### TypeScript/Angular

- Follow Angular style guide
- Use meaningful variable names
- Add JSDoc comments
- Format code with Prettier

---

## 🧪 Testing

### Writing Tests

- Write unit tests for new features
- Write integration tests for APIs
- Ensure all tests pass before submitting PR

### Running Tests

```bash
# .NET services
dotnet test

# Java services
mvn test

# Frontend
npm test
```

---

## 📚 Documentation

### Updating Documentation

- Update relevant documentation when adding features
- Keep documentation clear and concise
- Include code examples where helpful
- Update table of contents if needed

### Documentation Files

- `README.md` - Project overview
- `docs/` - Detailed documentation
- Code comments - Inline documentation

---

## 🔍 Code Review Process

1. **Submit PR** - Create a Pull Request
2. **Automated Checks** - CI/CD pipeline runs tests
3. **Review** - Team members review the code
4. **Feedback** - Address any feedback
5. **Approval** - At least one approval required
6. **Merge** - Merge to main branch

### PR Requirements

- All tests must pass
- Code must follow style guidelines
- Documentation must be updated
- No merge conflicts

---

## 🐛 Bug Fixes

### Before Fixing

1. Reproduce the bug locally
2. Understand the root cause
3. Check for similar issues

### Fixing

1. Create bugfix branch
2. Write test that reproduces the bug
3. Fix the bug
4. Ensure test passes
5. Submit PR

---

## ✨ Feature Development

### Before Starting

1. Check if feature is already planned
2. Discuss with team if needed
3. Create feature branch

### Development

1. Design the feature
2. Implement the feature
3. Write tests
4. Update documentation
5. Submit PR

---

## 📖 Related Documentation

- [Development Guide](docs/DEVELOPMENT.md) - Development setup
- [Team Guide](docs/TEAM_GUIDE.md) - Team collaboration
- [Architecture](docs/ARCHITECTURE.md) - System architecture

---

## ❓ Questions?

- Check [Documentation](docs/README.md)
- Review [GitHub Issues](https://github.com/Konecta-ERP-Cycle-3/erb_full_project/issues)
- Contact the team via [Team Guide](docs/TEAM_GUIDE.md)

---

**Thank you for contributing to Konecta ERP!** 🎉

