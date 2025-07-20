% File: section2.pl
:- module(section2,[surviving_spouse/2, head_of_household/2, married/2, unmarried/2]).

%% Facts you must assert in your case-facts file:
%%   spouse(Person,Spouse,DateMarried).
%%   death(Person,Date).
%%   remarried(Person,Date).
%%   lives_together(Person,Dependent,From,To).
%%   maintains(Person,HomeCostSharePercent).
%%   dependent(Person, Dependent).
%%   nonresident_alien(Person).

:- use_module(library(date)).

% Helper: date_diff_in_years(Date1, Date2, Years).
date_diff_in_years(Y1-M1-D1, Y2-_M2-_D2, Diff) :-
    Diff is Y2 - Y1.

%% married(Person, Year) holds at close of taxable Year
married(Person, Year) :-
    spouse(Person,_,Date),
    date_diff_in_years(Date, Year-12-31, 0),
    \+ ( death(Person, D), date_diff_in_years(Date, D, 0) ).

%% unmarried(Person, Year)
unmarried(Person, Year) :-
    \+ married(Person, Year).

%% surviving_spouse(Person, Year)
surviving_spouse(Person, Year) :-
    spouse(Person, Sp, DateM),
    death(Sp, DateD),
    date_diff_in_years(DateD, Year-1-12-31, Diff), Diff =< 2,
    \+ ( remarried(Person, _)),
    dependent(Person, Dep),
    lives_together(Person, Dep, _From, _To),
    maintains(Person, Share), Share > 50.

%% head_of_household(Person, Year)
head_of_household(Person, Year) :-
    \+ married(Person, Year),
    \+ surviving_spouse(Person, Year),
    dependent(Person, Dep),
    lives_together(Person, Dep, _F,_T),
    maintains(Person, Share), Share > 50,
    \+ nonresident_alien(Person).