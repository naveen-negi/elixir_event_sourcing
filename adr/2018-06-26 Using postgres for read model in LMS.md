
* **Title**: Using Postgres as read-model in lms workflow

* **Status**: accepted

* **Context**: In LMS, read-model read model is not tightly coupled to write model and can be independently scaled, Eventstore for writing events uses postgres underneath so using postgres for read model reduces our external dependencies.

* **Decision**: Using Postgres for read-model
* **Consequences**: LMS workflow is eventual consistent,it means that it might take sometime for these updates to be propogated to read model.
