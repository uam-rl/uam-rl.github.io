#!/usr/bin/env python3
"""
Fix SVG fill attributes in Typst HTML output to work with Dark Reader.
Uses proper HTML parsing to target only math equation SVGs.
Replaces #0a090b with currentColor for dark mode compatibility.
"""
import sys
from html.parser import HTMLParser

class MathSVGFixer(HTMLParser):
    """HTML parser that fixes fill attributes in math equation SVGs."""

    def __init__(self):
        super().__init__()
        self.output = []
        self.in_math_container = False
        self.math_depth = 0

    def handle_starttag(self, tag, attrs):
        # Check if entering a math container
        attrs_dict = dict(attrs)
        if tag in ('div', 'span') and 'class' in attrs_dict:
            class_value = attrs_dict['class']
            if 'dark-reader-fix-text' in class_value:
                self.in_math_container = True
                self.math_depth = 1

        # Fix fill attribute if we're inside a math container
        if self.in_math_container and 'fill' in attrs_dict:
            attrs = [(k, 'currentColor' if k == 'fill' and v == '#0a090b' else v)
                     for k, v in attrs]

        # Track nesting depth
        if self.in_math_container and self.math_depth > 0:
            self.math_depth += 1

        # Reconstruct the tag
        attrs_str = ''.join(f' {k}="{v}"' for k, v in attrs)
        self.output.append(f'<{tag}{attrs_str}>')

    def handle_endtag(self, tag):
        if self.in_math_container:
            self.math_depth -= 1
            if self.math_depth == 0:
                self.in_math_container = False

        self.output.append(f'</{tag}>')

    def handle_data(self, data):
        self.output.append(data)

    def handle_startendtag(self, tag, attrs):
        # Handle self-closing tags like <use ... />
        attrs_dict = dict(attrs)
        if self.in_math_container and 'fill' in attrs_dict:
            attrs = [(k, 'currentColor' if k == 'fill' and v == '#0a090b' else v)
                     for k, v in attrs]

        attrs_str = ''.join(f' {k}="{v}"' for k, v in attrs)
        self.output.append(f'<{tag}{attrs_str}/>')

    def get_output(self):
        return ''.join(self.output)

def fix_svg_fills(html_content):
    """Parse HTML and fix fill attributes in math SVGs."""
    parser = MathSVGFixer()
    parser.feed(html_content)
    return parser.get_output()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: fix-svg-fills.py <html-file>")
        sys.exit(1)

    filepath = sys.argv[1]

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    fixed_content = fix_svg_fills(content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print(f"Fixed SVG fills in {filepath}")
