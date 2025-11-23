#!/usr/bin/env python3
"""
A simple script that draws a dinosaur and exits.
"""

def draw_dinosaur():
    """Draw a dinosaur in ASCII art."""
    dinosaur = r"""
                   __
                  / _)
         _.----._/ /
        /         /
     __/ (  | (  |
    /__.-'|_|--|_|
    """
    print(dinosaur)

if __name__ == "__main__":
    draw_dinosaur()
    print("Roar! 🦖")
