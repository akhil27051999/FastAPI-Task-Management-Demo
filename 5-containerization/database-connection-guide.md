# Database Connection Guide

## Prerequisites
- MySQL server running
- Database credentials (username/password)
- Network access to database host

## Connection Steps

### 1. Connect via MySQL CLI
```bash
mysql -h <host> -u <username> -p
```

### 2. Select Database
```sql
USE taskdb;
```

### 3. Verify Connection
```sql
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

## Application Connection

### Environment Variables
```bash
DB_HOST=<database_host>
DB_USER=taskuser
DB_PASSWORD=<password>
DB_NAME=taskdb
DB_PORT=3306
```

### Connection String Example
```
mysql://taskuser:<password>@<host>:3306/taskdb
```

## Common Operations

### View All Tasks
```sql
SELECT * FROM tasks;
```

### Check User Permissions
```sql
SELECT user, host FROM mysql.user;
```

### Database Status
```sql
SHOW DATABASES;
```
