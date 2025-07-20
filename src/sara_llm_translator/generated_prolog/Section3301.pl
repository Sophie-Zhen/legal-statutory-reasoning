% §3301. Rate of tax
% There is hereby imposed on every employer (as defined in section 3306(a)) for each calendar year an excise tax,
% with respect to having individuals in his employ, equal to 6 percent of the total wages (as defined in section 3306(b))
% paid by such employer during the calendar year with respect to employment (as defined in section 3306(c)).

% Event: An employer is subject to an excise tax for a calendar year.
s3301_excise_tax_imposed(Event) :-
    employer(Event, Employer),
    calendar_year(Event, Year),
    excise_tax(Event, Employer, Year).

% Event: The excise tax is calculated as 6 percent of the total wages paid by the employer during the calendar year.
s3301_excise_tax_calculation(Event) :-
    excise_tax(Event, Employer, Year),
    total_wages_paid(Event, Employer, Year, TotalWages),
    tax_rate(Event, 0.06),
    tax_amount(Event, TotalWages * 0.06).

% Event: The employer has individuals in his employ during the calendar year.
s3301_employment(Event) :-
    employer(Event, Employer),
    employs_individuals(Event, Employer, Year),
    calendar_year(Event, Year).

% Event: The wages are defined as per section 3306(b).
s3301_wages_definition(Event) :-
    wages_defined(Event, section_3306b).

% Event: The employment is defined as per section 3306(c).
s3301_employment_definition(Event) :-
    employment_defined(Event, section_3306c).