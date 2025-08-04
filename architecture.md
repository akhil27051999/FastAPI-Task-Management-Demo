# Task Management System - Architecture Diagrams

## 🏗️ High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           TASK MANAGEMENT SYSTEM                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Internet  │───▶│  AWS EC2    │───▶│   Docker    │───▶│ Application │
│   Users     │    │   Instance  │    │  Containers │    │   Services  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                         │
                         ▼
                   ┌─────────────┐
                   │ Security    │
                   │ Groups      │
                   │ (Firewall)  │
                   └─────────────┘
```

## 🐳 Docker Container Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DOCKER COMPOSE ENVIRONMENT                           │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐            │
│  │   FRONTEND      │  │    BACKEND      │  │    DATABASE     │            │
│  │   (Nginx)       │  │  (Spring Boot)  │  │    (MySQL)      │            │
│  │                 │  │                 │  │                 │            │
│  │ Port: 3001:80   │  │ Port: 8080:8080 │  │ Port: 3306:3306 │            │
│  │                 │  │                 │  │                 │            │
│  │ • HTML/CSS/JS   │  │ • REST API      │  │ • Task Storage  │            │
│  │ • Nginx Proxy   │  │ • JPA/Hibernate │  │ • Persistence   │            │
│  │ • Static Files  │  │ • Actuator      │  │ • Health Check  │            │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘            │
│           │                     │                     │                    │
│           └─────────────────────┼─────────────────────┘                    │
│                                 │                                          │
│  ┌─────────────────┐  ┌─────────────────┐                                 │
│  │   PROMETHEUS    │  │    GRAFANA      │                                 │
│  │  (Monitoring)   │  │  (Dashboard)    │                                 │
│  │                 │  │                 │                                 │
│  │ Port: 9090:9090 │  │ Port: 3000:3000 │                                 │
│  │                 │  │                 │                                 │
│  │ • Metrics       │  │ • Visualization │                                 │
│  │ • Alerting      │  │ • Admin Panel   │                                 │
│  │ • Scraping      │  │ • Dashboards    │                                 │
│  └─────────────────┘  └─────────────────┘                                 │
│           │                     │                                          │
│           └─────────────────────┘                                          │
│                                                                             │
│                    ┌─────────────────┐                                     │
│                    │  TASK-NETWORK   │                                     │
│                    │ (Docker Bridge) │                                     │
│                    └─────────────────┘                                     │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🌐 Network Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            NETWORK FLOW                                     │
└─────────────────────────────────────────────────────────────────────────────┘

Internet User
     │
     ▼
┌─────────────┐
│   Browser   │
│             │
└─────────────┘
     │
     ▼ HTTP Request
┌─────────────┐
│ AWS EC2     │ 54.224.108.46
│ Security    │ Ports: 3001, 8080, 3000, 9090
│ Group       │
└─────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DOCKER CONTAINERS                                    │
│                                                                             │
│  Frontend (Port 3001)                                                      │
│  ┌─────────────────┐                                                       │
│  │     Nginx       │                                                       │
│  │                 │                                                       │
│  │ GET /           │ ──────┐                                               │
│  │ Static Files    │       │                                               │
│  │                 │       │                                               │
│  │ GET /api/*      │ ──────┼─────┐                                         │
│  │ Proxy to        │       │     │                                         │
│  │ app:8080        │       │     │                                         │
│  └─────────────────┘       │     │                                         │
│                            │     │                                         │
│  Backend (Port 8080)       │     │                                         │
│  ┌─────────────────┐       │     │                                         │
│  │  Spring Boot    │ ◀─────┘     │                                         │
│  │                 │             │                                         │
│  │ GET /api/tasks  │             │                                         │
│  │ POST /api/tasks │             │                                         │
│  │ PUT /api/tasks  │             │                                         │
│  │ DELETE /api/tasks│            │                                         │
│  │                 │             │                                         │
│  │ /actuator/*     │ ◀───────────┼─────┐                                   │
│  └─────────────────┘             │     │                                   │
│           │                      │     │                                   │
│           ▼ JDBC                 │     │                                   │
│  ┌─────────────────┐             │     │                                   │
│  │     MySQL       │             │     │                                   │
│  │                 │             │     │                                   │
│  │ Database: taskdb│             │     │                                   │
│  │ Table: tasks    │             │     │                                   │
│  │ User: taskuser  │             │     │                                   │
│  └─────────────────┘             │     │                                   │
│                                  │     │                                   │
│  Monitoring                      │     │                                   │
│  ┌─────────────────┐             │     │                                   │
│  │   Prometheus    │ ◀───────────┘     │                                   │
│  │                 │                   │                                   │
│  │ Scrapes:        │                   │                                   │
│  │ app:8080/       │                   │                                   │
│  │ actuator/       │                   │                                   │
│  │ prometheus      │                   │                                   │
│  └─────────────────┘                   │                                   │
│           │                            │                                   │
│           ▼                            │                                   │
│  ┌─────────────────┐                   │                                   │
│  │    Grafana      │ ◀─────────────────┘                                   │
│  │                 │                                                       │
│  │ Dashboards:     │                                                       │
│  │ • Spring Boot   │                                                       │
│  │ • Frontend      │                                                       │
│  │ • System        │                                                       │
│  └─────────────────┘                                                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATA FLOW                                      │
└─────────────────────────────────────────────────────────────────────────────┘

User Action: Create Task
     │
     ▼
┌─────────────┐
│  Frontend   │ 1. User fills form
│  Dashboard  │ 2. JavaScript validates
│             │ 3. POST /api/tasks
└─────────────┘
     │
     ▼ HTTP POST
┌─────────────┐
│   Nginx     │ 4. Proxy to app:8080/api/tasks
│   Proxy     │
└─────────────┘
     │
     ▼ Proxy Request
┌─────────────┐
│ Spring Boot │ 5. TaskController.createTask()
│ Controller  │ 6. Validate request body
│             │ 7. Call TaskService
└─────────────┘
     │
     ▼ Service Call
┌─────────────┐
│ Task        │ 8. Business logic
│ Service     │ 9. Call TaskRepository
└─────────────┘
     │
     ▼ Repository Call
┌─────────────┐
│ JPA         │ 10. Generate SQL INSERT
│ Repository  │ 11. Execute query
└─────────────┘
     │
     ▼ SQL Query
┌─────────────┐
│   MySQL     │ 12. Insert into tasks table
│  Database   │ 13. Return generated ID
└─────────────┘
     │
     ▼ Response Chain
┌─────────────┐
│  Response   │ 14. Repository → Service
│   Flow      │ 15. Service → Controller
│             │ 16. Controller → JSON
│             │ 17. JSON → Nginx
│             │ 18. Nginx → Frontend
│             │ 19. Frontend updates UI
└─────────────┘
```

