Run the current smoke/regression suite with:

```powershell
godot --headless --path . --scene res://tests/TestRunner.tscn
```

For manual validation in the editor, press Play on the project. The node at `res://tests/ManualValidationRunner.gd` runs on startup from the main scene and prints the same character sheet debug output plus PASS/FAIL lines to Godot's Output panel.

The first suite covers character creation behavior:
- point-buy validation
- character creation smoke flow
- feat application
- starting equipment loading
- ability modifier lookup
