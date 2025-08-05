## Unit Testing Notes:

- import `pytest` for unit testing .
- import `TestClient` from `fastapi.testclient`
  - This will test the app without launching any server
  - It tests directly and it is suitable for
    
    - Finding bugs at the earlier stage
    - Reduce downtime of the application
    - Reduce poor user experience
    - Avoid loss of trust from customers
- import `app` from our app.main
  
- `Client = TestClient(app)` --> Variable declared
  
### Start a Health Check
- Sends a GET request to /health.
- Checks if the HTTP response code is 200 OK.
- Checks if the JSON response is exactly {"status": "UP"}.


### Create a Task
- Defines a dictionary task_data with required fields for a task.
- Sends a POST request to `/api/tasks/` with that data as JSON.
- Asserts the response status is `200 OK`.
- Parses the JSON response.
- Verifies the response contains the same title and description as the input.

### Test the Task
- Sends a GET request to  `/api/tasks/`.
- Asserts the response status code is 200 OK.
- Checks that the response body is a list (which should contain tasks).
