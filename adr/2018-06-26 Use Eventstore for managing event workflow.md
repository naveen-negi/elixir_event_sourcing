
* **Title**:  Using eventstore for managing core leave workflow.

* **Status**: accepted

* **Context**: Leave management workflow deals with a lot of events where user can apply for leave, approver can approve leave. Although Current implementation does not consider multi-level approval (where leave must be approved by multiple people), this is an anticipated feature for LMS.

* **Decision**: We will be using EventStore for LMS, and each event should be captured in Eventstore.

* **Consequences**: This means that Eventstore is source of truth for our application. All write/updates goes to Eventstore, however for read model, we need to implement projections and stored in database.
