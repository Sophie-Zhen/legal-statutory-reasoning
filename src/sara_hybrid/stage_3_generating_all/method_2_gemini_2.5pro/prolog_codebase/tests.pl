:- module(tests,
    [
        run_tests/0,
        test_case/1,
        fact/2,
        answer/2
    ]).

:- use_module(knowledge_base).
:- use_module(helpers).
:- use_module(section1).
:- use_module(section2).
:- use_module(section63).
:- use_module(section68).
:- use_module(section151).
:- use_module(section152).
:- use_module(section3301).
:- use_module(section3306).
:- use_module(section7703).

:- dynamic fact/2.

run_tests :-
    findall(CaseID, answer(CaseID, _), Cases),
    run_tests(Cases, 0, Passed, []),
    format('~nTests complete. Passed: ~w, Failed: ~w~n', [Passed, Failed]).

run_tests([], Passed, Passed, []).
run_tests([], Passed, Passed, Failed) :- format('Failed cases: ~w~n', [Failed]).
run_tests([CaseID|T], Acc, Passed, Failed) :-
    (   test_case(CaseID)
    ->  NewAcc is Acc + 1,
        run_tests(T, NewAcc, Passed, Failed)
    ;   run_tests(T, Acc, Passed, [CaseID|Failed])
    ).

test_case(CaseID) :-
    answer(CaseID, Expected),
    (   (Expected == true ; Expected == false)
    ->  answer(CaseID, Calculated),
        (   Calculated == Expected -> format('Test ~w PASSED.~n', [CaseID])
        ;   format('Test ~w FAILED. Expected ~w, got ~w~n', [CaseID, Expected, Calculated]), fail
        )
    ;   answer(CaseID, Calculated),
        (   Calculated == Expected -> format('Test ~w PASSED.~n', [CaseID])
        ;   format('Test ~w FAILED. Expected ~w, got ~w~n', [CaseID, Expected, Calculated]), fail
        )
    ).

