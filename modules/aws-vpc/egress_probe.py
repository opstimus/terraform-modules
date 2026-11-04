import os
import time
import urllib.request

PROBE_URL = os.environ["PROBE_URL"]
TIMEOUT_SECONDS = 5
ATTEMPTS = 2


def lambda_handler(event, context):
    last_error = None
    for attempt in range(1, ATTEMPTS + 1):
        try:
            with urllib.request.urlopen(PROBE_URL, timeout=TIMEOUT_SECONDS) as response:
                body = response.read(64).decode(errors="replace").strip()
                print(f"Egress OK: HTTP {response.status} from {PROBE_URL} ({body})")
                return {"ok": True}
        except Exception as error:
            last_error = error
            print(f"Attempt {attempt} failed: {error!r}")
            if attempt < ATTEMPTS:
                time.sleep(2)

    # Raising marks the invocation as an error, which the alarm watches
    raise RuntimeError(f"Egress check to {PROBE_URL} failed: {last_error!r}")
