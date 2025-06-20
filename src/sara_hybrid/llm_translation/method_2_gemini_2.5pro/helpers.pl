:- module(helpers,
          [
            age_at_year_end/4, % age_at_year_end(CaseID, PersonID, TaxYear, Age)
            is_older_or_equal_age/4, % is_older_or_equal_age(CaseID, Person1ID, Person2ID, TaxYear)
            is_younger_than/4, % is_younger_than(CaseID, Person1ID, Person2ID, TaxYear)
            tcja_active/1,     % tcja_active(TaxYear)
            round_to_dollars/2 % round_to_dollars(Amount, RoundedAmount)
          ]).

:- use_module(library(lists)). % For potential list operations if needed

% Facts that would be in tests.pl, but helpers might need to know their structure
:- dynamic fact/3. % fact(CaseID, PredicateAtom, ValueListOrAtom) - generic or specific like below
:- dynamic person_dob/4. % person_dob(CaseID, PersonID, year(Y), month(M), day(D)). Assume this structure from tests.pl

age_at_year_end(CaseID, PersonID, TaxYear, Age) :-
    fact(CaseID, person_dob(PersonID, date(BirthY, _BirthM, _BirthD))),
    % Simplified age calculation: current year - birth year.
    % A more precise calculation would consider month and day.
    % For tax purposes, age is often determined as of Dec 31.
    Age is TaxYear - BirthY.

% True if Person1 is older than or the same age as Person2 at the end of TaxYear
is_older_or_equal_age(CaseID, Person1ID, Person2ID, TaxYear) :-
    age_at_year_end(CaseID, Person1ID, TaxYear, Age1),
    age_at_year_end(CaseID, Person2ID, TaxYear, Age2),
    Age1 >= Age2.

% True if Person1 is younger than Person2
is_younger_than(CaseID, Person1ID, Person2ID, TaxYear) :-
    age_at_year_end(CaseID, Person1ID, TaxYear, Age1),
    age_at_year_end(CaseID, Person2ID, TaxYear, Age2),
    Age1 < Age2.

% True if the Tax Cuts and Jobs Act (TCJA) specific rules are active for the TaxYear
tcja_active(TaxYear) :-
    TaxYear >= 2018,
    TaxYear =< 2025.

round_to_dollars(Amount, RoundedAmount) :-
    RoundedAmount is round(Amount).

% Example for more precise age calculation if needed (not strictly required by current cases)
% age_at_date(date(BirthY, BirthM, BirthD), date(CurrentY, CurrentM, CurrentD), Age) :-
%     Age0 is CurrentY - BirthY,
%     ( (CurrentM < BirthM) -> Age is Age0 - 1
%     ; (CurrentM =:= BirthM, CurrentD < BirthD) -> Age is Age0 - 1
%     ; Age is Age0
%     ).
% age_at_end_of_tax_year(CaseID, PersonID, TaxYear, Age) :-
%     fact(CaseID, person_dob(PersonID, DOB)),
%     age_at_date(DOB, date(TaxYear, 12, 31), Age).