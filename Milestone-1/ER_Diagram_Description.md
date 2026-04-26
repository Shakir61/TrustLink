# ER Diagram Description
## Freelance Platform Database — Milestone 1

---

## 1. Overview

This Entity-Relationship (ER) Diagram represents the relational database structure
for a freelance services platform — similar to Fiverr. The diagram models how users
interact with gigs, how orders are placed and tracked, how payments are held securely
in escrow, and how clients leave reviews after a completed transaction. The database
consists of five core entities: User, Gigs, Orders, Escrow_Transaction, and Reviews.

---

## 2. Entities and Their Attributes

### 2.1 User
The User entity is the central actor of the entire system. It represents every
person registered on the platform, whether they are hiring (Client) or offering
services (Freelancer). Both roles are stored in the same table, distinguished by
the Role attribute.

| Attribute         | Key  | Description                                      |
|-------------------|------|--------------------------------------------------|
| UserID            | PK   | Unique identifier for every user                 |
| Username          |      | Display name chosen by the user                  |
| Email             |      | Unique email address used for login              |
| Password_Hash     |      | Encrypted version of the user's password         |
| Role              |      | Defines the user as either Client or Freelancer  |
| Wallet_Balance    |      | Current available funds in the user's account    |

---

### 2.2 Gigs
The Gigs entity represents a service listing posted by a Freelancer. Each gig
describes what the freelancer is offering, at what price, and under which category.
A single freelancer can post multiple gigs.

| Attribute     | Key  | Description                                          |
|---------------|------|------------------------------------------------------|
| GigID         | PK   | Unique identifier for every gig                      |
| SellerID      | FK   | References UserID — the Freelancer who owns this gig |
| Title         |      | Short name or heading of the service                 |
| Description   |      | Detailed explanation of what the service includes    |
| Base_Price    |      | Starting price a client pays for this gig            |
| Category      |      | Type of service (e.g. Design, Writing, Development)  |

---

### 2.3 Orders
The Orders entity is the "state machine" of the platform. It tracks the full
lifecycle of a deal from the moment a client places an order to the moment it
is completed. Every order links a buyer (Client) to a specific gig (and thus
to the Freelancer behind that gig).

| Attribute     | Key  | Description                                               |
|---------------|------|-----------------------------------------------------------|
| OrderID       | PK   | Unique identifier for every order                         |
| BuyerID       | FK   | References UserID — the Client who placed the order       |
| GigID         | FK   | References GigID — the Gig being purchased                |
| Status        |      | Current stage: Pending → Active → Delivered → Completed   |
| Total_Amount  |      | Final price charged for this specific order               |

---

### 2.4 Escrow_Transaction
The Escrow_Transaction entity acts as a simulated financial vault or ledger.
It records every movement of money associated with an order. When an order
becomes Active, funds are "Locked" here — deducted from the client's wallet
but not yet given to the freelancer. Funds are only "Released" to the
freelancer once the order is Completed, or "Refunded" to the client if
something goes wrong.

| Attribute   | Key  | Description                                                |
|-------------|------|------------------------------------------------------------|
| Trans_ID    | PK   | Unique identifier for every escrow transaction             |
| OrderID     | FK   | References OrderID — the order this transaction belongs to |
| Amount      |      | The monetary value being moved                             |
| Type        |      | Nature of the transaction: Lock, Release, or Refund        |
| Timestamp   |      | Date and time when the transaction was recorded            |

---

### 2.5 Reviews
The Reviews entity stores feedback left by a Client after an order is
successfully completed. A review can only exist if its linked order has
reached the "Completed" status — this rule is enforced at the database
level via a trigger. Each completed order can have at most one review.

| Attribute  | Key  | Description                                               |
|------------|------|-----------------------------------------------------------|
| ReviewID   | PK   | Unique identifier for every review                        |
| OrderID    | FK   | References OrderID — the completed order being reviewed   |
| Rating     |      | Numeric score given by the client (1 to 5)                |
| Comment    |      | Written feedback describing the client's experience       |

---

## 3. Relationships

### 3.1 User — Gigs   (One to Many)
One User (acting as a Freelancer) can post many Gigs, but each Gig belongs
to exactly one Freelancer. This relationship is established through the
SellerID foreign key in the Gigs table, which references the UserID in the
User table.

> A Freelancer can offer multiple services, but every service listing is
> owned by one and only one Freelancer.

---

### 3.2 User — Orders   (One to Many)
One User (acting as a Client) can place many Orders, but each Order is
placed by exactly one Client. This relationship is established through the
BuyerID foreign key in the Orders table, which references the UserID in the
User table.

> A Client can purchase multiple gigs over time, but every individual order
> is tied back to one specific buyer.

---

### 3.3 Gigs — Orders   (One to Many)
One Gig can be associated with many Orders (many clients can purchase the
same gig), but each Order is for exactly one Gig. This is established
through the GigID foreign key in the Orders table.

> The same service can be sold to multiple clients, but each transaction
> (order) is always for a single specific gig.

---

### 3.4 Orders — Escrow_Transaction   (One to Many)
One Order can generate many Escrow Transactions (for example: one Lock
transaction when payment is made, then one Release or Refund transaction
later). Each Escrow Transaction belongs to exactly one Order. This is
established through the OrderID foreign key in the Escrow_Transaction table.

> Every financial movement (locking, releasing, or refunding money) is
> always traceable back to a single order, forming a complete audit trail.

---

### 3.5 Orders — Reviews   (One to One)
One Order can have at most one Review, and each Review belongs to exactly
one Order. This is enforced by a UNIQUE constraint on the OrderID column
in the Reviews table. Additionally, a review can only be written once the
order's Status is "Completed."

> A client may only leave one review per transaction, and only after the
> work has been fully delivered and accepted.

---

## 4. How OrderID Connects the Entire System

The OrderID is the most important key in this database. It acts as the
central link that ties every major entity together:

- It connects the **Buyer** (from the User table via BuyerID)
- It connects the **Gig** being purchased (from the Gigs table via GigID)
- It connects the **Seller** indirectly through the Gig's SellerID
- It connects the **Escrow_Transaction** table, recording all money movements
- It connects the **Reviews** table, recording post-completion feedback

This means that from a single OrderID, you can trace the full story of
a transaction: who bought it, from whom, for what service, how much money
was held and released, and what rating the client gave at the end.

---

## 5. Summary Table

| Relationship                        | Type         | Foreign Key                        |
|-------------------------------------|--------------|------------------------------------|
| User → Gigs (posts)                 | One to Many  | Gigs.SellerID → User.UserID        |
| User → Orders (places)              | One to Many  | Orders.BuyerID → User.UserID       |
| Gigs → Orders (ordered via)         | One to Many  | Orders.GigID → Gigs.GigID          |
| Orders → Escrow_Transaction (holds) | One to Many  | Escrow.OrderID → Orders.OrderID    |
| Orders → Reviews (receives)         | One to One   | Reviews.OrderID → Orders.OrderID   |

---
*Prepared for Database Lab — Milestone 1 Submission*

