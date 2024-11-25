# DevOps Eksamen

### Oppgave 1

##### Leveranse 1:

HTTP Endepunkt for Lambdafunksjonen, som kan testes i Postman: [https://jpw4h08k23.execute-api.eu-west-1.amazonaws.com/Prod/generate-image](https://jpw4h08k23.execute-api.eu-west-1.amazonaws.com/Prod/generate-image)

Postman:

Requestener en POST og skal ha en slik Body i raw JSON format:

{

    "prompt": "car"

}

##### Leveranse 2:

Link til vellykket Github Actions Workflow for Lambafunksjonen:

[https://github.com/Necropion/PGR301-DevOps-Exam/actions/runs/11890829390/job/33130299159](https://github.com/Necropion/PGR301-DevOps-Exam/actions/runs/11890829390/job/33130299159)

### Oppgave 2

##### Leveranse:

Link til vellykket Github Actions Workflow fra en feature branch der infrastrukturkoden bare utfører terraform plan:

[https://github.com/Necropion/PGR301-DevOps-Exam/actions/runs/11892512942/job/33135521936](https://github.com/Necropion/PGR301-DevOps-Exam/actions/runs/11892512942/job/33135521936)

Link til Github Actions Workflow I main branch der infrastruktur koden kjører kun terraform apply når feature branchen ble merget til main branchen:

[https://github.com/Necropion/PGR301-DevOps-Exam/actions/runs/11892581721/job/33135735061](https://github.com/Necropion/PGR301-DevOps-Exam/actions/runs/11892581721/job/33135735061)

SQS-kø URL for testing:

[https://sqs.eu-west-1.amazonaws.com/244530008913/image-generation-queue](https://sqs.eu-west-1.amazonaws.com/244530008913/image-generation-queue)

### Oppgave 3

##### Leveranse:

Taggestrategi:

**latest**:

- Viser til den nyeste bygde versjonen. Denne taggen er nyttig når du trenger den aller nyeste versjonen av imaget.

**main**:

- Indikerer den stabile versjonen fra main-branchen.

**v-tidspunkt** (eller en enklere versjon som v1, v2):

- I dette eksemplet genererte jeg en versjonstag basert på et tidsstempel (vYYYY-MM-DD_HH-MM). Alternativt kan du bruke inkrementelle versjoner som v1, v2, osv.
- Denne taggen gjør det enklere å spore endringer over tid og gir en tydelig versjonshistorikk som kan refereres til ved testing, distribusjon eller rollback.

Container Image: necropion/java-sqs-client

SQS Url: [https://sqs.eu-west-1.amazonaws.com/244530008913/image-generation-queue](https://sqs.eu-west-1.amazonaws.com/244530008913/image-generation-queue)

### Oppgave 4

For å teste alarmen med en spesifik epost adresse kan man endre terraform.tfvars filen som har variabelen notification_email

Som jeg personlig har testet har jeg implementert alarmen sånn at det kommer en epost etter 2 raske requests for bilde til SQS linken. Må gjerne prøve med flere raske meldinger om det ikke kommer opp.

### Oppgave 5

### Serverless (FaaS) vs. Mikrotjenester (Container-teknologi)

##### **Automatisering og Kontinuerlig Levering (CI/CD)**

Med en serverless-arkitektur er automatiseringen enklere å håndtere fordi Function as a Service (FaaS)-funksjoner er små og selvstendige der de kan deployes raskt og isolert. CI/CD-pipelines er enkelt å definere dersom hver funksjon kan ha sin egen pipeline. Disse pipelines kan da håndtere egen versjonskontroll og deployment.

Samtidig kan mange små funksjoner i produksjon føre til flere små CI/CD-pipelines, som gjør at den totale pipelinestrukturen blir mer kompleks. For å vedlikeholde alle disse små pipelines kan føre til en fragmentering av automatiseringsprosessen, som gir utfordringer når man skal sikre god funksjonalitet gjennom hele systemet.

En annen stor fordel med serverless er skaleringsstrategiene som er automatisert. Diverse mekanismer er i gang og sørger for riktig ressursbruk basert på etterspørsel, uten behov for manuelt arbeid med det.

Containerbaserte mikrotjenester gir større kontroll over hele CI/CD-prosessen. Tjenesten kan bygges, testes og deployes som en enhet. Verktøy som GitHub Actions og Kubernetes kan brukes til å definere komplekse pipelines men også styre deployment av flere mikrotjenester samtidig.

Mikrotjenester kan ha en krevende utrullingsprosess, spesielt hvis man har mange tjenester som skal oppdateres samtidig. Canary releases og blue/green deployments er ofte brukt i slike situasjoner, men disse strategiene krever krevende planlegging og en del ressurser.

En annen fordel med mikrotjenester er container orchestrators som Kubernetes som muliggjør deling av ressurser mellom flere tjenester og gir god ressursutnyttelse i en utviklingspipeline.

##### **Observability (Overvåkning)**

Overvåkning i serverless-arkitekturer er en utfordrende sak dersom funksjonene er kortlivede, "stateless", og kjører i isolerte miljøer. Logging og feilsøking der det skal sjekkes flere funksjoner enn ett enkelt et, vil skape en utfordring. Man har tjenester som CloudWatch Logs og AWS X-Ray som skal hjelpe med å spore funksjonskjøringer. Men for å få dette til å fungere effektivt til logging og feilsøking vil det kreve ekstra konfigurasjon og innsikt for å få til et helhetlig bilde av systemet.

Fordelen med serverless ligger i det som kalles telemetri som er innebygd med AWS, dette vil samles inn automatisk, slik at man får innsikt i ressursforbruket, responstidene og feilhåndteringen.

Mikrotjenester kjører konstant, og standarden er å sentralisere loggene mellom alle tjenestene. Man har en rekke med verktøy som man kan benytte, og en populær stack er ELK (Elasticsearch, Logstash og Kibana) stacken. Dette gjør det enklere å ha innsikt i ytelse, feilhåndtering og tilgjengelighet, og gir også full kontroll over hvordan loggingen konfigureres.

##### **Skalerbarhet og kostnadskontroll**

Den store fordelen med serverless er at ressursene skaleres automatisk etter belastningen. Det gjør at det blir enklere å håndtere trafikk uten noen manuell konfigurasjon. Man betaler kun per kjøring per funksjon, som også gir god kostnadskontroll.

For systemer med uforutsigbare brukstopper er FaaS mer kostnadseffektivt fordi man slipper å betale for tiden en applikasjon hadde vært kjørende og oppe i tider den hadde vært inaktiv. Men kjører man tunge funksjoner konstant, blir kostnadene fort høye.

Med mikrotjenester kjører containere konstant uavhengig av belastningen. Dette vil si at man må betale for denne infrastrukturen selv om den er underbenyttet. Kostnadene kan dermed være mer forutsigbare, men også mer statiske.

Kubernetes verktøyet gir mer fleksibilitet til å skalere opp og ned ressurser etter behov. Dette vil kreve innsikt i ressurs-håndtering for å balansere kostnad og ytelse effektivt. Systemer som er containerbaserte vil da fungere best for tjenester med jevn last.

##### **Eierskap og ansvar**

Ved bruk av FaaS, som AWS Lambda, trenger ikke teamet å bekymre seg for infrastrukturen. Med AWS trenger man ikke å planlegge serveradministrasjon, skalering, patching og oppdateringer på egen hånd. Teamet kan fokusere på selve applogikken.

Redusert eierskap kan også føre til mindre kontroll. Funksjoner må ofte testes i skyen, som fører til at debugging og lokal testing blir mer komplisert. Det krever gode mock-verktøy eller bruk av cloud-miljøet for testing, som kan øke utviklingstiden.

Mikrotjenestearkitekturen gir utviklingsteamet full kontroll over både applikasjonen og infrastrukturen. DevOps-teamet kan da optimalisere for ytelse, oppetid og tilpasse miljøene etter behov.

Grunnet eierskapet må teamet håndtere oppgaver som sikkerhet, nettverkskonfigurasjon, ressursadministrasjon og overvåkning av miljøene. Det gir større frihet, men også større ansvar.

##### **Konklusjon**

Serverless-arkitektur (FaaS) er en god løsning for rask utvikling, som har lav kostnad der man ikke har en jevn brukerstrafikk, og i tilfeller der man ønsker å redusere kompleksitet. Dette systemet passer godt for applikasjoner med varierende belastning, der skalering er kritisk, og der man bryr seg mer om kode fremfor infrastruktur.

Containerbasert mikrotjeneste-arkitektur gir større kontroll og fleksibilitet, spesielt ved konstant og jevn brukerstrafikk, og der man ønsker å ha en effektiv drift med tilpasset infrastruktur. Det gir gode overvåkningsmuligheter og sammenhengende CI/CD-pipelines, men krever også mer innsats og kompetanse.