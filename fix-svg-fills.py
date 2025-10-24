#!/usr/bin/env python3
"""
Fix SVG fill attributes in Typst HTML output to work with Dark Reader.
Replaces hardcoded fill="#000000" with fill="currentColor" in SVG use elements.
"""
import sys
import re

def fix_svg_fills(html_content):
    """Replace fill="#0a0a0a" with fill="currentColor" in SVG use elements."""
    # Replace fill="#0a0a0a" (uncommon near-black) with fill="currentColor" in <use> elements
    pattern = r'(<use[^>]*?)fill="#0a0a0a"([^>]*?>)'
    fixed = re.sub(pattern, r'\1fill="currentColor"\2', html_content)
    return fixed

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
