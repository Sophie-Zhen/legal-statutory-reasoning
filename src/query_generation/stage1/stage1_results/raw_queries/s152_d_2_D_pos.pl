% PROMPT USED: prompt_income_tax.txt

```prolog
case_query(Result) :- (taxable_income(alice, 2022, 100000) -> Result = true ; Result = false).
```

% --- SWI-PROLOG STDERR ---
% SWI-Prolog TIMEOUT