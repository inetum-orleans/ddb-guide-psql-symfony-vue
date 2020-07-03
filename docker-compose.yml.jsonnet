local ddb = import 'ddb.docker.libjsonnet';

ddb.Compose({
	services: {
		db: ddb.Image("postgres")
		  {
		    environment+: {POSTGRES_PASSWORD: "ddb"}
		  }
    }
})