# Code Review Workflow

### Caveat for Tight Coupling

- If **no code review comments** are found, state this in the report and remove the directory, `./next-code-review.secret`, if it exists.
- If there is **only one code review comment**, note that in the report directory, `./code-review.secret`.
- If there are additional code review comments beyond those listed, document them in a separate directory at `./next-code-review.secret` for future remediation efforts.
- No other files should be generated.

### Important Notes

- Do not conduct any source control management (SCM) or Git operations; these will be managed externally.

## Task: Perform a Code Review

### Step 1: Prepare for Review

- Familiarize yourself with the objectives of the code to be reviewed.
- Ensure the code is accessible (e.g., through a pull request or shared repository).

### Step 2: Review Criteria

Use the following criteria as a baseline for the code review:

#### 1. **Code Quality**

- **Readability:** Is the code easy to read and understand?
- **Consistency:** Are naming conventions and coding standards consistently applied?
- **Comments and Documentation:** Is the code well-commented where necessary? Are functions and components adequately documented?

#### 2. **Functionality**

- **Correctness:** Does the code produce the expected results? Are all requirements met?
- **Error Handling:** Are potential errors handled gracefully? Is the code robust against edge cases?

#### 3. **Performance**

- **Efficiency:** Are there any areas where performance can be improved?
- **Resource Management:** Is memory and resource usage optimized? Are there any potential leaks?

#### 4. **Maintainability**

- **Modularity:** Is the code broken into small, reusable functions or modules?
- **Testability:** Is the code written in a way that allows for unit tests? Are there tests in place?

#### 5. **Security**

- **Vulnerabilities:** Are there any obvious security vulnerabilities?
- **Data Handling:** Is sensitive data handled appropriately? Are any third-party libraries securely integrated?

#### 6. **Adherence to Standards**

- **Style Guide Compliance:** Does the code follow the agreed-upon style guide?
- **Architecture Compliance:** Does the code fit within the project’s architecture/design principles?

### Step 3: Provide Feedback

- Note areas of strength as well as areas for improvement.
- Use constructive language to suggest changes or improvements.

### Step 4: Document Review Findings

- Create a concise document summarizing the findings and feedback, including:
  - Positive aspects of the code
  - Specific areas that need improvement
  - Suggested changes with reasoning
  - write findings in directory `./code-review.secret`
