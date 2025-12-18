# Enhanced Demo Specifications

## Demo 2 Enhancement: Advanced Partial HTML System

### Current State
- Basic layout.partialhtml file 
- Simple content injection with {% content %} placeholder

### Enhanced Requirements
- Multiple partial HTML components (header, sidebar, footer, widgets)
- Nested partial HTML includes
- Dynamic content sections based on page type
- Advanced template variables beyond just {% content %}

### Implementation Plan
1. Create multiple partial HTML files:
   - header.partialhtml
   - footer.partialhtml
   - sidebar.partialhtml
   - nav.partialhtml
   - widget.partialhtml

2. Implement nested inclusion mechanism
3. Add advanced template variables:
   - {% title %}, {% description %}
   - {% author %}, {% date %}
   - {% related_posts %}, {% tags %}

4. Create component system for reusing elements

## Demo 3 Enhancement: Complex Hierarchy System

### Current State
- Multi-level directory structure with posts, categories, tags, archives
- Basic navigation between levels

### Enhanced Requirements
- Author pages and author-based navigation
- Comment systems integration
- Deep nested categories (e.g., tech/web/html, tech/web/css)

### Implementation Plan
1. Add author directory structure with author profiles
2. Create related content sections for each post
5. Create social sharing components
6. Implement deeper category hierarchies
7. Add breadcrumb navigation for complex paths
8. Create content recommendation system
9. Add search functionality page ( see `based.cooking`)
