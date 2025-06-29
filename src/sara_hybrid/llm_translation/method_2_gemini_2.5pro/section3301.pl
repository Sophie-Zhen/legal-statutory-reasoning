:- module(section3301,
          [
            s3301_calculate_futa_tax/4 % s3301_calculate_futa_tax(CaseID, EmployerID, CalendarYear, FutaTaxAmount)
          ]).
:- use_module(section3306, [
                            s3306_a_is_employer/4, % s3306_a_is_employer(CaseID, PersonID, CalendarYear, IsEmployerBool)
                            s3306_b_total_futa_wages_for_employer/4 % s3306_b_total_futa_wages_for_employer(CaseID, EmployerID, CalendarYear, TotalFUTAWages)
                           ]).
:- use_module(helpers, [round_to_nearest_dollar/2]).
:- use_module(tests, [fact/2]).
% s3301_calculate_futa_tax(CaseID, EmployerID, CalendarYear, FutaTaxAmount)
% Imposes an excise tax of 6% on total FUTA wages paid by an employer.
s3301_calculate_futa_tax(CaseID, EmployerID, CalendarYear, FutaTaxAmountRounded) :-
    s3306_a_is_employer(CaseID, EmployerID, CalendarYear, true), % Must be an employer
    s3306_b_total_futa_wages_for_employer(CaseID, EmployerID, CalendarYear, TotalFUTAWages),
    FutaTaxRate = 0.06,
    RawFutaTaxAmount is TotalFUTAWages * FutaTaxRate,
    round_to_nearest_dollar(RawFutaTaxAmount, FutaTaxAmountRounded),
    !.
s3301_calculate_futa_tax(_CaseID, _EmployerID, _CalendarYear, 0). % Not an employer or no FUTA wages, tax is 0.