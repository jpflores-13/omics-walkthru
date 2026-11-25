"""Build the reveal.js slide decks (a separate Quarto project in slides/) and
copy them into the book's output folder, so they are served at slides/<deck>.html.
Runs automatically after the book renders (post-render in _quarto.yml)."""
import os
import shutil
import subprocess

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out = os.environ.get("QUARTO_PROJECT_OUTPUT_DIR", "_book")
subprocess.run(["quarto", "render", os.path.join(root, "slides")], check=True)
dest = os.path.join(root, out, "slides")
shutil.rmtree(dest, ignore_errors=True)
shutil.copytree(os.path.join(root, "slides", "_output"), dest)
print(f"Slides copied to {dest}")
