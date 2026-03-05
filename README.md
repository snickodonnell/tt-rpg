
# Godot 4.4 Game Development `.cursorrules` for Cursor AI

This repository contains a `.cursorrules` file designed to enhance your Godot 4.4 game development experience when using [Cursor AI](https://docs.cursor.com/context/rules-for-ai).

## What is a `.cursorrules` File?

A `.cursorrules` file allows you to customize the behavior of Cursor AI to follow specific conventions and best practices for your project. As explained in the [Cursor documentation](https://docs.cursor.com/context/rules-for-ai):

> Using rules in Cursor you can control the behavior of the underlying model. You can think of it as instructions and/or a system prompt for LLMs.

While Cursor is moving toward a new system using `.cursor/rules` directory for project-specific rules, the `.cursorrules` file in your project root remains supported for backward compatibility.

## How to Use This File

1. Download the `.cursorrules` file from this repository
2. Place it in the root directory of your Godot 4.4 project
3. Cursor AI will automatically adjust its behavior to follow the Godot-specific guidelines when generating or editing code

## What's Included

This `.cursorrules` file contains comprehensive guidelines for Godot 4.4 development, including:

- Core development principles (strict typing, proper lifecycle implementation)
- Code style standards
- Naming conventions for files, classes, variables, and nodes
- Scene organization best practices
- Signal implementation guidelines
- Resource management techniques
- Performance optimization strategies
- Error handling approaches
- TileMap implementation for Godot 4.4

## Note on Cursor Rules Evolution

According to the [Cursor documentation](https://docs.cursor.com/context/rules-for-ai):

> For backward compatibility, you can still use a `.cursorrules` file in the root of your project. We will eventually remove .cursorrules in the future, so we recommend migrating to the new Project Rules system for better flexibility and control.

Consider migrating to the newer `.cursor/rules` directory system in the future as Cursor evolves.

---

*This repository is not affiliated with Godot Engine or Cursor AI.*
