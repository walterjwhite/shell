# Project Diagram Generation Workflow

### Important Notes

- Do not conduct any source control management (SCM) or Git operations; these will be managed externally.
- Place all generated / updated diagrams @ `./diagrams.secret` as separate files underneath that directory.

## Task: Generate Architectural, Network Services, Entity Relationships, and Sequence Diagrams

### Step 1: Architectural Diagram

- **Objective:** Create an architectural diagram to outline the system structure.
- **Components to Include:**
  - Application layers (presentation, business logic, data access)
  - Major modules or services
  - External dependencies (third-party services, databases)
- **Tools:** Use diagramming tools like Lucidchart, Draw.io, or Microsoft Visio.
- **Filename:** `./diagrams.secret/architecture` with appropriate extension.

### Step 2: Network Services Diagram

- **Objective:** Develop a network services diagram to represent the interactions between different services.
- **Components to Include:**
  - Services and APIs
  - Communication protocols (HTTP, WebSockets, etc.)
  - Data flow between services
- **Tools:** Use diagramming tools like Lucidchart, Draw.io, or Microsoft Visio.
- **Filename:** `./diagrams.secret/network-services` with appropriate extension.

### Step 3: Entity Relationship Diagram (ERD)

- **Objective:** Create an entity relationship diagram to illustrate the data model.
- **Components to Include:**
  - Entities (tables, collections)
  - Relationships (one-to-one, one-to-many, many-to-many)
  - Key attributes (primary keys, foreign keys)
- **Tools:** Use tools like MySQL Workbench, Lucidchart, or ERDPlus.
- **Filename:** `./diagrams.secret/entity-relationship` with appropriate extension.

### Step 4: Sequence Diagram

- **Objective:** Generate sequence diagrams to represent the interactions between objects over time.
- **Components to Include:**
  - Participants (objects or services involved)
  - Messages (method calls, responses)
  - Lifelines and activation boxes to show time progression
- **Tools:** Use tools like Lucidchart, Draw.io, or Visual Paradigm.
- **Filename:** `./diagrams.secret/sequence` with appropriate extension.

### Step 5: Review Diagrams

- Review each diagram for clarity, accuracy, and completeness.
- Ensure that all components are labeled correctly and adhere to the intended design principles.

### Step 6: Document Diagrams

- Export the diagrams in appropriate formats (e.g., PNG, PDF).
- Compile documentation explaining each diagram and its significance in the project.
- Documentation should be placed under, `./diagrams.secret/${DIAGRAM_NAME}-notes.md`

### Step 7: Share Diagrams

- Share the diagrams with the project team for feedback and collaboration.
- Publish them to the project repository or documentation site for reference.
- Make all changes on the existing branch, do NOT create a new branch
