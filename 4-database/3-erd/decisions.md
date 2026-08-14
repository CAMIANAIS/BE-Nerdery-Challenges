# Schema Design Decisions
1. Users → Roles: One-to-Many (one user, one role)
Decision: Keep simple. A user has one role. No M:N junction table needed. The business doesn't require a user to be admin and delivery_person at the same time. One role per user. Done.
2. Users → Orders: One-to-Many (one client has many orders)
Decision: Straightforward. One user places many orders. FK on Orders.user_id. Simple and correct.
3. Cart_Items vs Order_Items (separate tables)
Decision: Keep separate. Cart items are temporary, they sit in the cart until checkout, then disappear. Order items are the permanent historical record, we need to know what was actually ordered, with the price at that moment. They serve different purposes, so separate tables make sense.
4. Price_History 
Decision: Track historical prices. We need to know what price a product was at on a specific date. If a price changes, we insert a new price_history row, we never edit the old one. This way we can look back and say "this variant cost €50 on that date," which matters for auditing and understanding past orders.
5. Enums everywhere: Size, Color, Roles, Status, Payment methods
Decision: Be consistent with constraints. We locked down size and color because the business is simple ,shirts, fixed sizes and colors. But then I realized: order status is just as fixed (pending, paid, processing, shipped, cancelled). Role types are fixed (admin, manager, client, delivery_person). Payment methods are fixed (card, bank_account, apple_pay, google_pay). So use CHECK constraints everywhere the same way. Same logic, same enforcement level. Consistency matters.
6. Password_hash and reset_token_hash (authentication)
Decision: Standard security. password_hash is for login. reset_token_hash is for password resets, user gets the raw token in email, we hash it and compare it against what's stored. Both hashed before going into the database. No plaintext passwords or tokens ever.

7. CHECK constraints on amounts and quantities
Decision: Let the database enforce. Quantity > 0 because zero in a cart makes no sense. Payment amount > 0 because money has to move. Price >= 0 because free items happen. This catches mistakes early and prevents bad data from ever getting in.

8. What I am going to work next week changed_by_type without a constraint linking it to the fields is performative. Nothing stops contradictory data. Also a real gap. In the real world, shipped ≠ delivered. A package ships and then arrives. The flow should be:
pending → paid → processing → shipped → delivered → (can cancel at any point)
Decision: Add 'delivered'. Updated CHECK above.And finally this one I need to decide: Do we add an Address table. Two last are for the optional part.