# App Boilerplate - Design System

> Professional, Clean, Material Minimalist Design System

## 🎨 Core Principles

### Design Philosophy
- **Minimalist Material Design** - Clean, functional, elegant
- **No Excessive Roundness** - Square/sharp corners, minimal rounded elements
- **Flat Design** - No gradients, minimal shadows
- **Content-First** - Focus on information hierarchy
- **Professional & Clean** - Business-ready aesthetic

---

## 📐 Layout & Spacing

### Container Structure
```css
/* Card Container */
.card {
  border: 1px solid #e5e7eb; /* border-gray-200 */
  background: white;
  /* NO rounded corners */
}

/* Section Padding */
padding: 1rem;      /* p-4 */
padding: 1.5rem;    /* p-6 */

/* Grid Layout */
grid-template-columns: repeat(1, 1fr);           /* mobile */
grid-template-columns: repeat(3, 1fr);           /* desktop lg:grid-cols-3 */

/* Consistent Gaps */
gap: 1rem;          /* gap-4 */
gap: 1.5rem;        /* gap-6 */
```

### Page Structure Pattern
```
1. Breadcrumb Navigation
2. Header Section (Title + Description)
3. Stats Cards (Optional)
4. Filter Section (Optional)
5. Main Content (2-column layout: 2/3 + 1/3)
6. Footer Info (Optional)
```

---

## 🎨 Color Palette

### Primary Colors
```css
/* Purple - Primary Actions */
--primary-50:  #faf5ff;
--primary-100: #f3e8ff;
--primary-600: #9333ea;  /* Main */
--primary-700: #7e22ce;  /* Hover */

/* Gray - Neutrals */
--gray-50:  #f9fafb;     /* Backgrounds */
--gray-100: #f3f4f6;     /* Subtle backgrounds */
--gray-200: #e5e7eb;     /* Borders */
--gray-300: #d1d5db;     /* Input borders */
--gray-400: #9ca3af;     /* Placeholders */
--gray-500: #6b7280;     /* Helper text */
--gray-600: #4b5563;     /* Body text */
--gray-700: #374151;     /* Labels */
--gray-900: #111827;     /* Headings */
```

### Semantic Colors
```css
/* Success */
--green-500: #22c55e;
--green-700: #15803d;

/* Warning */
--yellow-600: #ca8a04;
--yellow-800: #854d0e;

/* Error */
--red-600: #dc2626;
--red-800: #991b1b;

/* Info */
--blue-600: #2563eb;
--blue-800: #1e40af;
```

---

## 📝 Typography

### Font Families
```css
font-family: 'Inter', system-ui, sans-serif;      /* Default */
font-family: 'JetBrains Mono', monospace;         /* Code/Technical */
```

### Text Hierarchy
```css
/* Headings */
h1: text-2xl font-semibold text-gray-900         /* 1.5rem / 24px */
h2: text-xl font-semibold text-gray-900          /* 1.25rem / 20px */
h3: text-sm font-semibold text-gray-900          /* 0.875rem / 14px */

/* Section Headers */
.section-header: text-sm font-semibold uppercase tracking-wider text-gray-900

/* Body Text */
.body: text-sm text-gray-700                     /* 0.875rem / 14px */
.body-large: text-base text-gray-700             /* 1rem / 16px */

/* Labels */
.label: text-sm font-medium text-gray-700

/* Helper Text */
.helper: text-xs text-gray-500                   /* 0.75rem / 12px */

/* Code/Technical */
.mono: font-mono text-sm text-gray-900           /* Slug, Username, ID */
```

### Font Weights
```css
font-normal:    400
font-medium:    500
font-semibold:  600
font-bold:      700
```

---

## 🧩 Components

### Buttons

#### Primary Button
```jsx
<button className="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 text-sm font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed">
  Button Text
</button>
```

#### Secondary Button
```jsx
<button className="bg-white border border-gray-300 text-gray-700 hover:bg-gray-50 px-4 py-2 text-sm font-medium transition-colors">
  Button Text
</button>
```

#### Danger Button
```jsx
<button className="bg-white border border-red-300 text-red-600 hover:bg-red-50 px-4 py-2 text-sm font-medium transition-colors">
  Delete
</button>
```

### Input Fields

```jsx
<div>
  <label className="block text-sm font-medium text-gray-700 mb-2">
    Label Name
    <span className="text-red-500 ml-1">*</span>
  </label>
  <input
    type="text"
    className="w-full px-3 py-2 border border-gray-300 text-sm focus:outline-none focus:border-purple-600 transition-colors"
    placeholder="Placeholder text"
  />
  <p className="mt-1 text-xs text-gray-500">Helper text goes here</p>
  <p className="mt-1 text-sm text-red-600">Error message</p>
</div>
```

### Cards

