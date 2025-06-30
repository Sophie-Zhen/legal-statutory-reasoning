```prolog
case_query(true) :- s3306_c_1(span("work",32,35),"Alice","Bob").
case_query(false) :- \+ s3306_c_1(span("work",32,35),"Alice","Bob").
```