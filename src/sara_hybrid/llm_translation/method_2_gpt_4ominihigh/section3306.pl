% File: section3306.pl
:- module(section3306,[employer/2, wages_excluded/3]).

%% employer(Name, Year) based on per-case facts: paid_wages(Name,Year,Amount), days_employed(Name,Year,Days).
employer(Name, Year) :-
    ( paid_wages(Name,Year,W), W >= 1500
    ; days_employed(Name,Year,D), D >= 10 ).

%% wages_excluded(Name,Year,Excluded)
% per-case facts for retirement, insurance, etc.
wages_excluded(_,_,0).  % assume we only handle §3306(b)(2)(C) via case-facts