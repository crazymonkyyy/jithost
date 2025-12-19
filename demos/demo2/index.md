# Advanced Features

This demo showcases more advanced features of JitHost.

## Tables

| Feature | Status | Notes |
|---------|--------|-------|
| Markdown | ✅ | Full support |
| HTML Embedding | ✅ | With custom attributes |
| CSS Unification | ✅ | Single CSS file |
| Static Generation | ✅ | Pre-build all pages |
| Partial HTML | ✅ | Layout templates |

## Code Blocks

```d
import std.stdio;

void main() {
    writeln("Hello from JitHost!");
}
```

## Embedded HTML with Complex Structure

```html <class=card id=info-card>
<div class="card-header">
  <h3>Information Card</h3>
</div>
<div class="card-body">
  <p>This card was embedded using JitHost's HTML embedding feature.</p>
  <ul>
    <li>Custom attributes supported</li>
    <li>Full HTML structure preserved</li>
    <li>CSS styling maintained</li>
  </ul>
</div>
```

## Small Code Block Example

```python
print("This is a small code block")
```

## Using Partial HTML Layouts

This page is using a partial HTML layout template that provides consistent navigation and structure across the site.