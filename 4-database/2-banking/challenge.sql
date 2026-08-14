/*
    Challenge: Implement a Secure Fund Transfer Function

    In this challenge, you will implement a PostgreSQL stored function to simulate transferring funds 
    between two accounts in a banking system. The function must follow proper validation, ensure data 
    integrity, and log transactions with a shared reference.

    Your function should be named:
    banking.transfer_funds(from_id INT, to_id INT, amount NUMERIC)

    The function must:

    - Prevent transfers to the same account
    - Ensure the transfer amount is greater than zero
    - Validate that both sender and recipient accounts exist
    - Prevent transfers if either account is marked as "frozen"
    - Ensure the sender has sufficient funds
    - Debit the sender and credit the recipient atomically
    - Log two transactions: a withdrawal and a deposit, both linked by the same UUID reference
    - Raise meaningful exceptions for all validation failures

    The function should perform all operations within a safe transactional context, maintaining 
    database consistency even in the event of failure.

    Notes:
    - In order to test you can mock some additional data in the tables that participates in this challenge.
    - Make sure of raising errors when they're present

    ERD:
    +---------------------+            +--------------------------+
    |     accounts        |            |      transactions        |
    +---------------------+            +--------------------------+
    | account_id (PK)     |<-----------| transaction_id (PK)      |
    | balance             |            | account_id (FK)          |
    | status              |            | amount                   |
    +---------------------+            | transaction_type         |
                                       | reference                |
                                       | transaction_date         |
                                       +--------------------------+
*/


-- your solution here

--======================================================
-- Author: Camila Mamani
-- Date: 13 August 2026
-- Description: Function for transfering in a secure way
--======================================================
CREATE FUNCTION banking.transfer_funds(from_id INT, to_id INT, amount NUMERIC) 
RETURNS UUID AS $$ 
DECLARE
 sender_balance NUMERIC; 
 sender_status TEXT;
 recipient_status TEXT;
 transaction_ref UUID;
BEGIN
IF from_id=to_id
THEN RAISE EXCEPTION 'same account';
END IF;
IF amount <= 0
THEN RAISE EXCEPTION 'transfer amount is zero';
END IF;

SELECT 
balance,
status
INTO 
sender_balance,
sender_status
FROM banking.accounts
WHERE account_id=from_id;


SELECT
status
INTO 
recipient_status
FROM banking.accounts
WHERE account_id=to_id;



IF
sender_status IS NULL OR
recipient_status IS NULL
THEN RAISE EXCEPTION
'account do not exist'
;
END IF
;

IF
sender_status='frozen' OR
recipient_status='frozen'
THEN RAISE EXCEPTION
'account is frozen'
;
END IF
;

IF
sender_balance<amount
THEN RAISE EXCEPTION
'sender has insufficient funds'
;
END IF
;

transaction_ref := gen_random_uuid();

UPDATE banking.accounts
SET balance =balance - amount
WHERE account_id = from_id;

UPDATE banking.accounts
SET balance=balance +amount
WHERE account_id = to_id;

INSERT INTO banking.transactions (account_id, amount, transaction_type, reference, transaction_date)
VALUES(to_id,amount,'deposit',transaction_ref,NOW());

INSERT INTO banking.transactions (account_id, amount, transaction_type, reference, transaction_date)
VALUES(from_id,amount,'withdrawal',transaction_ref,NOW());

RETURN transaction_ref;

END;
$$ LANGUAGE plpgsql;