```jsx
<div className="bg-white border border-gray-200">
  {/* Header */}
  <div className="px-6 py-4 border-b border-gray-200">
    <h2 className="text-sm font-semibold text-gray-900 uppercase tracking-wider">
      Card Title
    </h2>
  </div>
  
  {/* Body */}
  <div className="p-6">
    Card content
  </div>
  
  {/* Footer (Optional) */}
  <div className="px-6 py-4 bg-gray-50 border-t border-gray-200">
    Footer content
  </div>
</div>
```

### Stats Card

```jsx
<div className="bg-white border border-gray-200 p-4">
  <div className="flex items-center justify-between">
    <div>
      <div className="text-2xl font-semibold text-gray-900">2,450</div>
      <div className="text-sm text-gray-600 mt-1">Total Users</div>
    </div>
    <div className="w-10 h-10 bg-purple-50 flex items-center justify-center">
      <svg className="w-5 h-5 text-purple-600"><!-- icon --></svg>
    </div>
  </div>
</div>
```

### Table

```jsx
<div className="bg-white border border-gray-200">
  <table className="w-full text-sm">
    <thead className="bg-gray-50 border-b border-gray-200">
      <tr>
        <th className="px-6 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
          Column Name
        </th>
      </tr>
    </thead>
    <tbody className="divide-y divide-gray-200">
      <tr className="hover:bg-gray-50 transition-colors">
        <td className="px-6 py-4 text-gray-900">Cell content</td>
      </tr>
    </tbody>
  </table>
</div>
```

### Status Indicators

```jsx
{/* Dot Indicator - Square Style */}
<div className="flex items-center gap-1.5">
  <div className="w-1.5 h-1.5 bg-green-500"></div>
  <span className="text-sm text-gray-700">Active</span>
</div>

{/* Badge */}
<span className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-purple-50 border border-purple-200 text-sm font-medium text-purple-700">
  <svg className="w-4 h-4"><!-- icon --></svg>
  Badge Text
</span>
```

### Avatars

```jsx
{/* Square Avatar with Initials */}
<div className="w-12 h-12 bg-purple-600 flex items-center justify-center flex-shrink-0">
  <span className="text-white font-semibold text-lg">AB</span>
</div>

{/* Large Avatar */}
<div className="w-20 h-20 bg-purple-600 flex items-center justify-center flex-shrink-0">
  <span className="text-white font-semibold text-2xl">AB</span>
</div>
```

### Breadcrumb

```jsx
<div className="flex items-center gap-2 text-sm text-gray-600">
  <Link href="#" className="hover:text-purple-600 transition-colors">
    Home
  </Link>
  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
  </svg>
  <span className="text-gray-900 font-medium">Current Page</span>
</div>
```

### Empty State

```jsx
<div className="px-6 py-16 text-center">
  <div className="inline-flex flex-col items-center">
    <svg className="w-12 h-12 text-gray-300 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <!-- icon -->
    </svg>
    <p className="text-sm font-medium text-gray-900 mb-1">No items found</p>
    <p className="text-xs text-gray-500">Get started by creating your first item</p>
  </div>
</div>
```

### Alert Cards

```jsx
{/* Info */}
<div className="bg-blue-50 border border-blue-200 p-4">
  <div className="flex gap-3">
    <svg className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5"><!-- icon --></svg>
    <div>
      <h3 className="text-sm font-semibold text-blue-900 mb-1">Info Title</h3>
      <p className="text-xs text-blue-800 leading-relaxed">Info message</p>
    </div>
  </div>
</div>

{/* Warning */}
<div className="bg-yellow-50 border border-yellow-200 p-4">
  <div className="flex gap-3">
    <svg className="w-5 h-5 text-yellow-600 flex-shrink-0 mt-0.5"><!-- icon --></svg>
    <div>
      <h3 className="text-sm font-semibold text-yellow-900 mb-1">Warning Title</h3>
      <p className="text-xs text-yellow-800 leading-relaxed">Warning message</p>
    </div>
  </div>
</div>
```

---

## ⚡ Interactive States

### Hover States
```css
hover:bg-gray-50          /* Cards, rows */
hover:bg-purple-700       /* Primary buttons */
hover:text-purple-600     /* Links */
hover:border-gray-300     /* Inputs */
```

### Focus States
```css
focus:outline-none
focus:border-purple-600
focus:ring-2 focus:ring-purple-500
```

### Disabled States
```css
disabled:opacity-50
disabled:cursor-not-allowed
```

### Transitions
```css
transition-colors         /* Color changes only */
transition-all           /* Use sparingly */
```

---

## 🎯 Form Patterns

### Form Field Structure
```jsx
<div>
  {/* Label */}
  <label className="block text-sm font-medium text-gray-700 mb-2">
    Field Name
    <span className="text-red-500 ml-1">*</span>
    <span className="text-gray-400 text-xs ml-1">(Optional)</span>
  </label>
  
  {/* Input */}
  <input
    type="text"
    className="w-full px-3 py-2 border border-gray-300 text-sm focus:outline-none focus:border-purple-600 transition-colors"
    placeholder="Placeholder"
  />
  
  {/* Helper Text */}
  <p className="mt-1 text-xs text-gray-500">
    Helper text explaining the field
  </p>
  
  {/* Error Message */}
  <p className="mt-1 text-sm text-red-600">
    Error message here
  </p>
</div>
```

