# TrustLink — Database Structure Explained 🗂️

> **Who is this document for?**
> This guide is written for anyone who wants to understand how TrustLink stores its data — without needing to know how to read a technical database diagram. No programming knowledge is required. Every table, every column, and every connection between them is explained in plain, everyday language.

---

## Table of Contents

- [What is an ERD?](#what-is-an-erd)
- [How to Read This Document](#how-to-read-this-document)
- [The Big Picture — All Tables at a Glance](#the-big-picture--all-tables-at-a-glance)
- [Table 1 — users](#table-1--users)
- [Table 2 — wallets](#table-2--wallets)
- [Table 3 — kyc\_documents](#table-3--kyc_documents)
- [Table 4 — contracts](#table-4--contracts)
- [Table 5 — payments](#table-5--payments)
- [Table 6 — milestones](#table-6--milestones)
- [Table 7 — disputes](#table-7--disputes)
- [Table 8 — audit\_logs](#table-8--audit_logs)
- [Table 9 — notifications](#table-9--notifications)
- [How the Tables Connect — Relationships Explained](#how-the-tables-connect--relationships-explained)
- [A Complete Real-World Example](#a-complete-real-world-example)
- [Glossary of Terms](#glossary-of-terms)

---

## What is an ERD?

An **ERD** stands for **Entity Relationship Diagram**. Think of it as a map of how a system stores information.

Imagine a filing cabinet with multiple drawers. Each drawer holds a specific type of record — one drawer for users, one for contracts, one for payments, and so on. The ERD is a visual diagram that shows:

- **What drawers (tables) exist** and what information each one holds
- **How the drawers relate to each other** — for example, a contract always belongs to a user, and a payment always belongs to a contract

PakEscrow's ERD has **9 tables** (drawers), each holding a specific type of data that the platform needs to operate.

---

## How to Read This Document

Each table section below follows the same pattern:

1. **What it is** — a plain-English description of what this table represents in the real world
2. **What it stores** — every column explained in simple terms
3. **Why it matters** — how this table plays a role in the platform

At the end, the **Relationships** section explains how all the tables link together using real-world analogies.

---

## The Big Picture — All Tables at a Glance

Here is a summary of all 9 tables in the database and their purpose in one sentence each:

| # | Table Name | What It Represents |
|---|---|---|
| 1 | `users` | Every person registered on the platform — both freelancers and clients |
| 2 | `wallets` | The virtual money balance that every user holds on the platform |
| 3 | `kyc_documents` | Identity verification documents submitted by users (e.g. CNIC) |
| 4 | `contracts` | The escrow agreements created between a client and a freelancer |
| 5 | `payments` | Records of every deposit, withdrawal, or transfer of money |
| 6 | `milestones` | Individual phases or stages within a contract |
| 7 | `disputes` | Formal disagreements raised by either party during a contract |
| 8 | `audit_logs` | A tamper-proof record of every important action taken on the platform |
| 9 | `notifications` | Messages sent to users via email, SMS, or in-app alerts |

---

## Table 1 — `users`

### What It Is

The `users` table is the foundation of the entire database. Every single person who creates an account on PakEscrow — whether they are a **client** (someone who hires freelancers) or a **freelancer** (someone who does the work) — gets one row in this table.

Think of it as the **membership register** of the platform. Before anyone can create a contract, make a payment, or submit a document, they must first exist in this table.

### What It Stores

| Column | Plain-English Meaning |
|---|---|
| `id` | A unique identity number automatically assigned to each user — like a national ID number, but for the platform. No two users ever share the same ID. |
| `email` | The user's email address, used for login and communication. |
| `phone` | The user's mobile phone number, used for SMS verification and two-factor authentication. |
| `role` | Whether this person is a `FREELANCER`, a `CLIENT`, an `ADMIN`, a `MODERATOR`, or a `COMPLIANCE_OFFICER`. This determines what they are allowed to do on the platform. |
| `kyc_tier` | A number (1, 2, or 3) representing how fully this user has verified their identity. Tier 1 is basic phone verification. Tier 3 is full CNIC plus address proof. Higher tiers allow larger contracts. |
| `is_active` | A simple YES or NO flag. If a user's account is suspended by an admin, this becomes NO and they cannot log in. |
| `profile_data` | A flexible storage area for extra profile details — such as a freelancer's skills, portfolio links, and bio. |
| `created_at` | The exact date and time the account was created. |

### Why It Matters

Every other table in the database points back to `users` in some way. A contract belongs to a user. A wallet belongs to a user. A notification is sent to a user. Without a user record, nothing else in the system can exist.

---

## Table 2 — `wallets`

### What It Is

The `wallets` table is the **virtual bank account** system inside PakEscrow. When a client deposits money to fund a contract, or when a freelancer earns money from a completed contract, those balances are tracked here.

Every user gets exactly **one wallet** when they register. The wallet does not hold real physical cash — it holds a numerical balance that reflects the money the platform is managing on the user's behalf.

### What It Stores

| Column | Plain-English Meaning |
|---|---|
| `id` | A unique ID for this wallet record. |
| `user_id` | A reference to the user who owns this wallet. This is the link back to the `users` table. |
| `balance` | The total amount of money in the user's wallet, stored with up to 4 decimal places to avoid rounding errors. |
| `locked_balance` | The portion of the balance that is currently tied up inside an active escrow contract and cannot be withdrawn or spent elsewhere. |
| `currency` | The currency of the wallet — defaults to `PKR` (Pakistani Rupee). |
| `is_frozen` | If an admin suspects fraudulent activity, they can freeze a wallet. A frozen wallet cannot send or receive money until reviewed. |
| `updated_at` | The last time this wallet's balance was changed. |

### Why It Matters

The key idea here is **locked_balance**. When a client funds a contract, their money does not go directly to the freelancer — it is moved into the `locked_balance` field. It stays locked there until the work is approved. This is the core mechanism that makes escrow work: the money exists and is real, but neither party can touch it until the agreed conditions are met.

> **Practical example:** Hamza (a client) has PKR 50,000 in his wallet. He funds a contract for PKR 30,000. His `balance` stays at PKR 50,000, but his `locked_balance` becomes PKR 30,000. His *available* balance (balance minus locked) is now only PKR 20,000. He cannot withdraw the locked PKR 30,000 until the contract is either completed, cancelled, or refunded.

---

## Table 3 — `kyc_documents`

### What It Is

KYC stands for **Know Your Customer**. It is a standard process used by financial platforms worldwide to verify that users are who they claim to be. This table stores the identity documents that users upload to prove their identity.

In Pakistan, the primary identity document is the **CNIC (Computerised National Identity Card)**. Users must upload a photo of their CNIC front, back, and a selfie to unlock higher transaction limits on the platform.

### What It Stores

| Column | Plain-English Meaning |
|---|---|
| `id` | A unique ID for this document submission. |
| `user_id` | Which user submitted this document. Links back to the `users` table. |
| `document_type` | The type of document — for example: `CNIC_FRONT`, `CNIC_BACK`, `SELFIE`, `PROOF_OF_ADDRESS`. |
| `file_s3_key` | The file's location in secure cloud storage (Amazon S3). The actual document image is not stored in the database — only a reference to where it is stored. |
| `status` | The current review status of the document: `PENDING` (just uploaded), `UNDER_REVIEW` (admin is checking it), `APPROVED`, `REJECTED`, or `EXPIRED`. |
| `reviewed_by` | The ID of the admin or compliance officer who reviewed this document. |
| `reviewed_at` | The exact date and time the document was reviewed. |

### Why It Matters

KYC documents are the platform's way of building trust and meeting legal requirements. A user who has not verified their identity is limited to small transactions. A user who has uploaded and had their CNIC approved can handle much larger contracts. This also protects the platform from fraudulent accounts.

---

## Table 4 — `contracts`

### What It Is

The `contracts` table is the **heart of PakEscrow**. Every escrow agreement between a client and a freelancer is recorded here as a single row. A contract defines the terms of the work: what needs to be done, how much it pays, when it is due, and what conditions must be met before money is released.

Think of it as a **digital work order** that both parties have agreed to and that the platform enforces.

### What It Stores

| Column | Plain-English Meaning |
|---|---|
| `id` | A unique ID for this contract. |
| `reference_number` | A human-readable contract number like `PKE-2024-00847`. Used when communicating with support or referencing a contract in conversation. Guaranteed to be unique. |
| `client_id` | The ID of the user who created this contract (the person paying). Links to `users`. |
| `freelancer_id` | The ID of the user who accepted this contract (the person doing the work). Links to `users`. |
| `title` | A short name for the project, e.g. "Logo Design for Al-Noor Foods". |
| `scope` | A detailed description of exactly what work needs to be delivered. |
| `total_amount` | The total money agreed upon for the entire contract, stored with 4 decimal places. |
| `platform_fee` | The fee that TrustLink charges for facilitating this contract. Calculated at the time of contract creation and stored here for transparency. |
| `currency` | The currency for this contract — defaults to `PKR`. |
| `status` | Where this contract currently stands in its lifecycle. Possible values: `DRAFT`, `PENDING_ACCEPTANCE`, `FUNDED`, `IN_PROGRESS`, `DELIVERED`, `COMPLETED`, `DISPUTED`, `CANCELLED`, `REFUNDED`. |
| `terms` | A flexible storage area for any additional agreed-upon terms — for example, file format requirements, communication expectations, or revision policies. |
| `max_revisions` | The maximum number of revisions the client can request before the contract can be escalated to a dispute. Default is 3. |
| `revision_count` | How many revisions have been requested so far on this contract. |
| `delivery_deadline` | The date and time by which the freelancer must submit their work. If this passes with no delivery, the contract can be auto-cancelled. |
| `funded_at` | The exact moment the client's payment was confirmed and locked in escrow. |
| `completed_at` | The exact moment the client approved delivery and funds were released to the freelancer. |
| `cancelled_at` | The exact moment the contract was cancelled and funds were returned to the client. |
| `created_at` | When the contract was first created. |
| `updated_at` | The last time any detail of the contract changed. |

### Why It Matters

The `contracts` table is central to everything. Payments, milestones, and disputes all revolve around a contract. The `status` field acts like a traffic light — it tells the system (and both users) exactly what stage the agreement is in and what actions are allowed next.

---

## Table 5 — `payments`

### What It Is

The `payments` table records **every single movement of money** through the platform. When a client deposits funds via JazzCash to start a contract, that creates a payment record. When a freelancer requests a withdrawal to their bank account, that also creates a payment record.

This table is the **financial transaction log** — a permanent, detailed record of every rupee that ever moved.

### What It Stores

| Column | Plain-English Meaning |
|---|---|
| `id` | A unique ID for this payment transaction. |
| `contract_id` | Which contract this payment is associated with. Links to `contracts`. |
| `user_id` | Which user made or received this payment. Links to `users`. |
| `amount` | How much money was involved in this transaction, stored with 4 decimal places. |
| `gateway` | Which payment service processed this transaction — for example `JAZZCASH`, `EASYPAISA`, `HBL`, or `BANK_TRANSFER`. |
| `gateway_ref` | The unique reference number issued by the payment gateway (e.g. JazzCash transaction ID). Used to match platform records with the gateway's own records. |
| `status` | Whether the payment succeeded, failed, or is still pending: `PENDING`, `SUCCESS`, `FAILED`, `REFUNDED`. |
| `direction` | Whether money was coming IN to the platform (`DEPOSIT`) or going OUT of the platform (`WITHDRAWAL` or `RELEASE`). |
| `created_at` | When this payment record was created. |

### Why It Matters

Every financial action produces a permanent record here. This table is critical for dispute resolution (proving a payment was made), for financial reporting (how much money flowed through the platform), and for regulatory compliance (audit trail of all transactions).

---

## Table 6 — `milestones`

### What It Is

The `milestones` table handles contracts that are broken into **multiple phases or stages**. Instead of one large payment at the end of a long project, milestones allow the money to be divided into smaller portions — each released when that specific phase of the work is completed and approved.

For example, a six-week software development contract might have four milestones: Design, Development, Testing, and Launch. Each milestone has its own deadline, amount, and approval step.

### What It Stores

| Column | Plain-English Meaning |
|---|---|
| `id` | A unique ID for this milestone. |
| `contract_id` | Which contract this milestone belongs to. Links to `contracts`. |
| `title` | A short name for this phase, e.g. "Phase 2: Frontend Development". |
| `description` | A detailed explanation of what work needs to be completed to fulfil this milestone. |
| `amount` | How much money is released when this specific milestone is approved. |
| `sequence` | The order of this milestone within the contract — 1 for the first milestone, 2 for the second, and so on. |
| `status` | The current state of this milestone: `PENDING`, `IN_PROGRESS`, `DELIVERED`, `APPROVED`, `DISPUTED`, or `CANCELLED`. |
| `due_date` | The deadline for delivering this specific milestone. |
| `funded_at` | When the funds for this milestone were locked in escrow. |
| `released_at` | When the funds for this milestone were released to the freelancer after approval. |

### Why It Matters

Milestones protect both parties on long-running projects. The freelancer gets paid progressively as they deliver, rather than waiting until the very end. The client only releases each portion of money when they are satisfied with that phase. This dramatically reduces the financial risk of large, complex projects.

---

## Table 7 — `disputes`

### What It Is

The `disputes` table records **formal complaints** raised by either the client or the freelancer when they cannot agree on the outcome of a contract. A dispute puts the contract on hold — no money can be released or refunded until a PakEscrow moderator reviews the case and makes a decision.

Think of it as the platform's **conflict resolution record**.

### What It Stores

| Column | Plain-English Meaning |
|---|---|
| `id` | A unique ID for this dispute case. |
| `contract_id` | Which contract this dispute is about. Links to `contracts`. |
| `raised_by` | The ID of the user (client or freelancer) who opened the dispute. Links to `users`. |
| `reason` | The category of the complaint: `NON_DELIVERY` (work was never submitted), `QUALITY_NOT_MET` (work does not match agreed standards), `SCOPE_DISAGREEMENT` (the work delivered does not match what was agreed), `LATE_DELIVERY`, `PAYMENT_WITHHELD`, or `OTHER`. |
| `status` | Where the dispute stands right now: `RAISED`, `UNDER_REVIEW`, `EVIDENCE_SUBMITTED`, `DECISION_PENDING`, `RESOLVED`, or `ESCALATED`. |
| `assigned_to` | The ID of the moderator or compliance officer handling this case. Links to `users`. |
| `resolution_type` | The final decision: full release to the freelancer, full refund to the client, or a partial split. |
| `resolution_note` | The written explanation from the moderator explaining why they reached this decision. |
| `resolved_at` | The date and time the dispute was officially closed. |
| `created_at` | When the dispute was first opened. |

### Why It Matters

Without a dispute system, a disagreement between a client and a freelancer would have no resolution path — the money would just sit locked in escrow indefinitely. The dispute table ensures there is always a clear, documented path forward, with a neutral third party (TrustLink team) making the final call based on evidence submitted by both sides.

---

## Table 8 — `audit_logs`

### What It Is

The `audit_logs` table is the **security black box** of TrustLink. Every important action taken on the platform — whether by a user, a freelancer, a client, or an admin — is permanently recorded here. This table cannot be edited or deleted. Once an entry is written, it stays forever.

Think of it like a CCTV recording of every action. If anything ever goes wrong — a disputed transaction, a fraud investigation, a legal inquiry — this table provides a complete, trustworthy record of exactly what happened and when.

### What It Stores

| Column | Plain-English Meaning |
|---|---|
| `id` | A unique ID for this log entry. |
| `actor_id` | The ID of the user who performed the action. Links to `users`. |
| `action` | A description of what was done — for example `CONTRACT_FUNDED`, `DISPUTE_RAISED`, `KYC_APPROVED`, `FUNDS_RELEASED`. |
| `entity_type` | What kind of record was affected — for example `contract`, `wallet`, `user`, `dispute`. |
| `entity_id` | The specific ID of the record that was changed. |
| `before_snapshot` | A complete copy of the data as it looked *before* the action was taken. |
| `after_snapshot` | A complete copy of the data as it looked *after* the action was taken. |
| `ip_address` | The internet address of the device that performed the action — useful for detecting fraud. |
| `user_agent` | The browser or app that was used to perform the action. |
| `created_at` | The exact date and time the action happened. |
| `chain_hash` | A special security fingerprint calculated from this entry and the previous one. If anyone tries to secretly alter or delete a log entry, the fingerprint chain breaks, and the tampering becomes detectable. |

### Why It Matters

Financial platforms are legally required to maintain accurate records. The audit log provides regulators, compliance officers, and legal teams with an unquestionable history of everything that happened. It also protects PakEscrow from false claims — if a user says "I never approved that contract", the audit log shows exactly when their account performed that action and from which device.

---

## Table 9 — `notifications`

### What It Is

The `notifications` table keeps a record of every **message sent to a user** by the platform. This includes emails, SMS messages, and in-app notifications. Every time something important happens — a contract is funded, a delivery is submitted, a dispute is opened — the platform automatically sends a notification to the relevant user and logs it here.

### What It Stores

| Column | Plain-English Meaning |
|---|---|
| `id` | A unique ID for this notification record. |
| `user_id` | Which user this notification was sent to. Links to `users`. |
| `event_type` | What triggered this notification — for example `CONTRACT_FUNDED`, `DELIVERY_SUBMITTED`, `DISPUTE_RAISED`, `FUNDS_RELEASED`, `KYC_APPROVED`. |
| `channel` | How the notification was sent: `EMAIL`, `SMS`, or `IN_APP`. |
| `payload` | The actual content of the message — the subject line, body text, and any dynamic values like the contract reference number or amount. |
| `status` | Whether the message was successfully delivered (`SENT`), failed (`FAILED`), or is waiting to be sent (`PENDING`). |
| `sent_at` | The exact date and time the notification was delivered. |

### Why It Matters

Notifications keep both parties informed in real time so no one is left wondering what is happening with their contract or their money. The log also helps the support team diagnose delivery problems — for example, if a user says "I never got a notification", the support team can check this table and see exactly what was sent, when, and through which channel.

---

## How the Tables Connect — Relationships Explained

This section explains, in plain English, how the 9 tables are linked together. In the diagram, these links are drawn as lines with labels like **1:1** or **1:N**.

### What Do 1:1 and 1:N Mean?

- **1:1 (One-to-One):** One record in Table A belongs to exactly one record in Table B. Like a person and their passport — one person has one passport, and one passport belongs to one person.
- **1:N (One-to-Many):** One record in Table A can be linked to many records in Table B. Like a teacher and their students — one teacher can have many students.

---

### Relationship 1 — `users` → `wallets` (One-to-One)

**In plain English:** Every user has exactly one wallet. When you register on PakEscrow, the system automatically creates one wallet for you. You cannot have two wallets, and every wallet belongs to exactly one person.

---

### Relationship 2 — `users` → `kyc_documents` (One-to-Many)

**In plain English:** One user can submit multiple identity documents. For example, a user might upload their CNIC front, CNIC back, and a selfie — that is three separate document records, all belonging to the same user. Over time they might re-upload documents if they expire or get rejected.

---

### Relationship 3 — `users` → `contracts` as Client (One-to-Many)

**In plain English:** One client can create many contracts. If Ayesha is a client, she could simultaneously have contracts with three different freelancers for three different projects. Each contract is a separate record, but they all point back to Ayesha's user account.

---

### Relationship 4 — `users` → `contracts` as Freelancer (One-to-Many)

**In plain English:** One freelancer can work on many contracts. If Ali is a freelancer, he might be working on five different projects for five different clients. Each of those projects is a separate contract record, but they all reference Ali's user account as the freelancer.

> Note: The `contracts` table links back to `users` **twice** — once for the client and once for the freelancer. This is why the diagram shows two separate lines from `users` to `contracts`.

---

### Relationship 5 — `contracts` → `payments` (One-to-Many)

**In plain English:** One contract can have multiple payment records. When a client deposits money to fund a contract, that creates one payment record. When the freelancer's earnings are released, that creates another. If a refund happens, that creates a third. All of these payments are linked to the same contract.

---

### Relationship 6 — `contracts` → `milestones` (One-to-Many)

**In plain English:** One contract can be divided into many milestones. A long-term software development contract might have four phases — each phase is a separate milestone record linked to that one contract. A simple short contract might have no milestones at all and be settled in one payment.

---

### Relationship 7 — `contracts` → `disputes` (One-to-Many)

**In plain English:** One contract can have multiple disputes raised against it. In practice, most contracts have zero disputes. But if a dispute is resolved and the same contract runs into another problem later, a second dispute can be opened. Each dispute is linked back to the contract it concerns.

---

### Relationship 8 — `users` → `audit_logs` (One-to-Many)

**In plain English:** One user can have many audit log entries. Every time a user performs an important action — logging in, funding a contract, approving a delivery, requesting a withdrawal — a new log entry is created. Over time, an active user might have hundreds of log entries all linked to their account.

---

### Relationship 9 — `users` → `notifications` (One-to-Many)

**In plain English:** One user receives many notifications over time. Every contract event, payment confirmation, dispute update, and KYC decision triggers a notification to the relevant user. All of those notification records are linked to the user who received them.

---

### Relationship 10 — `users` → `payments` (One-to-Many)

**In plain English:** One user is associated with many payment records — both deposits and withdrawals. Every time a user sends or receives money through the platform, a payment record is created and linked to their account.

---

## A Complete Real-World Example

To bring everything together, here is how all 9 tables work in a single real scenario:

---

**The Scenario:** Usman (a client) hires Fatima (a freelancer) to build a website for PKR 80,000, split into 3 milestones.

**Step 1 — Registration**
Both Usman and Fatima register. Two rows are created in the `users` table — one for each. Two rows are also automatically created in the `wallets` table — one wallet per user.

**Step 2 — KYC Verification**
Fatima uploads her CNIC front and back. Two rows are created in `kyc_documents`, both linked to Fatima's user ID. An admin reviews them, updates the `status` to `APPROVED`, and Fatima's `kyc_tier` in the `users` table is updated to `2`.

**Step 3 — Contract Creation**
Usman creates a contract. One row is created in the `contracts` table with `client_id` pointing to Usman and `freelancer_id` pointing to Fatima. The `status` is `DRAFT`.

**Step 4 — Milestones Added**
Three rows are created in the `milestones` table — Design (PKR 15,000), Development (PKR 45,000), Testing & Launch (PKR 20,000) — all linked to the same `contract_id`.

**Step 5 — Fatima Accepts**
Fatima reviews and accepts the contract. The contract `status` changes to `FUNDED` once Usman pays. One row is created in the `payments` table showing the PKR 80,000 deposit by Usman via JazzCash. Usman's wallet `locked_balance` increases by PKR 80,000. An `audit_log` entry is created for this action.

**Step 6 — Work Begins**
The contract `status` moves to `IN_PROGRESS`. Fatima begins work. A `notifications` row is created and sent to Fatima via SMS: *"Contract PKE-2024-00847 is now active. Funds of PKR 80,000 are secured in escrow."*

**Step 7 — Milestone 1 Delivered and Approved**
Fatima submits Milestone 1. Usman reviews and approves it. Milestone 1's `status` changes to `APPROVED`. PKR 15,000 is released to Fatima's wallet. A `payments` row is created for this release. An `audit_log` entry records Usman's approval. Fatima receives an `EMAIL` notification: *"PKR 15,000 has been released to your wallet."*

**Step 8 — Dispute on Milestone 2**
Usman is not happy with the frontend work. He opens a dispute. One row is created in the `disputes` table, linked to the contract and with `raised_by` pointing to Usman. The contract `status` moves to `DISPUTED`. A moderator is assigned (`assigned_to` is updated). Both parties submit evidence. The moderator reviews and decides a partial split — Fatima receives PKR 30,000 of the PKR 45,000 milestone, and Usman receives PKR 15,000 back. The `resolution_type` and `resolution_note` fields are filled in. Two `payments` rows are created for this split.

**Step 9 — Milestone 3 Completed**
The contract resumes. Fatima completes and delivers Milestone 3. Usman approves. PKR 20,000 is released. The contract `status` moves to `COMPLETED`. `completed_at` is recorded. Final `audit_log` entries are written. Both users receive a `notifications` record confirming completion.

---

At the end of this scenario, the database holds:

- **2 rows** in `users` (Usman + Fatima)
- **2 rows** in `wallets` (one each)
- **2 rows** in `kyc_documents` (Fatima's CNIC front and back)
- **1 row** in `contracts`
- **3 rows** in `milestones`
- **Multiple rows** in `payments` (deposit, three milestone releases, one partial refund)
- **1 row** in `disputes`
- **Many rows** in `audit_logs` (one for every state change)
- **Many rows** in `notifications` (one for every event alert)

---

## Glossary of Terms

| Term | Plain-English Meaning |
|---|---|
| **Table** | A structured container in the database that holds a specific type of information — similar to a spreadsheet tab or a filing cabinet drawer. |
| **Row** | A single entry inside a table — like one line in a spreadsheet. For example, one user, one contract, or one payment. |
| **Column** | A specific piece of information stored about every row — like a field in a form. For example, every user row has a column for `email` and a column for `phone`. |
| **Primary Key (PK)** | A column that gives every row its own unique identity number. No two rows in a table can have the same PK. It is like a national ID card — unique per person. |
| **Foreign Key (FK)** | A column that points to the PK of another table. It is how tables are linked together. For example, the `contract_id` column in the `payments` table is a Foreign Key pointing to the `id` column in the `contracts` table. |
| **Unique Constraint (UQ)** | A rule that prevents two rows from having the same value in a specific column. For example, no two contracts can have the same `reference_number`. |
| **UUID** | A universally unique identifier — a long, random-looking string of letters and numbers (e.g. `a3f7c2d1-...`) used as an ID. Essentially impossible to guess or duplicate. |
| **ENUM** | A column that can only contain one of a fixed set of allowed values. For example, a contract `status` can only ever be one of: `DRAFT`, `FUNDED`, `IN_PROGRESS`, etc. It cannot be any random word. |
| **BOOLEAN** | A column that can only be `TRUE` or `FALSE` (yes or no). For example, `is_active` is a BOOLEAN — either the account is active or it is not. |
| **NUMERIC(20,4)** | A way to store money values precisely, with up to 4 decimal places. This avoids the rounding errors that normal decimal storage can cause — critical for financial data. |
| **TIMESTAMPTZ** | A date-and-time value that also records the timezone. Used for all date columns so records are always accurate regardless of where the server is located. |
| **JSONB** | A flexible storage format for data that does not have a fixed structure. Like a notes field where you can store anything — used for contract terms, notification payloads, and profile data. |
| **Escrow** | A financial arrangement where a neutral third party (TrustLink) holds money on behalf of two parties until agreed conditions are met. |
| **KYC** | Know Your Customer — the process of verifying a user's real identity using official documents before allowing them to conduct financial transactions. |
| **1:1 Relationship** | One record in Table A is linked to exactly one record in Table B, and vice versa. |
| **1:N Relationship** | One record in Table A can be linked to many records in Table B. |

---

*This document was written to accompany the TrustLink Entity Relationship Diagram (`pakescrow_erd.xml`). For the technical database schema, refer to the main project README.*
