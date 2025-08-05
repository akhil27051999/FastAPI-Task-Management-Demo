# Database Connection & Querying Guide

## Database Connection Steps

### 1. Connect to MySQL
```bash
mysql -h <host> -u taskuser -p
```

### 2. Select Database
```sql
USE taskdb;
```

### 3. Verify Connection
```sql
SHOW DATABASES;
SHOW TABLES;
DESCRIBE tasks;
```

## Database Schema

### Tasks Table Structure
```sql
+-------------+--------------+------+-----+---------+----------------+
| Field       | Type         | Null | Key | Default | Extra          |
+-------------+--------------+------+-----+---------+----------------+
| id          | bigint       | NO   | PRI | NULL    | auto_increment |
| created_at  | datetime(6)  | YES  |     | NULL    |                |
| description | varchar(255) | YES  |     | NULL    |                |
| status      | varchar(255) | YES  |     | NULL    |                |
| title       | varchar(255) | NO   |     | NULL    |                |
| updated_at  | datetime(6)  | YES  |     | NULL    |                |
+-------------+--------------+------+-----+---------+----------------+
```

## Querying Operations

### View All Tasks
```sql
SELECT * FROM tasks;
```

### Filter Tasks by Status
```sql
SELECT * FROM tasks WHERE status = 'PENDING';
SELECT * FROM tasks WHERE status = 'COMPLETED';
```

### Search Tasks by Title
```sql
SELECT * FROM tasks WHERE title LIKE '%authentication%';
```

### Get Task Count by Status
```sql
SELECT status, COUNT(*) FROM tasks GROUP BY status;
```

### Recent Tasks (Last 7 Days)
```sql
SELECT * FROM tasks WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);
```

### Insert New Task
```sql
INSERT INTO tasks (title, description, status, created_at, updated_at) 
VALUES ('New Task', 'Task description', 'PENDING', NOW(), NOW());
```

### Update Task Status
```sql
UPDATE tasks SET status = 'COMPLETED', updated_at = NOW() WHERE id = 1;
```

### Delete Task
```sql
DELETE FROM tasks WHERE id = 1;
```

### Order Tasks by Creation Date
```sql
SELECT * FROM tasks ORDER BY created_at DESC;
```

### Get Specific Task by ID
```sql
SELECT * FROM tasks WHERE id = 1;
```

## Database Management

### Check Users
```sql
SELECT user, host FROM mysql.user;
```

### Exit MySQL
```sql
exit;
```
