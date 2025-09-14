# Contributing to Nen Core

Thank you for your interest in contributing to Nen Core! This document provides guidelines and information for contributors.

## 🚀 **Getting Started**

### **Prerequisites**
- Zig 0.15.1 or later
- Git
- Basic understanding of Data-Oriented Design principles

### **Development Setup**

```bash
# Fork and clone the repository
git clone https://github.com/your-username/nen-core.git
cd nen-core

# Create a feature branch
git checkout -b feature/your-feature-name

# Run tests to ensure everything works
zig build test

# Run examples to verify functionality
zig build run-numerical
zig build run-memory
zig build run-batching
```

## 📋 **Contribution Guidelines**

### **Code Style**

We follow strict coding standards to maintain code quality and performance:

#### **Naming Conventions**
- Use `snake_case` for functions, variables, and file names
- Use descriptive names - no `_` for unused variables
- Use `PascalCase` for types and structs
- Use `SCREAMING_SNAKE_CASE` for constants

#### **Function Guidelines**
- Keep functions under **70 lines maximum**
- Add **minimum 2 assertions** per function on average
- Assert all function arguments and return values
- Use `inline` for hot-path functions (< 20 lines)
- Document complex algorithms with comments explaining **why**, not **what**

#### **Formatting**
- Use `zig fmt` to format all code
- Maintain **100-column line limit**
- Use meaningful variable names that convey purpose

#### **Performance Requirements**
- All hot-path functions must be `inline`
- Use Data-Oriented Design principles
- Prefer stack allocation over heap allocation
- Batch operations when possible
- Profile performance-critical code

### **Example Code Style**

```zig
/// High-performance vector addition using SIMD
/// Optimized for cache-friendly memory access patterns
pub inline fn addVectors(a: []const f32, b: []const f32, output: []f32) void {
    // Assertions for safety
    std.debug.assert(a.len == b.len);
    std.debug.assert(a.len == output.len);
    std.debug.assert(a.len > 0);
    
    const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
    const len = a.len;
    
    // Process SIMD batches for maximum performance
    var i: usize = 0;
    while (i + simd_width <= len) {
        for (0..simd_width) |j| {
            output[i + j] = a[i + j] + b[i + j];
        }
        i += simd_width;
    }
    
    // Handle remaining elements
    while (i < len) {
        output[i] = a[i] + b[i];
        i += 1;
    }
}
```

## 🧪 **Testing Requirements**

### **Test Coverage**
- All public functions must have tests
- Performance-critical functions need benchmarks
- Edge cases and error conditions must be tested
- Tests must pass in both Debug and ReleaseFast modes

### **Running Tests**

```bash
# Run all tests
zig build test

# Run tests with ReleaseFast optimization
zig build -Doptimize=ReleaseFast test

# Run specific test
zig test src/memory.zig

# Run performance benchmarks
zig build -Doptimize=ReleaseFast run-inline
```

### **Test Structure**

```zig
test "function name - specific behavior" {
    // Arrange
    var input = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    var output = [_]f32{ 0.0, 0.0, 0.0, 0.0 };
    
    // Act
    addVectors(&input, &input, &output);
    
    // Assert
    try std.testing.expectEqual(@as(f32, 2.0), output[0]);
    try std.testing.expectEqual(@as(f32, 4.0), output[1]);
    try std.testing.expectEqual(@as(f32, 6.0), output[2]);
    try std.testing.expectEqual(@as(f32, 8.0), output[3]);
}
```

## 📝 **Pull Request Process**

### **Before Submitting**
1. **Run all tests**: `zig build test`
2. **Run examples**: `zig build run-numerical run-memory run-batching`
3. **Check performance**: `zig build -Doptimize=ReleaseFast run-inline`
4. **Format code**: `zig fmt .`
5. **Update documentation** if needed

### **Pull Request Template**

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Performance improvement
- [ ] Documentation update
- [ ] Breaking change

## Testing
- [ ] All tests pass
- [ ] Examples run successfully
- [ ] Performance benchmarks pass
- [ ] No regressions introduced

## Performance Impact
- [ ] No performance impact
- [ ] Performance improvement (specify)
- [ ] Performance regression (justify)

## Checklist
- [ ] Code follows style guidelines
- [ ] Functions are under 70 lines
- [ ] Adequate assertions added
- [ ] Tests added for new functionality
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

### **Review Process**
1. **Automated checks** must pass
2. **Code review** by maintainers
3. **Performance validation** for critical changes
4. **Documentation review** for API changes

## 🎯 **Areas for Contribution**

### **High Priority**
- **Performance optimizations** for existing functions
- **New SIMD operations** for mathematical functions
- **Additional allocator patterns** for specific use cases
- **Memory layout optimizations** for DOD principles

### **Medium Priority**
- **Additional fast math functions** (trigonometric, logarithmic)
- **More RNG algorithms** with different characteristics
- **Extended batching patterns** for specific domains
- **Additional data type utilities**

### **Low Priority**
- **Documentation improvements** and examples
- **Test coverage** for edge cases
- **Code organization** and refactoring
- **Build system improvements**

## 🚫 **What Not to Contribute**

- **Breaking changes** without discussion
- **Dependencies** on external libraries
- **Non-performance-optimized code**
- **Code that doesn't follow DOD principles**
- **Functions over 70 lines**
- **Code without adequate tests**

## 💡 **Ideas and Discussion**

### **Feature Requests**
- Open an issue with the `enhancement` label
- Provide use case and performance requirements
- Discuss implementation approach

### **Performance Issues**
- Open an issue with the `performance` label
- Include benchmark results and analysis
- Provide reproduction steps

### **Questions**
- Use GitHub Discussions for general questions
- Tag maintainers for specific technical questions
- Check existing issues and discussions first

## 🏆 **Recognition**

Contributors will be recognized in:
- **README.md** contributors section
- **Release notes** for significant contributions
- **GitHub contributors** page

## 📞 **Getting Help**

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and ideas
- **Code Review**: For implementation guidance

## 🔄 **Release Process**

1. **Feature freeze** for major releases
2. **Comprehensive testing** across all platforms
3. **Performance validation** with benchmarks
4. **Documentation updates** and review
5. **Release notes** preparation
6. **Tagged release** with semantic versioning

---

Thank you for contributing to Nen Core! Your contributions help make high-performance computing more accessible and efficient.