## 🏭 Production Architecture (Kubernetes)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        KUBERNETES PRODUCTION                                │
└─────────────────────────────────────────────────────────────────────────────┘

Internet
    │
    ▼
┌─────────────┐
│   Ingress   │ (nginx-ingress-controller)
│ Controller  │ Routes: /, /api/*
└─────────────┘
    │
    ├─────────────────────┬─────────────────────┐
    ▼                     ▼                     ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  Frontend   │   │   Backend   │   │ Monitoring  │
│  Service    │   │   Service   │   │  Services   │
│             │   │             │   │             │
│ ClusterIP   │   │ ClusterIP   │   │ ClusterIP   │
└─────────────┘   └─────────────┘   └─────────────┘
    │                     │                     │
    ▼                     ▼                     ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  Frontend   │   │   Backend   │   │ Prometheus  │
│ Deployment  │   │ Deployment  │   │   Grafana   │
│             │   │             │   │ Deployments │
│ Replicas: 2 │   │ Replicas: 3 │   │ Replicas: 1 │
└─────────────┘   └─────────────┘   └─────────────┘
                          │
                          ▼
                  ┌─────────────┐
                  │   MySQL     │
                  │ StatefulSet │
                  │             │
                  │ Replicas: 1 │
                  │ PVC: 10Gi   │
                  └─────────────┘
```

## 🔧 Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       COMPONENT INTERACTIONS                                │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐    HTTP/REST     ┌─────────────┐    JDBC/SQL    ┌─────────────┐
│             │ ──────────────▶  │             │ ─────────────▶ │             │
│  Frontend   │                  │   Backend   │                │   MySQL     │
│   (Nginx)   │ ◀────────────────│(Spring Boot)│◀───────────────│ (Database)  │
│             │    JSON/HTTP     │             │   ResultSet    │             │
└─────────────┘                  └─────────────┘                └─────────────┘
       │                                │                              │
       │                                │                              │
       │ HTTP Requests                  │ Metrics Export               │ Health Check
       │ • GET /api/tasks               │ • /actuator/prometheus       │ • Connection Pool
       │ • POST /api/tasks              │ • /actuator/health           │ • Query Performance
       │ • PUT /api/tasks/{id}          │ • /actuator/metrics          │ • Storage Usage
       │ • DELETE /api/tasks/{id}       │                              │
       │                                │                              │
       ▼                                ▼                              ▼
┌─────────────┐                  ┌─────────────┐                ┌─────────────┐
│    User     │                  │ Prometheus  │                │   Grafana   │
│  Browser    │                  │(Monitoring) │                │(Dashboard)  │
│             │                  │             │                │             │
│ • Dashboard │                  │ • Scraping  │                │ • Visualization│
│ • Forms     │                  │ • Storage   │                │ • Alerting  │
│ • Real-time │                  │ • Alerting  │                │ • Reports   │
└─────────────┘                  └─────────────┘                └─────────────┘
```

## 📊 Technology Stack Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          TECHNOLOGY STACK                                   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                            PRESENTATION LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │    HTML5    │  │    CSS3     │  │ JavaScript  │  │   Nginx     │        │
│  │             │  │             │  │    ES6+     │  │   Alpine    │        │
│  │ • Semantic  │  │ • Flexbox   │  │ • Fetch API │  │ • Reverse   │        │
│  │ • Forms     │  │ • Grid      │  │ • Async/    │  │   Proxy     │        │
│  │ • Responsive│  │ • Animation │  │   Await     │  │ • Static    │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ HTTP/REST API
┌─────────────────────────────────────────────────────────────────────────────┐
│                            APPLICATION LAYER                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Spring Boot │  │   Java 17   │  │   Maven     │  │  Actuator   │        │
│  │     3.x     │  │             │  │    3.8+     │  │             │        │
│  │ • REST API  │  │ • Records   │  │ • Build     │  │ • Health    │        │
│  │ • Auto      │  │ • Streams   │  │ • Test      │  │ • Metrics   │        │
│  │   Config    │  │ • Lambda    │  │ • Package   │  │ • Info      │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ JPA/Hibernate
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DATA LAYER                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   MySQL     │  │     JPA     │  │  Hibernate  │  │  HikariCP   │        │
│  │    8.0      │  │             │  │             │  │             │        │
│  │ • ACID      │  │ • Entities  │  │ • ORM       │  │ • Connection│        │
│  │ • Indexing  │  │ • Repository│  │ • Caching   │  │   Pooling   │        │
│  │ • Replication│ │ • Queries   │  │ • Lazy Load │  │ • Performance│       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼ Container Runtime
┌─────────────────────────────────────────────────────────────────────────────┐
│                          INFRASTRUCTURE LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Docker    │  │ Kubernetes  │  │    AWS      │  │ Monitoring  │        │
│  │             │  │             │  │             │  │             │        │
│  │ • Containers│  │ • Pods      │  │ • EC2       │  │ • Prometheus│        │
│  │ • Compose   │  │ • Services  │  │ • VPC       │  │ • Grafana   │        │
│  │ • Networks  │  │ • Ingress   │  │ • Security  │  │ • Alerting  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🔐 Security Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SECURITY LAYERS                                   │
└─────────────────────────────────────────────────────────────────────────────┘

Internet
    │
    ▼
┌─────────────┐ Layer 1: Network Security
│   AWS       │ • Security Groups (Firewall)
│ Security    │ • VPC Isolation
│  Groups     │ • Port Restrictions (22, 3001, 8080, 3000, 9090)
└─────────────┘
    │
    ▼
┌─────────────┐ Layer 2: Container Security
│   Docker    │ • Non-root User (appuser:1001)
│ Container   │ • Resource Limits (CPU/Memory)
│  Security   │ • Network Isolation (task-network)
│             │ • Minimal Base Images (Alpine)
└─────────────┘
    │
    ▼
┌─────────────┐ Layer 3: Application Security
│ Application │ • Input Validation
│  Security   │ • SQL Injection Prevention (JPA)
│             │ • CORS Configuration
│             │ • Health Check Security
└─────────────┘
    │
    ▼
┌─────────────┐ Layer 4: Data Security
│    Data     │ • Database Authentication
│  Security   │ • Connection Encryption
│             │ • Secrets Management
│             │ • Backup Encryption
└─────────────┘
```

This architecture demonstrates a modern, scalable, and secure full-stack application with comprehensive monitoring and DevOps practices.
