"""Lock each tutorial's answer key behind a codeword after Quarto renders the site.

Any page section with id="answer-key" (made by a heading like
`## Answer key {#answer-key .answer-key}`) is encrypted in place with AES-GCM.
The key is derived from the codeword with PBKDF2-SHA256, and the page decrypts
it in the browser when someone types the codeword. The answers also come out
of the site search index.

Each tutorial has its own codeword. They all live in one GitHub Actions
secret, GEOG391_KEY_CODEWORDS, one line per tutorial page:

    probability: riverbend
    clt: floodplain

The name before the colon is the page's file name without .html. A page with
an answer key but no codeword gets its key removed instead, so an answer key
is never published in plain text by accident.

Runs as a Quarto post-render script; needs `cryptography` and `beautifulsoup4`.
"""

import base64
import json
import os
import pathlib
import sys

from bs4 import BeautifulSoup
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

KEY_ID = "answer-key"
ITERATIONS = 250_000

UNLOCK_JS = """
(function () {
  function b64(s) { return Uint8Array.from(atob(s), function (c) { return c.charCodeAt(0); }); }
  document.querySelectorAll('form.key-unlock').forEach(function (form) {
    form.addEventListener('submit', async function (ev) {
      ev.preventDefault();
      var box = form.parentElement;
      var data = JSON.parse(box.querySelector('script.key-data').textContent);
      var msg = form.querySelector('.key-msg');
      msg.textContent = '';
      var word = form.querySelector('input').value.trim().toLowerCase();
      try {
        var base = await crypto.subtle.importKey('raw', new TextEncoder().encode(word), 'PBKDF2', false, ['deriveKey']);
        var key = await crypto.subtle.deriveKey(
          { name: 'PBKDF2', salt: b64(data.salt), iterations: data.iter, hash: 'SHA-256' },
          base, { name: 'AES-GCM', length: 256 }, false, ['decrypt']);
        var plain = await crypto.subtle.decrypt({ name: 'AES-GCM', iv: b64(data.iv) }, key, b64(data.ct));
        var body = box.querySelector('.key-body');
        body.innerHTML = new TextDecoder().decode(plain);
        body.hidden = false;
        form.hidden = true;
      } catch (e) {
        msg.textContent = "That codeword didn't work.";
      }
    });
  });
})();
"""

FORM_HTML = """
<p>Check your work once you're done. Enter the codeword from class to open the answers and the full script.</p>
<form class="key-unlock">
  <label>Codeword <input type="password" autocomplete="off" spellcheck="false"></label>
  <button type="submit">Open key</button>
  <span class="key-msg" role="status"></span>
</form>
<div class="key-body" hidden></div>
"""


def encrypt(plaintext: str, codeword: str) -> dict:
    salt, iv = os.urandom(16), os.urandom(12)
    kdf = PBKDF2HMAC(algorithm=hashes.SHA256(), length=32, salt=salt, iterations=ITERATIONS)
    key = kdf.derive(codeword.strip().lower().encode())
    ct = AESGCM(key).encrypt(iv, plaintext.encode(), None)
    enc = lambda b: base64.b64encode(b).decode()
    return {"salt": enc(salt), "iv": enc(iv), "iter": ITERATIONS, "ct": enc(ct)}


def lock_page(path: pathlib.Path, codeword: str | None) -> bool:
    soup = BeautifulSoup(path.read_text(encoding="utf-8"), "html.parser")
    section = soup.find(id=KEY_ID)
    if section is None:
        return False
    heading = section.find(["h1", "h2", "h3"])
    if heading is not None:
        heading.extract()
    inner = section.decode_contents()
    section.clear()
    if heading is not None:
        section.append(heading)

    if not codeword:
        note = soup.new_tag("p")
        note.string = "The answer key isn't available in this build."
        section.append(note)
    else:
        section.append(BeautifulSoup(FORM_HTML, "html.parser"))
        data = soup.new_tag("script", attrs={"type": "application/json", "class": "key-data"})
        data.string = json.dumps(encrypt(inner, codeword))
        section.append(data)
        js = soup.new_tag("script")
        js.string = UNLOCK_JS
        section.append(js)

    path.write_text(str(soup), encoding="utf-8")
    return True


def scrub_search(out_dir: pathlib.Path) -> None:
    index = out_dir / "search.json"
    if not index.exists():
        return
    entries = json.loads(index.read_text(encoding="utf-8"))
    kept = [e for e in entries if f"#{KEY_ID}" not in e.get("href", "")]
    index.write_text(json.dumps(kept), encoding="utf-8")


def read_codewords() -> dict[str, str]:
    codewords = {}
    for line in os.environ.get("GEOG391_KEY_CODEWORDS", "").splitlines():
        page, sep, word = line.partition(":")
        if sep and page.strip() and word.strip():
            codewords[page.strip().removesuffix(".html").lower()] = word.strip()
    return codewords


def main() -> None:
    out_dir = pathlib.Path(
        os.environ.get("QUARTO_PROJECT_OUTPUT_DIR") or (sys.argv[1] if len(sys.argv) > 1 else "docs")
    )
    codewords = read_codewords()
    locked, removed = [], []
    for path in sorted(out_dir.rglob("*.html")):
        word = codewords.get(path.stem.lower())
        if lock_page(path, word):
            (locked if word else removed).append(path.stem)
    scrub_search(out_dir)
    print(f"lock_keys: locked {len(locked)} answer key(s): {', '.join(locked) or 'none'}")
    if removed:
        print(f"lock_keys: no codeword in GEOG391_KEY_CODEWORDS for {', '.join(removed)}, so those keys were removed")


if __name__ == "__main__":
    main()
