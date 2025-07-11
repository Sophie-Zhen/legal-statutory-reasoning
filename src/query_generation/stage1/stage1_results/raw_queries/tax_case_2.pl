case_query(Result) :-
    bagof(Year,bob_household_maintenance(Year,_,_,_),Years),
    sum_list(Years,Sum),
    Result is Sum / length(Years).