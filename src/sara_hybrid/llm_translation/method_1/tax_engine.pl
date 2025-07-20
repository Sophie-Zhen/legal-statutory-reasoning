% ----- tax_engine.pl -----
:- module(tax_engine,
          [ tax_due/4,                     % Person × Year × FilingStatus × Tax
            decide_tax/4                  % Person × Year × ClaimedTax × Verdict
          ]).

:- use_module(section7703).
:- use_module(section2).
:- use_module(section1).
:- use_module(people_data).

%% 1. Determine filing status
status(Person, Year, married_filing_jointly) :-
    section7703:married_under_section_7703(Person,Year),
    section7703:files_joint_return(Person,Year).
status(Person, Year, surviving_spouse) :-
    section2:surviving_spouse(Person,Year).

%% 2. Compute actual tax
tax_due(Person, Year, FilingStatus, Tax) :-
    status(Person, Year, FilingStatus),
    people_data:taxable_income(Person, Year, Income),
    section1:bracket(FilingStatus, Year, Low, High, Base, Rate),
    Income > Low, Income =< High,
    TaxF is Base + (Income - Low) * Rate,
    Tax is round(TaxF).

%% 3. Decide entailment vs. contradiction
decide_tax(Person, Year, Claimed, entailment) :-
    tax_due(Person, Year, _, Computed),
    Computed =:= Claimed.
decide_tax(Person, Year, Claimed, contradiction) :-
    \+ decide_tax(Person, Year, Claimed, entailment).