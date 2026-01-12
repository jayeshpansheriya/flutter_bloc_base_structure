# Project Guidelines

This directory contains all comprehensive documentation and guidelines for this Flutter BLoC project.

## 📁 Directory Structure

```
guidelines/
├── README.md                           ← You are here
│
├── Core Rules (For Antigravity)
│   ├── architecture.md                 # Project structure and organization
│   ├── networking.md                   # API, Retrofit, and token management
│   ├── coding_standards.md             # Code style and conventions
│   └── antigravity_behavior.md         # How Antigravity should behave
│
├── Developer Guides
│   ├── DIO_RETROFIT_SETUP.md           # Complete Retrofit setup guide
│   ├── SECURE_TOKEN_STORAGE_GUIDE.md   # Token management and auth flows
│   └── PERFORMANCE_OPTIMIZATION.md     # Token caching and performance
│
└── Meta Documentation
    ├── UPDATED_RULES.md                # Original consolidated rules
    └── RULES_ORGANIZATION_SUMMARY.md   # How rules are organized
```

## 📖 Core Rules (Antigravity)

These files define how code should be structured and written:

### [architecture.md](architecture.md)

**Project structure and organization**

- Feature-first directory structure
- Clean architecture layers (data, domain, presentation)
- File organization and naming
- Dependency rules
- Best practices

**When to read**: Before creating new features or organizing code

---

### [networking.md](networking.md)

**API calls, Retrofit, and token management**

- DioClient configuration
- Creating Retrofit services (step-by-step)
- Error handling with ApiError
- Authentication and secure token storage
- Token caching for performance
- Automatic token refresh
- Retrofit annotations reference

**When to read**: Before making API calls or handling authentication

---

### [coding_standards.md](coding_standards.md)

**Code style and conventions**

- Naming conventions (files, classes, variables)
- Import organization (5 categories)
- Code formatting rules
- Error handling patterns
- Code generation workflow
- BLoC vs Cubit guidelines
- Dependency injection patterns

**When to read**: Before writing any code

---

### [antigravity_behavior.md](antigravity_behavior.md)

**How Antigravity should behave**

- File existence checks
- Dependency verification
- Code generation reminders
- Service locator updates
- Communication guidelines
- Security best practices
- Performance considerations

**When to read**: Antigravity reads this automatically

---

## 📚 Developer Guides

These files provide detailed setup instructions and usage examples:

### [DIO_RETROFIT_SETUP.md](DIO_RETROFIT_SETUP.md)

**Complete Retrofit setup guide**

- What was created (file structure)
- Key features overview
- How to create Retrofit services
- Configuration guide
- Example log output
- Next steps

**When to read**: When setting up networking or creating new API services

---

### [SECURE_TOKEN_STORAGE_GUIDE.md](SECURE_TOKEN_STORAGE_GUIDE.md)

**Token management and authentication**

- How secure storage works
- Token caching explained
- Login/logout flows
- BLoC integration examples
- App initialization
- Platform-specific notes
- Security best practices
- Troubleshooting

**When to read**: When implementing authentication or managing user sessions

---

### [PERFORMANCE_OPTIMIZATION.md](PERFORMANCE_OPTIMIZATION.md)

**Token caching and performance tips**

- Problem solved (before/after comparison)
- Architecture improvements
- Performance metrics
- How caching works
- Memory usage analysis
- API changes
- Best practices

**When to read**: When optimizing performance or understanding token caching

---

## 🎯 Quick Navigation

### I want to...

**Create a new feature**
→ Read [architecture.md](architecture.md)

**Make an API call**
→ Read [networking.md](networking.md) + [DIO_RETROFIT_SETUP.md](DIO_RETROFIT_SETUP.md)

**Handle authentication**
→ Read [SECURE_TOKEN_STORAGE_GUIDE.md](SECURE_TOKEN_STORAGE_GUIDE.md)

**Follow code style**
→ Read [coding_standards.md](coding_standards.md)

**Understand token caching**
→ Read [PERFORMANCE_OPTIMIZATION.md](PERFORMANCE_OPTIMIZATION.md)

**Know how Antigravity works**
→ Read [antigravity_behavior.md](antigravity_behavior.md)

---

## 📊 Documentation Types

| Type       | Files                                                                    | Purpose                    |
| ---------- | ------------------------------------------------------------------------ | -------------------------- |
| **Rules**  | architecture, networking, coding_standards, antigravity_behavior         | Define how to code         |
| **Guides** | DIO_RETROFIT_SETUP, SECURE_TOKEN_STORAGE_GUIDE, PERFORMANCE_OPTIMIZATION | Explain how things work    |
| **Meta**   | UPDATED_RULES, RULES_ORGANIZATION_SUMMARY                                | Document the documentation |

---

## 🔄 How This Works

```
.agent/rules/rules.md (Antigravity reads this)
        ↓
    References
        ↓
guidelines/ (All detailed documentation)
        ↓
    Developers read these
        ↓
    Write consistent code
```

---

## ✅ Benefits

### For Developers

- ✅ All documentation in one place
- ✅ Easy to find specific information
- ✅ Comprehensive examples
- ✅ Clear guidelines

### For Antigravity

- ✅ Concise rules file
- ✅ Detailed references available
- ✅ Consistent behavior
- ✅ Better code generation

### For Project

- ✅ Consistent code style
- ✅ Best practices enforced
- ✅ Easy onboarding
- ✅ Maintainable codebase

---

## 📝 Updating Guidelines

When updating documentation:

1. **Update the relevant file** in `guidelines/`
2. **Update `.agent/rules/rules.md`** if quick reference changes
3. **Keep consistency** across all files
4. **Add examples** for clarity
5. **Document reasoning** behind decisions

---

## 🚀 Getting Started

### For New Developers

1. Read [README.md](../README.md) in project root
2. Read [architecture.md](architecture.md) to understand structure
3. Read [coding_standards.md](coding_standards.md) for code style
4. Refer to other guides as needed

### For Antigravity

1. Read `.agent/rules/rules.md` (happens automatically)
2. Reference detailed guidelines when needed
3. Follow all rules consistently
4. Remind developers about best practices

---

**Note**: All guidelines are living documents and should be updated as the project evolves.
