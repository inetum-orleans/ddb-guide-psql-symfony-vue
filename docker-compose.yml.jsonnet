local ddb = import 'ddb.docker.libjsonnet';

local domain_ext = std.extVar("core.domain.ext");
local domain_sub = std.extVar("core.domain.sub");

local domain = std.join('.', [domain_sub, domain_ext]);

ddb.Compose({
	services: {
		db: ddb.Build("postgres") + ddb.User() +
		    ddb.Binary("psql", "/project", "psql --dbname=postgresql://postgres:ddb@db/postgres") +
		    ddb.Binary("pg_dump", "/project", "pg_dump --dbname=postgresql://postgres:ddb@db/postgres") +
		  {
		    environment+: {POSTGRES_PASSWORD: "ddb"},
		    volumes+: [
          'db-data:/var/lib/postgresql/data',
          ddb.path.project + ':/project'
		    ]
		  },
    php: ddb.Build("php") +
         ddb.User() +
         ddb.Binary("composer", "/var/www/html", "composer") +
         ddb.Binary("php", "/var/www/html", "php") +
         ddb.XDebug() +
         {
          volumes+: [
             ddb.path.project + ":/var/www/html",
             "php-composer-cache:/composer/cache",
             "php-composer-vendor:/composer/vendor"
          ]
         },
    web: ddb.Build("web") +
         ddb.VirtualHost("80", std.join('.', ['api', domain]))
         {
              volumes+: [
                 ddb.path.project + ":/var/www/html",
                 ddb.path.project + "/.docker/web/apache.conf:/usr/local/apache2/conf/custom/apache.conf",
              ]
         },
    },
})