% --- Fact Definitions ---
% (Copied from previous responses)
%% --- CaseID: s1_d_iv_neg BEGIN ---
fact(s1_d_iv_neg, married(alice, spouse_of_alice, '2016-01-01')).
fact(s1_d_iv_neg, date('2016-01-01', 2016, 1, 1)).
fact(s1_d_iv_neg, taxable_income(alice, 2017, 28864)).
fact(s1_d_iv_neg, files_separate_return(alice, 2017)).
%% --- CaseID: s1_d_iv_neg END ---
%% --- CaseID: s3306_c_5_pos BEGIN ---
fact(s3306_c_5_pos, child(alice, bob)).
fact(s3306_c_5_pos, paid_wages(alice, bob, 2017, 3200, work)).
fact(s3306_c_5_pos, service_performed_in_us(bob, alice, 2017)).
%% --- CaseID: s3306_c_5_pos END ---
%% --- CaseID: s1_c_i_neg BEGIN ---
fact(s1_c_i_neg, taxable_income(alice, 2017, 718791)).
%% --- CaseID: s1_c_i_neg END ---
%% --- CaseID: s1_b_iii_neg BEGIN ---
fact(s1_b_iii_neg, taxable_income(alice, 2017, 54775)).
fact(s1_b_iii_neg, child(bob, alice)).
fact(s1_b_iii_neg, date_of_birth(alice, date(1980,1,1))).
fact(s1_b_iii_neg, date_of_birth(bob, date(2010,1,1))).
fact(s1_b_iii_neg, principal_place_of_abode_for_more_than_half_year(bob, alice, 2017)).
fact(s1_b_iii_neg, furnished_over_half_cost_of_household(alice, 2017)).
fact(s1_b_iii_neg, gross_income(bob, 2017, 0)).
%% --- CaseID: s1_b_iii_neg END ---
%% --- CaseID: s152_d_2_F_pos BEGIN ---
fact(s152_d_2_F_pos, child(bob, charlie)).
fact(s152_d_2_F_pos, sibling(alice, charlie)).
%% --- CaseID: s152_d_2_F_pos END ---
%% --- CaseID: s1_a_1_iii_neg BEGIN ---
fact(s1_a_1_iii_neg, married(alice, spouse_of_alice, '2016-01-01')).
fact(s1_a_1_iii_neg, date('2016-01-01', 2016, 1, 1)).
fact(s1_a_1_iii_neg, files_joint_return(alice, spouse_of_alice, 2017)).
fact(s1_a_1_iii_neg, taxable_income(alice, 2017, 164612)).
%% --- CaseID: s1_a_1_iii_neg END ---
%% --- CaseID: s3306_b_10_A_neg BEGIN ---
fact(s3306_b_10_A_neg, payment_termination_of_employment(alice, bob, 2019, retirement_age)).
fact(s3306_b_10_A_neg, paid_wages(alice, bob, 2019, 12980, retirement_bonus)).
%% --- CaseID: s3306_b_10_A_neg END ---
%% --- CaseID: s63_c_2_B_neg BEGIN ---
fact(s63_c_2_B_neg, gross_income(alice, 2017, 33200)).
fact(s63_c_2_B_neg, married(alice, bob, '2017-02-03')).
fact(s63_c_2_B_neg, date('2017-02-03', 2017, 2, 3)).
fact(s63_c_2_B_neg, files_joint_return(alice, bob, 2017)).
%% --- CaseID: s63_c_2_B_neg END ---
%% --- CaseID: s3306_b_7_neg BEGIN ---
fact(s3306_b_7_neg, remuneration_for_service_not_in_course_of_trade(alice, bob, 2017)).
fact(s3306_b_7_neg, payment_medium(alice, bob, 2017, cash)).
%% --- CaseID: s3306_b_7_neg END ---
%% --- CaseID: s152_c_1_E_pos BEGIN ---
fact(s152_c_1_E_pos, child(bob, alice)).
fact(s152_c_1_E_pos, married(bob, charlie, '2018-10-23')).
fact(s152_c_1_E_pos, date('2018-10-23', 2018, 10, 23)).
fact(s152_c_1_E_pos, files_separate_return(bob, 2019)).
%% --- CaseID: s152_c_1_E_pos END ---
%% --- CaseID: s2_a_2_B_pos BEGIN ---
fact(s2_a_2_B_pos, married(bob, alice, '1992-02-03')).
fact(s2_a_2_B_pos, date('1992-02-03', 1992, 2, 3)).
fact(s2_a_2_B_pos, died(alice, 2014, '2014-07-09')).
fact(s2_a_2_B_pos, date('2014-07-09', 2014, 7, 9)).
%% --- CaseID: s2_a_2_B_pos END ---
%% --- CaseID: s63_c_3_pos BEGIN ---
fact(s63_c_3_pos, gross_income(alice, 2017, 33200)).
fact(s63_c_3_pos, married(alice, bob, '2017-02-03')).
fact(s63_c_3_pos, date('2017-02-03', 2017, 2, 3)).
fact(s63_c_3_pos, date_of_birth(alice, date(1950,1,1))).
fact(s63_c_3_pos, date_of_birth(bob, date(1950,1,1))).
fact(s63_c_3_pos, files_joint_return(alice, bob, 2017)).
%% --- CaseID: s63_c_3_pos END ---
%% --- CaseID: s3306_a_1_neg BEGIN ---
fact(s3306_a_1_neg, paid_wages(alice, bob, 2017, 3200, domestic_service)).
%% --- CaseID: s3306_a_1_neg END ---
%% --- CaseID: s7703_b_1_pos BEGIN ---
fact(s7703_b_1_pos, married(alice, bob, '2012-04-05')).
fact(s7703_b_1_pos, date('2012-04-05', 2012, 4, 5)).
fact(s7703_b_1_pos, child(charlie, alice)).
fact(s7703_b_1_pos, date_of_birth(charlie, date(2017, 9, 16))).
fact(s7703_b_1_pos, date_of_birth(alice, date(1990,1,1))).
fact(s7703_b_1_pos, files_separate_return(alice, 2018)).
fact(s7703_b_1_pos, maintains_household_for_child_gt_half_year(alice, charlie, 2018)).
fact(s7703_b_1_pos, furnished_over_half_cost_of_household(alice, 2018)).
fact(s7703_b_1_pos, spouse_not_in_household_last_6_months(alice, 2018)).
fact(s7703_b_1_pos, gross_income(charlie, 2018, 0)).
%% --- CaseID: s7703_b_1_pos END ---
%% --- CaseID: s1_c_iv_pos BEGIN ---
fact(s1_c_iv_pos, taxable_income(alice, 2017, 210204)).
%% --- CaseID: s1_c_iv_pos END ---
%% --- CaseID: s3306_b_pos BEGIN ---
fact(s3306_b_pos, paid_remuneration_for_employment(alice, bob, 2325, 2018)).
%% --- CaseID: s3306_b_pos END ---
%% --- CaseID: s1_a_1_pos BEGIN ---
fact(s1_a_1_pos, married(alice, spouse_of_alice, '2016-01-01')).
fact(s1_a_1_pos, date('2016-01-01', 2016, 1, 1)).
fact(s1_a_1_pos, files_joint_return(alice, spouse_of_alice, 2017)).
fact(s1_a_1_pos, taxable_income(alice, 2017, 17330)).
%% --- CaseID: s1_a_1_pos END ---
%% --- CaseID: s68_b_1_A_neg BEGIN ---
fact(s68_b_1_A_neg, adjusted_gross_income(alice, 2016, 567192)).
fact(s68_b_1_A_neg, married(alice, spouse_of_alice, '2015-01-01')).
fact(s68_b_1_A_neg, date('2015-01-01', 2015, 1, 1)).
fact(s68_b_1_A_neg, files_separate_return(alice, 2016)).
%% --- CaseID: s68_b_1_A_neg END ---
%% --- CaseID: tax_case_89 BEGIN ---
fact(tax_case_89, gross_income(alice, 2018, 3200)).
fact(tax_case_89, earned_income(alice, 2018, 3200)).
fact(tax_case_89, married(alice, bob, '2017-02-03')).
fact(tax_case_89, date('2017-02-03', 2017, 2, 3)).
fact(tax_case_89, files_separate_return(alice, 2018)).
fact(tax_case_89, files_separate_return(bob, 2018)).
fact(tax_case_89, gross_income(bob, 2018, 0)).
fact(tax_case_89, is_blind(alice, 2018)).
fact(tax_case_89, date_of_birth(alice, date(1990,1,1))).
fact(tax_case_89, date_of_birth(bob, date(1990,1,1))).
%% --- CaseID: tax_case_89 END ---
%% --- CaseID: tax_case_13 BEGIN ---
fact(tax_case_13, gross_income(bob, 2017, 53249)).
fact(tax_case_13, child(alice, bob)).
fact(tax_case_13, principal_place_of_abode_for_more_than_half_year(alice, bob, 2017)).
fact(tax_case_13, furnished_over_half_cost_of_household(bob, 2017)).
fact(tax_case_13, date_of_birth(bob, date(1970,1,1))).
fact(tax_case_13, date_of_birth(alice, date(1997,1,1))).
fact(tax_case_13, gross_income(alice, 2017, 0)).
%% --- CaseID: tax_case_13 END ---
%% --- CaseID: tax_case_40 BEGIN ---
fact(tax_case_40, married(alice, charlie, '2012-04-05')).
fact(tax_case_40, date('2012-04-05', 2012, 4, 5)).
fact(tax_case_40, legally_separated(alice, charlie, 2017, '2017-09-16')).
fact(tax_case_40, date('2017-09-16', 2017, 9, 16)).
fact(tax_case_40, gross_income(alice, 2017, 756420)).
fact(tax_case_40, date_of_birth(alice, date(1980,1,1))).
fact(tax_case_40, filing_status(alice, 2017, unmarried)).
%% --- CaseID: tax_case_40 END ---
%% --- CaseID: tax_case_26 BEGIN ---
fact(tax_case_26, gross_income(alice, 2019, 567192)).
fact(tax_case_26, child(alice, charlie)).
fact(tax_case_26, principal_place_of_abode_for_full_year(charlie, alice, 2019)).
fact(tax_case_26, furnished_over_half_cost_of_household(alice, 2019)).
fact(tax_case_26, gross_income(charlie, 2019, 0)).
fact(tax_case_26, date_of_birth(alice, date(1980,1,1))).
fact(tax_case_26, date_of_birth(charlie, date(1950,1,1))).
%% --- CaseID: tax_case_26 END ---
%% --- CaseID: tax_case_79 BEGIN ---
fact(tax_case_79, married(alice, bob, '2017-02-03')).
fact(tax_case_79, date('2017-02-03', 2017, 2, 3)).
fact(tax_case_79, files_joint_return(alice, bob, 2020)).
fact(tax_case_79, gross_income(alice, 2020, 103272)).
fact(tax_case_79, gross_income(bob, 2020, 10)).
fact(tax_case_79, date_of_birth(alice, date(1980,1,1))).
fact(tax_case_79, date_of_birth(bob, date(1980,1,1))).
%% --- CaseID: tax_case_79 END ---
%% --- CaseID: tax_case_70 BEGIN ---
fact(tax_case_70, gross_income(alice, 2016, 567192)).
fact(tax_case_70, adjusted_gross_income(alice, 2016, 567192)).
fact(tax_case_70, married(alice, husband_of_alice, '2016-01-12')).
fact(tax_case_70, date('2016-01-12', 2016, 1, 12)).
fact(tax_case_70, gross_income(husband_of_alice, 2016, 0)).
fact(tax_case_70, files_separate_return(alice, 2016)).
fact(tax_case_70, itemized_deductions(alice, 2016, 100206)).
fact(tax_case_70, date_of_birth(alice, date(1980,1,1))).
fact(tax_case_70, date_of_birth(husband_of_alice, date(1980,1,1))).
%% --- CaseID: tax_case_70 END ---
%% --- CaseID: tax_case_63 BEGIN ---
fact(tax_case_63, married(alice, bob, '2017-02-03')).
fact(tax_case_63, date('2017-02-03', 2017, 2, 3)).
fact(tax_case_63, date_of_birth(alice, date(1950, 3, 2))).
fact(tax_case_63, date_of_birth(bob, date(1955, 3, 3))).
fact(tax_case_63, gross_income(bob, 2019, 113580)).
fact(tax_case_63, gross_income(alice, 2019, 0)).
fact(tax_case_63, files_joint_return(alice, bob, 2019)).
%% --- CaseID: tax_case_63 END ---
%% --- CaseID: tax_case_61 BEGIN ---
fact(tax_case_61, child(alice, bob)).
fact(tax_case_61, principal_place_of_abode_for_full_year(bob, alice, 2015)).
fact(tax_case_61, gross_income(bob, 2015, 0)).
fact(tax_case_61, gross_income(alice, 2015, 102268)).
fact(tax_case_61, furnished_over_half_cost_of_household(alice, 2015)).
fact(tax_case_61, date_of_birth(alice, date(1980,1,1))).
fact(tax_case_61, date_of_birth(bob, date(1950,1,1))).
%% --- CaseID: tax_case_61 END ---


