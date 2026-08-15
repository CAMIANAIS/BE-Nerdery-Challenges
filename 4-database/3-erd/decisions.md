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

8. Order status flow now includes 'delivered'
Decision: Add delivered state. The full flow is pending → paid → processing → shipped → delivered, then cancelled is possible at any point. Shipped and delivered are different, shipped means it left the warehouse, delivered means it arrived. Both matter

9. Adress Decision: Let users save multiple addresses. A user can have as many shipping addresses and billing addresses as they want. But only one can be marked as default. I use a partial unique index, it only checks the rows marked default, and makes sure there's only one default per address type. Non-default addresses don't get checked, so users can have as many as you need.

10.  Added a CHECK constraint that enforces: if changed_by_type = 'user', changed_by_email must always be recorded. The changed_by_user_id can go null if the user is deleted — that's fine. If changed_by_type = 'system', both fields stay null. The email is the durable identifier that keeps the audit trail meaningful. The user_id is just a convenience link. This way you can delete a user without breaking the historical record.