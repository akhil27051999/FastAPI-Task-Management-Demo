## Unit Testing Notes:

- import `pytest` for unit testing .
- import `TestClient` from fastapi.testclient
  - This will test the app without launching any server
  - It tests directly and it is suitable for
    - Finding bugs at the earlier stage
    - Reduce downtime of the application
    - Reduce poor user experience
    - Avoid loss of trust from customers
- import `app` from our app.main
  
- `Client = TestClient(app)` --> Variable declared
  
### Start a Health Check
  - `response = client.get("/health")` --> Variable declared
  - `assert response.status_code == 200` This is the health response we should get with response code 200. `assert` Checks if something is true; fails test if false
  - Checks if the JSON response is exactly `{"status": "UP"}`.


