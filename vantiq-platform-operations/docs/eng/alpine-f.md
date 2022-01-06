# alpine-f
- Tool for verifying Name Resolution with `nslookup` and accessing Postgres with `psql` from within a k8s cluster.  

## How to use
Deploy with the following command.
```sh
kubectl apply -f https://raw.githubusercontent.com/fujitake/vantiq-related/main/vantiq-platform-operations/conf/tools/alpine-f.yaml
```

Enter the alpine-f shell.
```sh
kubectl exec -n vantiqtools -it alpine-f -- ash

/ #
```

Undeploy with the following command.  
```sh
kubectl delete -f https://raw.githubusercontent.com/fujitake/vantiq-related/main/vantiq-platform-operations/conf/tools/alpine-f.yaml
```

The following commands are possible to execute in the alpine-f shell.  

### Verify Name Resolution

```sh
$ nslookup internal.vantiqjp.com
Server:		10.100.0.10
Address:	10.100.0.10:53

Non-authoritative answer:

Non-authoritative answer:
Name:	internal.vantiqjp.com
Address: 20.194.148.153
```

### Verify reachability of access to Vantiq services and the repositories

```sh
$ curl -visk https://internal.vantiqjp.com
*   Trying 20.194.148.153:443...
* TCP_NODELAY set
* Connected to internal.vantiqjp.com (20.194.148.153) port 443 ('#0')
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
```
`-v` - Show details  
`-i` - Check the Http Response Header and the Body.  
`-s` - Check the result of the Response only.  
`-k` - Skip SSL certificates for self-signed sites, etc.



### Check the Postgres connections

```sh
$ psql --host=keycloak-postgresql.czjeauchlabl.ap-northeast-1.rds.amazonaws.com --username=keycloak --password --dbname=keycloak
Password:
psql (12.2, server 11.10)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

keycloak=> \l  # list the DBs
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 keycloak  | keycloak | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres  | keycloak | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 rdsadmin  | rdsadmin | UTF8     | en_US.UTF-8 | en_US.UTF-8 | rdsadmin=CTc/rdsadmin
 template0 | rdsadmin | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/rdsadmin          +
           |          |          |             |             | rdsadmin=CTc/rdsadmin
 template1 | keycloak | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/keycloak          +
           |          |          |             |             | keycloak=CTc/keycloak
(5 rows)
```
[PostgreSQL command cheat sheet](https://titanwolf.org/Network/Articles/Article?AID=16a58645-233a-41b8-a479-45b573ee1061#gsc.tab=0)


### Dump the Keycloak DB
```
/ # pg_dump -Fc -v --host=keycloakvantiqjpinternalprod.postgres.database.azure.com --username=keycloak@keycloakvantiqjpinternalprod.postgres
.database.azure.com --password --dbname=keycloak -f keycloak.dump
Password:
pg_dump: last built-in OID is 16383
pg_dump: reading extensions
pg_dump: identifying extension members
pg_dump: reading schemas
pg_dump: reading user-defined tables
pg_dump: reading user-defined functions
pg_dump: reading user-defined types
pg_dump: reading procedural languages
...
```

### Check the Global IP for Outbound communication
Check the Public IP address of the Internet Gateway and the NAT Gateway etc.
```sh
curl ifconfig.me
```
