:- module(helpers,
          [ is_tax_year_between/3,
            tcja_standard_deduction_rules_active/1,
            tcja_personal_exemption_zero_active/1,
            tcja_s68_limitation_inactive/1,
            get_age_at_year_end/4, % get_age_at_year_end(CaseID, PersonID, TaxYear, Age)
            is_person_younger_than_person_at_year_end/5, % is_person_younger_than_person_at_year_end(CaseID, Person1ID, Person2ID, TaxYear, IsYoungerBool)
            round_to_dollars/2,
            ceil_dollars/2
          ]).

:- dynamic fact/2. % fact(CaseID, FactAtom)

is_tax_year_between(TaxYear, StartYear, EndYear) :-
    TaxYear >= StartYear,
    TaxYear =< EndYear.

tcja_standard_deduction_rules_active(TaxYear) :- % For Sec 63(c)(7)
    is_tax_year_between(TaxYear, 2018, 2025).

tcja_personal_exemption_zero_active(TaxYear) :- % For Sec 151(d)(5)
    is_tax_year_between(TaxYear, 2018, 2025).

tcja_s68_limitation_inactive(TaxYear) :- % For Sec 68(f)
    is_tax_year_between(TaxYear, 2018, 2025).

get_age_at_year_end(CaseID, PersonID, TaxYear, Age) :-
    fact(CaseID, person_dob(PersonID, date(BirthY, _BirthM, _BirthD))),
    % Simplified age: assumes age increments on Jan 1 for tax end-of-year purposes
    Age is TaxYear - BirthY.

is_person_younger_than_person_at_year_end(CaseID, Person1ID, Person2ID, TaxYear, true) :-
    get_age_at_year_end(CaseID, Person1ID, TaxYear, Age1),
    get_age_at_year_end(CaseID, Person2ID, TaxYear, Age2),
    Age1 < Age2.
is_person_younger_than_person_at_year_end(CaseID, Person1ID, Person2ID, TaxYear, false) :-
    get_age_at_year_end(CaseID, Person1ID, TaxYear, Age1),
    get_age_at_year_end(CaseID, Person2ID, TaxYear, Age2),
    Age1 >= Age2.

round_to_dollars(Amount, RoundedAmount) :-
    RoundedAmount is round(Amount).

ceil_dollars(Amount, CeiledAmount) :-
    CeiledAmount is ceiling(Amount).