import os
import urllib.request

PROBE_URL = os.environ["PROBE_URL"]
TIMEOUT_SECONDS = 5


# Any exception or Lambda timeout counts as an error, which the alarm watches
def lambda_handler(event, context):
    with urllib.request.urlopen(PROBE_URL, timeout=TIMEOUT_SECONDS) as response:
        body = response.read(64).decode(errors="replace").strip()
        print(f"Egress OK: HTTP {response.status} from {PROBE_URL} ({body})")
    return {"ok": True}
