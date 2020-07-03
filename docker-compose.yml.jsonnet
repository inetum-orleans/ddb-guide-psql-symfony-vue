local ddb = import 'ddb.docker.libjsonnet';

ddb.Compose({
	services: {
		db: ddb.Image("postgres") +
		    ddb.Binary("psql", "/project", "psql --dbname=postgresql://postgres:ddb@db/postgres") +
		    ddb.Binary("pg_dump", "/project", "pg_dump --dbname=postgresql://postgres:ddb@db/postgres") +
		  {
		    environment+: {POSTGRES_PASSWORD: "ddb"},
		    volumes+: [
          'db-data:/var/lib/postgresql/data',
          ddb.path.project + ':/project'
		    ]
		  }
    }
})