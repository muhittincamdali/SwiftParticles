# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to the repository owner.

### What to Expect

- A confirmation of receipt within 48 hours
- An assessment of the vulnerability within 7 days
- Regular updates on our progress

## Security Considerations

SwiftParticles is a graphics library with minimal security surface:

1. **Memory Management** - Uses Swift's automatic memory management
2. **Metal Shaders** - All shaders are compiled and validated
3. **No Network Access** - Library does not make any network calls
