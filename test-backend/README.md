# Sample test backend

A small in-memory HTTP server for testing Dev Scenario against a real backend: the sample apps' **Backend**
screen signs in against it and places an order, and flows fetch test data from it (a bearer token, the test
user's current username, the order status). State lives in memory only; restart or `POST /test/reset` to start
over.

## Run

```bash
./gradlew run          # http://127.0.0.1:8095
SAMPLE_BACKEND_PORT=9000 ./gradlew run
SAMPLE_BACKEND_HOST=0.0.0.0 ./gradlew run   # reachable from the network
```

It listens on the loopback only by default. Each request is logged to stdout (method, path, status).

Reaching it from a device (all of these end up on the host's loopback):

- Android emulator: `http://10.0.2.2:8095` (the sample's default).
- Physical Android device: `adb reverse tcp:8095 tcp:8095`, then launch the sample with
  `--es backendUrl http://localhost:8095`.
- iOS simulator: `http://localhost:8095` (the default). Launch argument `-backendUrl <url>` overrides it.

## The test user

One user, account id `1001`, password `sample-pass`. Its username is random (`sample_user_xxxx`) and changes
after every successful app sign-in. For 2 s after each change (and after start and reset) the user is
provisioning: the search returns no users, so a caller has to retry.

## Endpoints

| Call | Auth | Result |
|---|---|---|
| `POST /auth/token` (form `grant_type=client_credentials`) | `Basic base64(sample-client:sample-secret)` | `{"access_token","token_type":"Bearer","expires_in":600}`; 401 `{"error":"invalid_client"}` |
| `GET /users/search?accountId=1001` | `Bearer <token>` | `{"users":[{"accountId":1001,"username","status":"active"}],"count":1}`; `{"users":[],"count":0}` while provisioning or for an unknown id |
| `GET /orders/current` | `Bearer <token>` + `X-Account-Id: 1001` | `{orderId, status, updatedAt}`; 404 `{"error":"No order"}` |
| `POST /app/login` `{"username","password"}` | none | `{"session","username"}`, then the username rotates; 401 `{"error":"Wrong username or password"}` |
| `POST /app/orders` | `X-Session` | Places (replaces) the order: `{orderId, status:"Placed", updatedAt}` |
| `GET /app/orders/current` | `X-Session` | The order, or 404 |
| `POST /test/reset` | none | New username (provisioning), no sessions, no order. Tokens stay valid. |
| `GET /health` | none | `{"ok":true}` |

An order's `status` goes `Placed` → `Packed` after 3 s → `Shipped` after 6 s, counted from when it was placed.

## Try it

```bash
TOKEN=$(curl -s -u sample-client:sample-secret -d grant_type=client_credentials localhost:8095/auth/token \
  | sed 's/.*"access_token":"\([^"]*\)".*/\1/')
curl -s -H "Authorization: Bearer $TOKEN" 'localhost:8095/users/search?accountId=1001'
curl -s -H "Authorization: Bearer $TOKEN" -H 'X-Account-Id: 1001' localhost:8095/orders/current
```