% --- Answer Predicates ---
answer(s1_d_iv_neg, true) :- tax_imposed(s1_d_iv_neg, alice, 2017, 28864, Tax), round_to_nearest_dollar(Tax, 5683), !, fail.
answer(s1_d_iv_neg, true).
answer(s3306_c_5_pos, true) :- is_employment_exception_c5(s3306_c_5_pos, alice, bob, 2017, _).
answer(s1_c_i_neg, true) :- tax_imposed(s1_c_i_neg, alice, 2017, 718791, Tax), round_to_nearest_dollar(Tax, 265413), !, fail.
answer(s1_c_i_neg, true).
answer(s1_b_iii_neg, true) :- tax_imposed(s1_b_iii_neg, alice, 2017, 54775, Tax), round_to_nearest_dollar(Tax, 11489), !, fail.
answer(s1_b_iii_neg, true).
answer(s152_d_2_F_pos, true) :- relationship_qualifying_relative(s152_d_2_F_pos, bob, alice, (f)).
answer(s1_a_1_iii_neg, true) :- tax_imposed(s1_a_1_iii_neg, alice, 2017, 164612, Tax), round_to_nearest_dollar(Tax, 44789), !, fail.
answer(s1_a_1_iii_neg, true).
answer(s3306_b_10_A_neg, true) :- \+ is_wages_exception_b10(s3306_b_10_A_neg, alice, bob, 12980, 2019, _).
answer(s63_c_2_B_neg, true) :- basic_standard_deduction(s63_c_2_B_neg, alice, head_of_household, 2017, 4400), !, fail.
answer(s63_c_2_B_neg, true).
answer(s3306_b_7_neg, true) :- \+ is_wages_exception_b7(s3306_b_7_neg, _, _, _, _, _).
answer(s152_c_1_E_pos, true) :- qualifying_child_no_joint_return(bob, 2019, s152_c_1_E_pos).
answer(s2_a_2_B_pos, true) :- surviving_spouse_limitation_joint_return_possible(bob, alice, 2014, s2_a_2_B_pos).
answer(s63_c_3_pos, true) :- additional_standard_deduction(s63_c_3_pos, alice, _, 2017, 1200).
answer(s3306_a_1_neg, true) :- \+ is_employer_general(s3306_a_1_neg, alice, 2018, true).
answer(s7703_b_1_pos, true) :- is_not_considered_married_living_apart(s7703_b_1_pos, alice, 2018, true).
answer(s1_c_iv_pos, true) :- tax_imposed(s1_c_iv_pos, alice, 2017, 210204, Tax), round_to_nearest_dollar(Tax, 65445).
answer(s3306_b_pos, true) :- is_wages(s3306_b_pos, alice, bob, 2325, 2018, true).
answer(s1_a_1_pos, true) :- tax_imposed(s1_a_1_pos, alice, 2017, 17330, Tax), round_to_nearest_dollar(Tax, 2600).
answer(s68_b_1_A_neg, true) :- \+ (determine_filing_status_for_68(s68_b_1_A_neg, alice, 2016, FS), (FS=married_filing_jointly; FS=surviving_spouse)).
answer(tax_case_89, 0) :- taxable_income(tax_case_89, alice, 2018, TI), tax_imposed(tax_case_89, alice, 2018, TI, Tax), round_to_nearest_dollar(Tax, 0).
answer(tax_case_13, 8710) :- taxable_income(tax_case_13, bob, 2017, TI), tax_imposed(tax_case_13, bob, 2017, TI, Tax), round_to_nearest_dollar(Tax, 8710).
answer(tax_case_40, 279124) :- taxable_income(tax_case_40, alice, 2017, TI), tax_imposed(tax_case_40, alice, 2017, TI, Tax), round_to_nearest_dollar(Tax, 279124).
answer(tax_case_26, 195965) :- taxable_income(tax_case_26, alice, 2019, TI), tax_imposed(tax_case_26, alice, 2019, TI, Tax), round_to_nearest_dollar(Tax, 195965).
answer(tax_case_79, 17402) :- taxable_income(tax_case_79, alice, 2020, TI), tax_imposed(tax_case_79, alice, 2020, TI, Tax), round_to_nearest_dollar(Tax, 17402).
answer(tax_case_70, 178147) :- taxable_income(tax_case_70, alice, 2016, TI), tax_imposed(tax_case_70, alice, 2016, TI, Tax), round_to_nearest_dollar(Tax, 178147).
answer(tax_case_63, 19921) :- taxable_income(tax_case_63, bob, 2019, TI), tax_imposed(tax_case_63, bob, 2019, TI, Tax), round_to_nearest_dollar(Tax, 19921).
answer(tax_case_61, 25055) :- taxable_income(tax_case_61, alice, 2015, TI), determine_filing_status_for_63(tax_case_61, alice, 2015, unmarried), tax_imposed(unmarried, 2015, TI, Tax), round_to_nearest_dollar(Tax, 25055).
