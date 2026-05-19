## Component Overview
### Consul

Consul is a service that provides a centralized registry and configuration management system.

*   Description: Consul is a highly available, distributed key-value store and service registrar.
*   Role in the stack: Provides a centralized registry for service discovery and configuration management.

### Elasticsearch

Elasticsearch is a service that provides a search engine for storing and retrieving large amounts of data.

*   Description: Elasticsearch is a NoSQL search engine that allows for flexible, dynamic indexing and searching of documents.
*   Role in the stack: Serves as an index store for Kibana's visualization data and provides a search interface for users to query data.

### Haproxy

Haproxy is a service that provides a reverse proxy server for load balancing and traffic management.

*   Description: HAProxy is a free, open-source reverse proxy server and load balancer.
*   Role in the stack: Acts as an entry point for incoming HTTP requests and directs them to either Elasticsearch or Kibana based on the requested URL.

### MySQL

MySQL is a service that provides a relational database for storing structured data.

*   Description: MySQL is an open-source relational database management system (RDBMS).
*   Role in the stack: Stores user data and serves as a backend database for applications using its API.

### Postgres

Postgres is a service that provides a relational database for storing structured data.

*   Description: PostgreSQL is an open-source, object-relational database system.
*   Role in the stack: Acts as an alternative to MySQL for storing structured data and serving as a backend database for applications.

## Resource Allocation

| Component | CPUs | Memory | Disk |
| --- | --- | --- | --- |
| Consul | 1 | 1G | 5G |
| Elasticsearch | 2 | 4G | 20G |
| Haproxy | 1 | 1G | 5G |
| Kibana | 2 | 2G | 10G |
| MySQL | 2 | 2G | 10G |
| Postgres | 2 | 2G | 10G |

## Network Topology

### Consul
*   Ports: 8500 (http), 8600 (dns), 8502 (grpc), 8301 (serf lan), 8302 (serf wan), 8300 (rpc)
*   Protocol: http, dns, grpc, serf lan, serf wan, rpc

### Elasticsearch
*   Ports: 9200 (http), 9300 (transport)
*   Protocol: http, transport

### Haproxy
*   Ports: 80 (http), 8404 (stats)
*   Protocol: http

### Kibana
*   Ports: 5601 (server)
*   Protocol: server

### MySQL
*   Ports: 3306 (mysql)
*   Protocol: mysql

### Postgres
*   Ports: 5432 (postgresql)
*   Protocol: postgresql

## Dependency Map

*   Kibana -> Elasticsearch (port 9200, ref: kibana/config/kibana.yml:elasticsearch.hosts)
*   Haproxy -> Elasticsearch (port 9200, ref: haproxy/config/haproxy.cfg:backend elasticsearch_back)
*   Haproxy -> Kibana (port 5601, ref: haproxy/config/haproxy.cfg:backend kibana_back)

## Security Posture

### Consul
*   Bind address: 0.0.0.0
*   Authentication status: Unspecified
*   Security concerns: None noted

### Elasticsearch
*   Bind address: 0.0.0.0
*   Authentication status: xpack.security.enabled = false (no authentication)
*   Security concerns: No security concerns noted, but using `xpack.security` enables authentication and authorization.

### Haproxy
*   Bind address: 0.0.0.0
*   Authentication status: Unspecified
*   Security concerns: None noted

### Kibana
*   Bind address: 0.0.0.0
*   Authentication status: Unspecified
*   Security concerns: None noted, but using `xpack.security` enables authentication and authorization.

### MySQL
*   Bind address: 0.0.0.0
*   Authentication status: Unspecified
*   Security concerns: Using bind-address = 0.0.0.0 with weak password is a critical security vulnerability.

### Postgres
*   Bind address: *
*   Authentication status: Unspecified
*   Security concerns: None noted

## Key Configuration Highlights

*   Consul:
    *   Data directory `/opt/consul/data` stores Raft state, snapshots, and the local agent cache.
    *   5GB disk allocation is sufficient for dev/POC. Monitor disk usage if the KV store grows significantly.

*   Elasticsearch:
    *   `xpack.security.enabled = false` disables authentication and authorization.
    *   Updating `elasticsearch.hosts` in Kibana to match changes in `http.port` ensures connectivity between services.

*   Haproxy:
    *   Using `maxconn` in the global section limits total connections. Reducing VM memory below 512MB may cause issues under connection spikes.

*   MySQL:
    *   Using bind-address = 0.0.0.0 and a weak password is a critical security vulnerability.
    *   Creating users with host restrictions (`@'10.0.0.%'`) restricts connections to the `10.0.0.0/24` subnet.

*   Postgres:
    *   No security concerns noted, but it should be monitored for performance and resource usage.