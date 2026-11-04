# Personal coding style

Apply this style to new and modified code in every project. Preserve behavior
when reformatting existing code. Keep upstream/vendor libraries in their own
format; format assistant-authored application modules and generated USER CODE
regions. Use the language's valid syntax rather than copying delimiters between
languages.

## C and C++

- Use Allman braces: function, type and control-block opening braces on their
  own lines; closing braces and `else` on their own lines.
- Indent with four spaces, not tabs. Always brace `if`, `else`, loop and other
  control bodies, including single-statement bodies.
- Expand functions and control blocks; put independent statements on separate
  lines. Use blank lines between functions and logical steps.
- Use spaces around operators and after commas; write `if (condition)` and
  `for (int i = 0; i < count; i++)`.
- Use meaningful comments to explain intent; preserve existing identifiers and
  interfaces during formatting-only changes.

```c
void processValue(int value)
{
    if (value > 0)
    {
        processPositive(value);
    }
    else
    {
        processNonPositive(value);
    }
}
```

## Verilog and SystemVerilog

- Use four-space indentation and readable operator spacing.
- Put module ports and parameters on separate lines.
- Put procedural `begin` and `end` on their own lines, including the block
  following `always`, `always_ff`, `always_comb`, `if`, `else` and loops.
- Put `else` on its own line. Expand nested blocks instead of one-line logic.
- Use nonblocking assignments in sequential clocked logic. Formatting alone
  must preserve reset behavior, assignment semantics and inferred hardware;
  the example's explicit hold assignment is not a requirement to add one.

```verilog
always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        counter <= 8'b0;
    end
    else if (enable)
    begin
        counter <= counter + 1;
    end
end
```

## Other languages

Use four-space indentation, expanded control flow and readable spacing where
valid. In Python, keep normal colon/indentation syntax and avoid compact
semicolon-separated statements or one-line compound control blocks. Do not
introduce C braces into Python or procedural `begin` into VHDL.

When adapting existing assistant-written code, constrain cleanup to the agreed
project scope and verify relevant builds/tests before calling it complete.
