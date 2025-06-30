```prolog
case_query(true) :- s3306_b(_, _, _, "Alice", "Bob", _, _, _), s3306_b(_, _, _, "Bob", "Alice", _, _, _), \+ s3306_a_1("Alice").
```