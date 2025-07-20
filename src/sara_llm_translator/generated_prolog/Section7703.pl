% §7703. Determination of marital status

% (a) General rule

% (1) the determination of whether an individual is married shall be made as of the close of his taxable year; 
% except that if his spouse dies during his taxable year such determination shall be made as of the time of such death;
s7703_a_1(Event, Individual) :-
    taxable_year_close(Event, Individual, Date),
    \+ (spouse_death(Event, Individual, DeathDate), Date \= DeathDate).

% (2) an individual legally separated from his spouse under a decree of divorce or of separate maintenance shall not be considered as married.
s7703_a_2(Event, Individual) :-
    legal_separation(Event, Individual),
    \+ considered_married(Event, Individual).

% (b) Certain married individuals living apart

% For purposes of those provisions of this title which refer to this subsection, if-

% (1) an individual who is married (within the meaning of subsection (a)) and who files a separate return maintains as his home a household 
% which constitutes for more than one-half of the taxable year the principal place of abode of a child with respect to whom such individual 
% is entitled to a deduction for the taxable year under section 151,
s7703_b_1(Event, Individual) :-
    s7703_a_1(Event, Individual),
    files_separate_return(Event, Individual),
    maintains_household(Event, Individual, Household),
    principal_abode_of_child(Event, Household, Child),
    entitled_to_deduction(Event, Individual, Child),
    more_than_half_year(Event, Household).

% (2) such individual furnishes over one-half of the cost of maintaining such household during the taxable year,
s7703_b_2(Event, Individual) :-
    furnishes_over_half_cost(Event, Individual, Household).

% (3) during the last 6 months of the taxable year, such individual's spouse is not a member of such household,
s7703_b_3(Event, Individual) :-
    last_six_months(Event, Date),
    \+ member_of_household(Event, Individual, Spouse, Date).

% such individual shall not be considered as married.
s7703_b(Event, Individual) :-
    s7703_b_1(Event, Individual),
    s7703_b_2(Event, Individual),
    s7703_b_3(Event, Individual),
    \+ considered_married(Event, Individual).