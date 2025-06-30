```prolog
case_query(Result) :-
    s3306_a_2_(span("paid", 10, 13)),
    s3306_a_2_is_wages(span("paid", 10, 13)),
    Result = true.

case_query(false).
```