### Form Footer
```jsx
<div className="px-6 py-4 bg-gray-50 border-t border-gray-200 flex items-center justify-between">
  <Link href="#" className="text-sm font-medium text-gray-600 hover:text-gray-900 transition-colors">
    ← Back
  </Link>
  <div className="flex gap-3">
    <button className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 transition-colors">
      Cancel
    </button>
    <button className="px-4 py-2 text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 transition-colors">
      Save Changes
    </button>
  </div>
</div>
```

---

## 📱 Responsive Design

### Breakpoints
```css
/* Mobile First */
default:  /* 0px - 639px */
sm:       /* 640px+ */
md:       /* 768px+ */
lg:       /* 1024px+ */
xl:       /* 1280px+ */
```

### Common Patterns
```jsx
{/* Mobile: 1 column, Desktop: 3 columns */}
<div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
  
{/* Mobile: 1 column, Desktop: 2/3 + 1/3 */}
<div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
  <div className="lg:col-span-2">Main content</div>
  <div>Sidebar</div>
</div>

{/* Responsive Flex */}
<div className="flex flex-col sm:flex-row gap-4">
```

---

## 🚫 Don't Use

### Avoid These Styles
```css
/* ❌ Excessive Rounding */
rounded-2xl, rounded-full

/* ❌ Heavy Shadows */
shadow-xl, shadow-2xl

/* ❌ Gradients */
bg-gradient-to-r, bg-gradient-to-br

/* ❌ Complex Animations */
animate-bounce, animate-spin (except loading states)

/* ❌ Centered Rounded Avatars */
/* Use square avatars instead */
```

---

## ✅ Best Practices

### Consistency Rules

1. **Always use square design** - No rounded corners except for subtle button text
2. **Border over shadow** - Prefer borders for separation
3. **Mono font** for code-like text (slug, username, ID)
4. **Purple** for primary actions and interactive elements
5. **Gray scale** for content hierarchy
6. **Uppercase tracking-wider** for section headers
7. **Square dot indicators** for status (w-1.5 h-1.5)
8. **Consistent spacing** - Use p-4, p-6, gap-4, gap-6
9. **Icon size consistency** - w-4 h-4 for inline, w-5 h-5 for standalone
10. **Transition colors only** - Avoid complex animations

### Accessibility

```jsx
{/* Always include labels */}
<label htmlFor="email">Email</label>
<input id="email" type="email" />

{/* Use semantic HTML */}
<button type="button">Click</button>
<Link href="#">Navigate</Link>

{/* Provide focus states */}
focus:outline-none focus:border-purple-600

{/* Use proper color contrast */}
text-gray-900 on white background (AAA)
text-gray-600 for secondary text (AA)
```

### Code Organization

```jsx
// Class order convention:
// 1. Layout (flex, grid, block)
// 2. Positioning (relative, absolute)
// 3. Display (hidden, visible)
// 4. Sizing (w-, h-)
// 5. Spacing (p-, m-, gap-)
// 6. Typography (text-, font-)
// 7. Colors (bg-, text-, border-)
// 8. Effects (shadow-, opacity-)
// 9. Transitions
// 10. States (hover:, focus:, disabled:)

<div className="flex items-center gap-3 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 hover:bg-gray-50 transition-colors">
```

---

## 📦 Component Library Structure

```
/components
  /ui
    /atoms
      - Button.jsx
      - Input.jsx
      - Label.jsx
      - Badge.jsx
    /molecules
      - InputGroup.jsx
      - StatCard.jsx
      - AlertBox.jsx
    /organisms
      - Table.jsx
      - Form.jsx
      - Sidebar.jsx
  /layouts
    - DashboardLayout.jsx
    - GuestLayout.jsx
```

---

## 🎨 Tailwind Config

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: {
          600: '#9333ea',
          700: '#7e22ce',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
  plugins: [],
}
```

---

## 📋 Checklist for New Components

- [ ] Uses square design (no rounded-2xl)
- [ ] Borders instead of heavy shadows
- [ ] Consistent spacing (p-4, p-6, gap-4, gap-6)
- [ ] Proper color hierarchy (gray scale)
- [ ] Purple for primary actions
- [ ] Mono font for technical text
- [ ] Hover/focus states implemented
- [ ] Loading/disabled states handled
- [ ] Responsive breakpoints considered
- [ ] Accessibility requirements met
- [ ] Consistent with existing components

---

**Design System Version:** 1.0.0  
**Last Updated:** January 2026  
**Framework:** React + Tailwind CSS + Inertia.js