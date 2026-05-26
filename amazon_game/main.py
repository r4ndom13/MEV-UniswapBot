"""Entry point — run with: python main.py"""
import os
import sys

# Make sure sibling modules resolve correctly when run from repo root
sys.path.insert(0, os.path.dirname(__file__))

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")   # headless fallback for CI
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

from game import Game

if __name__ == "__main__":
    # Remove headless override if a display is actually available
    if "DISPLAY" in os.environ or sys.platform == "win32" or sys.platform == "darwin":
        os.environ.pop("SDL_VIDEODRIVER", None)
        os.environ.pop("SDL_AUDIODRIVER", None)

    Game().run()
