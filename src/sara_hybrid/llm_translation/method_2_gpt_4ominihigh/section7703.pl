% File: section7703.pl
:- module(section7703,[marital_status/3]).

%% marital_status(Person, Date, Status)
% Status = married | unmarried
marital_status(Person, Date, married) :-
    section2:married(Person, Date).
marital_status(Person, Date, unmarried) :-
    section2:unmarried(Person, Date).