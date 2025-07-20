% §68. Overall limitation on itemized deductions

% (a) General rule
% In the case of an individual whose adjusted gross income exceeds the applicable amount, 
% the amount of the itemized deductions otherwise allowable for the taxable year shall be 
% reduced by the lesser of 3 percent of the excess of adjusted gross income over the applicable 
% amount, or 80 percent of the amount of the itemized deductions otherwise allowable for such 
% taxable year.
s68_a(Event) :-
    agent_(Event, Individual),
    adjusted_gross_income_(Event, AGI),
    applicable_amount_(Event, ApplicableAmount),
    itemized_deductions_(Event, ItemizedDeductions),
    Excess is AGI - ApplicableAmount,
    Reduction1 is 0.03 * Excess,
    Reduction2 is 0.80 * ItemizedDeductions,
    Reduction is min(Reduction1, Reduction2),
    reduce_itemized_deductions_(Event, Reduction).

% (b) Applicable amount
% (1) In general
% For purposes of this section, the term "applicable amount" means-
% (A) $300,000 in the case of a joint return or a surviving spouse (as defined in section 2(a)),
s68_b_1_a(Event, 300000) :-
    (filed_joint_return(Event) ; surviving_spouse(Event)).

% (B) $275,000 in the case of a head of household (as defined in section 2(b)),
s68_b_1_b(Event, 275000) :-
    head_of_household(Event).

% (C) $250,000 in the case of an individual who is not married and who is not a surviving spouse or head of household,
s68_b_1_c(Event, 250000) :-
    \+ married(Event),
    \+ surviving_spouse(Event),
    \+ head_of_household(Event).

% (D) 1/2 the amount applicable under subparagraph (A) in the case of a married individual filing a separate return.
s68_b_1_d(Event, ApplicableAmount) :-
    married(Event),
    filed_separate_return(Event),
    s68_b_1_a(_, AmountA),
    ApplicableAmount is AmountA / 2.

% For purposes of this paragraph, marital status shall be determined under section 7703.
% (This is a note for reference and does not require a separate rule)

% (f) Section not to apply
% This section shall not apply to any taxable year beginning after December 31, 2017, and before January 1, 2026.
s68_f(Event) :-
    start_(Event, Date),
    (Date @=< date(2017, 12, 31) ; Date @>= date(2026, 1, 1)).