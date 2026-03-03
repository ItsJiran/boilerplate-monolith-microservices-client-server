# APP BOILERPLATE APP

### Description : 

App Boilerplate is a monolithic full-stack application architecture boilerplate with best practices including Docker orchestration, monitoring, SSL management, and stress testing.

### How To Run :

- setup-env.sh

To run the core app like (Laravel, Frontend, Mariadb, etc..) (IMPORTANT) (SOME FEATURES NEED SSL)
- run.dev.ssl.sh

#### Note : 
If u have custom ssl especially in production u can custom the ssl pathway after u generated it..
pretty useful for development..

#### SSL Certificate Strategy:
- **Development**: Uses Step CA (self-signed) or mkcert for local SSL
  - See: `infra/STEP-CA.md` for Step CA setup
- **Production**: Uses Let's Encrypt for trusted SSL certificates
  - See: `infra/LETSENCRYPT.md` for production SSL setup            

- setup-hosts.sh
- setup-nginx-host.sh

#### Note : 
Above command will generated assigned url in the .env to the /etc/hosts and the nginx main machine 
pretty useful for development..            

To run the core app like (Laravel, Frontend, Mariadb, etc..)
- run.app.sh 


#### Note For Monitoring : 
Below command will generate the example config promtail and prometheus.. the variable is defined 
by the .env.devops
- setup-monitoring-config.sh 

To run the monitoring exporter services ( Node exporter, Promtail, Mariadb Exporter etc.. )
- run.devops.exporter.sh

To run the monitoring services (Grafana, Loki, etc..)
- run.devops.sh

To run the portainer service..
- run.portainer.sh


After that u can visit.
- myapp.test (sesuaikan APP_URL di .env)
- api.myapp.test
- s3.myapp.test
- monitoring.myapp.test


### NOTE :
For further usecase don't forget to create prometheus.yml to
add matrics to the grafana u can use the prometheus.example.yml 
for references..

Match the endpoint and port exporter with the 
.env that u setup or u can use default localhost that 
example file provided.


Developed by : Akterma Technology [AT] founded by ItsJiran
Timestamp : 2026/01/01 