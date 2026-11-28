"""Accessibility touch-ups on the rendered site (run from post_render.py).

Quarto's own markup has a few gaps that WCAG checkers flag. This fixes them in
every page of _site:
  - names each navigation landmark (the sidebar and the table of contents)
  - gives images inside a captioned figure the caption as alt text when the
    image has none at all
  - closes skipped heading levels (an h3 straight under the h1 becomes an h2,
    keeping its look through a class)
It also prints anything it could not fix, such as images with no alt text and
no caption, so the build log shows what still needs a person.
"""
import os
import pathlib
import re

from bs4 import BeautifulSoup

SITE = pathlib.Path(os.environ.get("QUARTO_PROJECT_OUTPUT_DIR", "_site"))
if not SITE.is_absolute():
    SITE = pathlib.Path(__file__).resolve().parent.parent / SITE

NAV_LABELS = {"quarto-sidebar": "Pages", "TOC": "On This Page", "quarto-margin-sidebar": "On This Page"}


def fix(path: pathlib.Path) -> list[str]:
    html = path.read_text(encoding="utf-8")
    soup = BeautifulSoup(html, "html.parser")
    notes = []
    changed = False

    for nav in soup.find_all("nav"):
        if nav.get("aria-label") or nav.get("aria-labelledby"):
            continue
        label = NAV_LABELS.get(nav.get("id", ""))
        if label is None and "nav-footer" in nav.get("class", []):
            label = "Footer"
        if label:
            nav["aria-label"] = label
            changed = True

    for img in soup.find_all("img"):
        if img.has_attr("alt"):
            continue
        fig = img.find_parent("figure")
        cap = fig.find("figcaption") if fig else None
        text = cap.get_text(" ", strip=True) if cap else ""
        if text:
            img["alt"] = text
            changed = True
        else:
            notes.append(f"{path.name}: image with no alt text: {img.get('src', '')[:80]}")

    main = soup.find("main") or soup.body
    if main is not None:
        last = 1
        for h in main.find_all(re.compile(r"^h[1-6]$")):
            if h.find_parent(class_="answer-key-locked") is not None:
                continue
            level = int(h.name[1])
            if level > last + 1:
                new = last + 1
                h["class"] = h.get("class", []) + [f"h{level}"]
                h.name = f"h{new}"
                changed = True
                level = new
            last = level

    for a in soup.find_all("a"):
        t = a.get_text(" ", strip=True).lower()
        if t in {"here", "click here", "link", "this", "this link", "read more"}:
            notes.append(f"{path.name}: vague link text '{t}' -> {a.get('href', '')[:80]}")

    if changed:
        path.write_text(str(soup), encoding="utf-8")
    return notes


def main():
    notes = []
    for p in sorted(SITE.glob("*.html")):
        notes += fix(p)
    for n in notes:
        print("a11y:", n)
    print(f"a11y_fix: checked {len(list(SITE.glob('*.html')))} pages, {len(notes)} items need a person")


if __name__ == "__main__":
    main()
